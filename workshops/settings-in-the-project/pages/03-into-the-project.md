---
title: Into the project
requires: [verify:served-from-table]
---

# Into the project

Stop the project in the terminal on the left.

```{interrupt}
:id: stop-from-flags
:session: server
```

Now add a `[tool.muru]` table to the project's `pyproject.toml` with
the same settings: the entrypoint, the processes and threads, the
hooks module, the soft timeout in its own `timeouts` table, and the
environment variable in an `env` table.

```{file-write}
:id: add-table
:title: Add the [tool.muru] table to notes/pyproject.toml
:path: notes/pyproject.toml
:mode: append
:open: true
:area: viewer


# How muructl run serves the project, and what the daemon starts from
# when the project is deployed to it.
[tool.muru]
entrypoint = "notes:application"
processes = 2
threads = 2
hooks = "hooks"

[tool.muru.timeouts]
soft_timeout = "5s"

[tool.muru.env]
NOTES_TITLE = "Team notes"
```

Start the project again, this time giving `muructl run` only the
project's directory and the port.

```{execute}
:id: start-from-table
:session: server
:wait: 3s
muructl run notes --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

The first line, `muru: using [tool.muru] from notes/pyproject.toml`,
says where the settings came from, and the rest are as before: two
workers of two threads, each printing its line from the hooks module.
The project directory is where the host runs, as `--chdir` made it
before, so the import of `notes` finds `notes/notes.py`.

```{execute}
:id: ask-from-table
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/; echo
```

```{verify}
:id: served-from-table
:label: The project is served from its table
:substrate: shell
:trigger: after:ask-from-table
grep -q '^\[tool.muru\]' notes/pyproject.toml || { echo "notes/pyproject.toml has no [tool.muru] table yet. Add it with the action above."; exit 1; }; out=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/); printf '%s\n' "$out" | grep '"title": "Team notes"' || { printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}"; exit 1; }
```

The title arrived without anything in the shell: the `env` table sets
it for the workers. It also wins over the same variable set in the
shell, since the table says what the workers get.

The port stayed on the command line. The table holds what the
application is, wherever it runs; the port, HTTPS, the reload
patterns, the access log and the dashboard are about how this checkout
is served, and have no keys in it. They have a table of their own,
which the next page writes.
