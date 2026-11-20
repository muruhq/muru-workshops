---
title: How this checkout serves
requires: [verify:served-from-run-table, verify:served-from-local, quiz:three-places]
---

# How this checkout serves

Read the document's section on the run table. The port, the reload
patterns, HTTPS, the access log and the dashboard describe how a
checkout of the project is served while someone works on it, and a
`[tool.muru.run]` table holds them, with a key for each flag of
`muructl run`.

Stop the project and append the table, with the port and an access log
of errors only.

```{interrupt}
:id: stop-from-table
:session: server
```

```{file-write}
:id: add-run-table
:title: Add the [tool.muru.run] table to notes/pyproject.toml
:path: notes/pyproject.toml
:mode: append
:open: true
:area: viewer


# How muructl run serves a checkout of the project. The daemon ignores
# this table.
[tool.muru.run]
port = {{ app_port }}
dashboard = "127.0.0.1:{{ dashboard_port }}"
access_log = "errors"
```

Now nothing goes on the command line but the project.

```{execute}
:id: start-from-run-table
:session: server
:wait: 3s
muructl run notes
```

The serving line names port {{ app_port }} from the table, and an
ordinary request leaves no access log line.

```{execute}
:id: ask-from-run-table
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/; echo
```

```{verify}
:id: served-from-run-table
:label: The project is served on the table's port
:substrate: shell
:trigger: after:ask-from-run-table
grep -q '^\[tool.muru.run\]' notes/pyproject.toml || { echo "notes/pyproject.toml has no [tool.muru.run] table yet. Add it with the action above."; exit 1; }; out=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/); printf '%s\n' "$out" | grep '"title": "Team notes"' || { printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}"; exit 1; }
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "is in use by", followed by a
program and its process id, means another program has the port it
names, {{ app_port }} or the dashboard's {{ dashboard_port }}: change
`app_port` or `dashboard_port` from the gear button in the header of
this panel, write the table again so it has the new port, and start
the project again.
```

The table is committed with the project, so it says how everyone
serves it. One machine can differ: suppose port {{ app_port }} is taken
on yours. A `muru.local.toml` beside `pyproject.toml` holds a `[run]`
table with the same keys for this machine alone.

```{file-write}
:id: write-local
:title: Write notes/muru.local.toml with another port
:path: notes/muru.local.toml
:open: true
:area: viewer
# This machine's own settings for muructl run; never committed.
[run]
port = {{ other_port }}
```

The run on the left noticed the new file and reloaded, since a run
watches its settings files, but it says `muru.local.toml changed port;
restart the run for it to take effect`. A reload reads the settings
again, and a new port needs a new run.

A file for one machine must never be committed, and the run checks
that the project's `.gitignore` names it. This project has no
`.gitignore` yet; give it the one every Python project has, in the
terminal on the right.

```{execute}
:id: write-gitignore
:session: client
:wait: prompt
printf '__pycache__/\n' > notes/.gitignore
```

Stop the project and start it again, with the same command.

```{interrupt}
:id: stop-from-run-table
:session: server
```

```{execute}
:id: start-from-local
:session: server
:wait: 3s
muructl run notes
```

Two new lines: `muru: using [run] from notes/muru.local.toml`, and a
warning that the file `is not covered by the project's .gitignore`,
with what to do about it. The serving line now names port
{{ other_port }}.

```{execute}
:id: ask-from-local
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ other_port }}/; echo
```

```{verify}
:id: served-from-local
:label: The project is served on this machine's port
:substrate: shell
:trigger: after:ask-from-local
grep -q '^\[run\]' notes/muru.local.toml 2>/dev/null || { echo "notes/muru.local.toml has no [run] table yet. Write it with the action above."; exit 1; }; out=$(curl -s --max-time 2 http://127.0.0.1:{{ other_port }}/); printf '%s\n' "$out" | grep '"title": "Team notes"' || { printf '%s\n' "${out:-Nothing answers on port {{ other_port }}. Start the project again with the action above.}"; exit 1; }
```

Add the file to the project's `.gitignore`, where it belongs. The
warning goes on the next start, and the next page starts the project
again.

```{execute}
:id: ignore-local
:session: client
:wait: prompt
echo muru.local.toml >> notes/.gitignore
```

Three places, then: `[tool.muru]` for what the application is,
`[tool.muru.run]` for how a checkout is served, `muru.local.toml` for
how this machine serves it. A flag wins over the local file, and the
local file over the project's table.

```{quiz}
:id: three-places
question: The team agrees that a change to a template under `templates/` should start a new release, as a change to a module does. Where does `reload_include = ["**/*.html"]` belong?
options:
  - { text: "In `muru.local.toml`, since reloading is a development setting", explanation: "The local file is for one machine alone. Everyone working on the project wants templates to count, so it belongs in the committed table." }
  - { text: "In `[tool.muru.run]`, with the other settings of how a checkout is served", correct: true }
  - { text: "In `[tool.muru]`, beside the hooks and the timeouts", explanation: "Those describe the application wherever it runs, under the daemon too. The daemon never reloads, and `[tool.muru]` has no reload keys." }
explanation: "Reloading, its patterns and directories included, is how muructl run serves a checkout, which is what [tool.muru.run] holds; the daemon ignores it. muru.local.toml would make the same setting one machine's own."
```
