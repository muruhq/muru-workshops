"""Show the processes of the Muru daemon serving a port.

Usage: python show_processes.py PORT

Finds the muructl daemon started with --listen on PORT, then every
process below it, and prints them as a tree, saying what each one is
and which release it belongs to.
"""

import os
import subprocess
import sys


def process_table() -> dict[int, tuple[int, list[str]]]:
    """Return every process as pid -> (parent pid, command line words)."""

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
            table[int(fields[0])] = (int(fields[1]), fields[2].split())

    return table


def option(words: list[str], name: str) -> str | None:
    """Return the value after an option, if the command line has it."""

    for word, following in zip(words, words[1:]):
        if word == name:
            return following

    return None


def is_daemon(words: list[str], port: str) -> bool:
    if len(words) < 3 or os.path.basename(words[0]) != "muructl":
        return False

    listen = option(words, "--listen") or "127.0.0.1:8080"

    return words[1:3] == ["daemon", "run"] and listen.endswith(f":{port}")


def describe(words: list[str], parent_words: list[str], releases: dict[str, str]) -> str:
    """Say what a process is, from its command line and its parent's."""

    name = os.path.basename(words[0])

    if name == "muructl" and words[1:3] == ["edge", "run"]:
        return "the edge: holds the listening socket, talks to every client"

    if name == "muructl" and words[1:3] == ["relay", "run"]:
        release = releases.get(os.path.dirname(option(words, "--control") or ""))

        if release:
            return f"the log relay of {release}: writes its host's and workers' output to its log"

        return "a release's log relay: writes its host's and workers' output to its log"

    if "muru.host" in words:
        release = f"{option(words, '--name')}@{option(words, '--release')}"

        if "muru.host" in parent_words:
            return f"a worker of {release}, forked from its host"

        return f"the host of {release}: imported the code, forks the workers"

    if "gunicorn" in " ".join(words):
        if "gunicorn" in " ".join(parent_words):
            return "a gunicorn worker"

        return "gunicorn's master process, started by the daemon"

    return " ".join([name] + words[1:4])


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python show_processes.py PORT")
        return 2

    port = sys.argv[1]
    table = process_table()
    daemons = [pid for pid, (_, words) in table.items() if is_daemon(words, port)]

    if not daemons:
        print(f"No Muru daemon is serving port {port}. Start it first.")
        return 1

    # A release's log relay keeps its control socket beside its host's,
    # so the directory says which release each relay belongs to.
    releases = {}

    for _, words in table.values():
        if "muru.host" in words and option(words, "--control"):
            directory = os.path.dirname(option(words, "--control"))
            releases[directory] = f"{option(words, '--name')}@{option(words, '--release')}"

    children: dict[int, list[int]] = {}

    for pid, (parent, _) in table.items():
        children.setdefault(parent, []).append(pid)

    def show(pid: int, depth: int) -> None:
        parent, words = table[pid]
        parent_words = table.get(parent, (0, []))[1]
        what = (
            "the daemon: the controller, never on the request path"
            if depth == 0
            else describe(words, parent_words, releases)
        )

        print(f"{'  ' * depth}pid {pid:<7} {what}")

        for child in sorted(children.get(pid, [])):
            show(child, depth + 1)

    show(daemons[0], 0)

    return 0


if __name__ == "__main__":
    sys.exit(main())
