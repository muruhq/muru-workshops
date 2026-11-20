---
title: Flags and mistakes
requires: [quiz:flag-or-table, verify:typo-fixed]
---

# Flags and mistakes

The table says two processes. Sometimes one run needs something else,
such as a single worker while you chase a problem.

```{quiz}
:id: flag-or-table
question: The table says `processes = 2`. You start the project with `muructl run notes --port {{ app_port }} --processes 1`. How many workers serve it?
options:
  - { text: "One: the flag wins for this run, and the table is left as it is", correct: true }
  - { text: "Two: the table is the project's setting and the flag is ignored", explanation: "A flag given for a setting the table also has wins, for that run only." }
  - { text: "None: muructl refuses a flag that contradicts the table", explanation: "Flags and the table are merged, flag first, so one run can differ without editing the project." }
explanation: "muructl run takes each setting from the command line first, then muru.local.toml, then the project's tables, then its own default."
```

Stop the project and start it with one worker.

```{interrupt}
:id: stop-from-table
:session: server
```

```{execute}
:id: start-one-worker
:session: server
:wait: 3s
muructl run notes --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --processes 1
```

The serving line says `1 worker of 2 threads`: the processes from the
flag, the threads still from the table. `notes/pyproject.toml` is
unchanged.

A table is only useful if a mistake in it is noticed. Stop the project
and misspell `threads` as `thread`.

```{interrupt}
:id: stop-one-worker
:session: server
```

```{editor-replace}
:id: add-typo
:title: Misspell threads in notes/pyproject.toml
:path: notes/pyproject.toml
:match: threads = 2
thread = 2
```

```{execute}
:id: start-with-typo
:session: server
:wait: prompt
muructl run notes --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

Nothing starts. The error points at the line, says ``unknown field
`thread` ``, and lists every key the table takes, from `entrypoint` to
`commands`. A key the table does not know is never ignored, so a
setting cannot silently fail to apply. Put it right and start the
project again.

```{editor-replace}
:id: fix-typo
:title: Spell threads correctly again
:path: notes/pyproject.toml
:match: thread = 2
threads = 2
```

```{execute}
:id: start-fixed
:session: server
:wait: 3s
muructl run notes --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

```{verify}
:id: typo-fixed
:label: The table is right and the project is served
:substrate: shell
:trigger: after:start-fixed
grep -q '^threads = 2' notes/pyproject.toml || { echo "notes/pyproject.toml still says thread. Put it right with the action above."; exit 1; }; curl -s --max-time 2 -o /dev/null -w '%{http_code}\n' http://127.0.0.1:{{ app_port }}/ | grep '^200$' || { echo "Nothing answers on port {{ app_port }}. Start the project with the action above."; exit 1; }
```
