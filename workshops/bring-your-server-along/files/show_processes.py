"""Show the processes of the Muru daemon serving a port.

Usage: python show_processes.py PORT

Asks `muructl daemon status` for the daemon this workspace's settings
name, checks that it serves PORT, then lists every process below it as
a tree, saying what each one is and which release it belongs to.

Every process of Muru's names itself in its title, which is what ps
shows in place of its command line: `muru edge`, then `muru relay`,
`muru host` and `muru worker`, each with its release, such as
`muru worker greeter@r2 default/1`. A managed server's processes keep
their own command lines, below a log relay of their own.
"""

import json
import subprocess
import sys


def process_table() -> dict[int, tuple[int, str]]:
    """Return every process as pid -> (parent pid, title or command line)."""

    output = subprocess.run(
        ["ps", "-e", "-o", "pid=,ppid=,args="],
        capture_output=True,
        text=True,
        check=True,
    ).stdout

    table = {}

    for line in output.splitlines():
        fields = line.split(None, 2)

        if len(fields) == 3:
            table[int(fields[0])] = (int(fields[1]), fields[2].strip())

    return table


def daemon_pid(port: str) -> int | None:
    """Return the pid of the daemon this workspace names, if it serves the port."""

    answer = subprocess.run(
        ["muructl", "daemon", "status", "--json"],
        capture_output=True,
        text=True,
    )

    if answer.returncode != 0:
        return None

    status = json.loads(answer.stdout)

    if not any(listener.endswith(f":{port}") for listener in status.get("listeners", [])):
        return None

    return status.get("pid")


def describe(title: str, parent_title: str) -> str:
    """Say what a process is, from its title and its parent's."""

    words = title.split()

    if words[:2] == ["muru", "edge"]:
        return "the edge: holds the listening socket, talks to every client"

    if words[:2] == ["muru", "relay"] and len(words) >= 3:
        release = words[2]

        if len(words) >= 5 and words[3] == "instance":
            return f"the log relay of {release}'s server: writes its output to the release's log"

        return f"the log relay of {release}: writes its host's and workers' output to its log"

    if words[:2] == ["muru", "host"] and len(words) >= 3:
        return f"the host of {words[2]}: imported the code, forks the workers"

    if words[:2] == ["muru", "worker"] and len(words) >= 4:
        return f"worker {words[3]} of {words[2]}, forked from its host"

    if "gunicorn" in title:
        if "gunicorn" in parent_title:
            return "a gunicorn worker"

        return "gunicorn's master process, run by its log relay"

    return " ".join(words[:4])


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python show_processes.py PORT")
        return 2

    port = sys.argv[1]
    daemon = daemon_pid(port)
    table = process_table()

    if daemon is None or daemon not in table:
        print(f"No Muru daemon is serving port {port}. Start it first.")
        return 1

    children: dict[int, list[int]] = {}

    for pid, (parent, _) in table.items():
        children.setdefault(parent, []).append(pid)

    def show(pid: int, depth: int) -> None:
        parent, title = table[pid]
        parent_title = table.get(parent, (0, ""))[1]
        what = (
            "the daemon: the controller, never on the request path"
            if depth == 0
            else describe(title, parent_title)
        )

        print(f"{'  ' * depth}pid {pid:<7} {what}")

        for child in sorted(children.get(pid, [])):
            show(child, depth + 1)

    show(daemon, 0)

    return 0


if __name__ == "__main__":
    sys.exit(main())
