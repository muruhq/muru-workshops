---
title: A long command line
requires: [verify:served-from-flags]
---

# A long command line

Open the document on where servers keep their settings. It covers
gunicorn's five sources and its configuration file, uvicorn's and
Granian's command lines and environment variables, mod_wsgi's Apache
directives, and Muru's `[tool.muru]` table, with a diagram of where
the table goes.

```{file-open}
:title: Open the document on where settings live
:path: docs/where-settings-live.md
:factory: Markdown Preview
:area: viewer
```

The project's application answers every request with a title it takes
from the `NOTES_TITLE` environment variable, and the index and process
id of the worker that answered. Its hooks module prints a line as each
worker starts.

```{file-open}
:title: Open notes/notes.py
:path: notes/notes.py
:area: viewer
```

```{file-open}
:title: Open notes/hooks.py
:path: notes/hooks.py
:area: viewer
```

Its `pyproject.toml` says nothing about serving it yet, so everything
goes on the command line: the environment variable, the directory to
run in, two worker processes of two threads, the hooks module, a soft
timeout of five seconds and the port. Start it in the terminal on the
left.

```{execute}
:id: start-from-flags
:session: server
:wait: 3s
NOTES_TITLE="Team notes" muructl run notes:application --chdir notes --processes 2 --threads 2 --hooks hooks --timeout soft=5s --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

The hooks module's `worker 0 is starting` and `worker 1 is starting`
arrive tagged by worker, and the serving line says `2 workers of 2
threads`. Ask the application for its title.

```{execute}
:id: ask-from-flags
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/; echo
```

```{verify}
:id: served-from-flags
:label: The project answers with its title
:substrate: shell
:trigger: after:ask-from-flags
out=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/); printf '%s\n' "$out" | grep '"title": "Team notes"' || { printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}"; exit 1; }
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "is in use by", followed by a
program and its process id, means another program has the port it
names, {{ app_port }} or the dashboard's {{ dashboard_port }}: change
`app_port` or `dashboard_port` from the gear button in the header of
this panel, then start the project again.
```

That command line is the only record of how the project is served. The
next person to run it, or you next week, has to know all of it.
