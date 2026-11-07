"""Ask for a page ten times a second until what it says changes.

Usage: python watch.py PORT

Prints the first line of the page when it starts and again each time
it changes, with the seconds since it started. One second after the
first change, or after two minutes with none, it stops and prints how
many requests it sent and how many failed. The summary also goes to
watch.log, followed by how each failed request failed and when.
"""

import sys
import time
import urllib.error
import urllib.request

LIMIT = 120.0


def first_line(url: str) -> tuple[str | None, str | None]:
    """Return the first line of the page, or None and how it failed."""

    try:
        with urllib.request.urlopen(url, timeout=5) as response:
            return response.read().decode().splitlines()[0], None

    except urllib.error.HTTPError as error:
        return None, f"HTTP {error.code}"

    except (urllib.error.URLError, OSError) as error:
        reason = getattr(error, "reason", error)
        return None, f"{type(reason).__name__}: {reason}"


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python watch.py PORT")
        return 2

    url = f"http://127.0.0.1:{sys.argv[1]}/"
    start = time.monotonic()
    stop_at = start + LIMIT
    sent = 0
    failures = []
    last = None

    while time.monotonic() < stop_at:
        line, error = first_line(url)
        sent += 1
        elapsed = time.monotonic() - start

        if line is None:
            failures.append(f"{elapsed:5.1f}s  request failed: {error}")
            print(failures[-1])

        elif line != last:
            print(f"{elapsed:5.1f}s  {line}")

            if last is not None:
                stop_at = min(stop_at, time.monotonic() + 1.0)

            last = line

        time.sleep(0.1)

    summary = f"{sent} requests in {time.monotonic() - start:.1f}s, {len(failures)} failed"

    print(summary)

    with open("watch.log", "w") as log:
        log.write("\n".join([summary, *failures]) + "\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
