"""Send requests eight at a time and report what the edge measured.

Usage: python load.py PORT PATH...

For each path, sends 40 requests, eight at a time, and prints how many
were served per second and the median of three times the edge recorded
for them in its JSON access log, requests.jsonl: the total, the time a
request queued at the edge waiting for a free worker thread, and the
time in the application. The first line says how many CPUs this
process may use.
"""

import concurrent.futures
import json
import math
import os
import statistics
import sys
import time
import urllib.request

LOG = "requests.jsonl"
REQUESTS = 40
AT_A_TIME = 8


def cpus() -> int:
    """Return the CPUs available, allowing for a container's CPU quota."""

    count = os.process_cpu_count() or 1

    try:
        with open("/sys/fs/cgroup/cpu.max") as quota_file:
            quota, period = quota_file.read().split()

        if quota != "max":
            count = min(count, max(1, math.ceil(int(quota) / int(period))))

    except (OSError, ValueError):
        pass

    return count


def fetch(url: str) -> str:
    """Make one request and return the request id the edge gave it."""

    with urllib.request.urlopen(url, timeout=60) as response:
        response.read()
        return response.headers["X-Request-ID"]


def records(ids: set[str]) -> list[dict]:
    """Return the access log records for the requests with these ids."""

    for _ in range(20):
        with open(LOG) as log:
            found = [
                record
                for record in map(json.loads, log)
                if record["request_id"] in ids
            ]

        if len(found) == len(ids):
            return found

        time.sleep(0.1)

    return found


def run(port: str, path: str) -> None:
    url = f"http://127.0.0.1:{port}{path}"
    start = time.monotonic()

    with concurrent.futures.ThreadPoolExecutor(AT_A_TIME) as pool:
        ids = set(pool.map(fetch, [url] * REQUESTS))

    elapsed = time.monotonic() - start
    found = records(ids)

    def median(field: str) -> float:
        return statistics.median(record[field] for record in found)

    print(
        f"{path:<9} {REQUESTS / elapsed:5.1f} per second   "
        f"total {median('total_ms'):4.0f}ms   "
        f"queue {median('queue_ms'):4.0f}ms   "
        f"app {median('app_ms'):4.0f}ms"
    )


def main() -> int:
    if len(sys.argv) < 3:
        print("Usage: python load.py PORT PATH...")
        return 2

    if not os.path.exists(LOG):
        print(f"No {LOG} here. Start muructl run with --access-log-file {LOG}.")
        return 1

    print(f"{REQUESTS} requests to each path, {AT_A_TIME} at a time, on {cpus()} CPUs")
    print("medians:")

    for path in sys.argv[2:]:
        run(sys.argv[1], path)

    return 0


if __name__ == "__main__":
    sys.exit(main())
