---
title: Starting up
requires: [verify:app-up, quiz:where-the-pool-goes]
---

# Starting up

Open the document on hooks. It covers gunicorn's server hooks and
uvicorn's lifespan, and has a table of Muru's seven with a diagram of
the order they run in.

```{file-open}
:title: Open the document on hooks
:path: docs/hooks.md
:factory: Markdown Preview
:area: viewer
```

`hooks.py` defines every hook, and each prints its name, whether it
ran in the host or a worker, and its process id.

```{file-open}
:title: Open hooks.py
:path: hooks.py
:area: viewer
```

Start `greeting.py` with the hooks module and two workers in the
terminal on the left.

```{execute}
:id: start-greeting
:session: server
:wait: 3s
muructl run greeting:application --hooks hooks --processes 2 --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

```{verify}
:id: app-up
:label: The application answers on port {{ app_port }}
:substrate: shell
:trigger: after:start-greeting
curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "is in use by", followed by a
program and its process id, means another program has the port it
names, {{ app_port }} or the dashboard's {{ dashboard_port }}: change
`app_port` or `dashboard_port` from the gear button in the header of
this panel, then start the application again.
```

Read the `hook` lines from the top:

- `on_load` and `pre_fork` in the host, tagged `muru.host[N].stdout:`
  with the host's process id, as the host's own lines are tagged
  `muru.host[N]:`. They ran once, after the import and before the
  fork.

- `post_fork` then `on_ready` in each worker, tagged
  `muru.worker[0].stdout:` and `muru.worker[1].stdout:`, each with its
  own process id. They ran twice, once in each worker.

```{quiz}
:id: where-the-pool-goes
question: An application needs a pool of database connections for each worker. Which hook should open it?
options:
  - { text: "post_fork, which runs in each worker just after it is forked", correct: true }
  - { text: "on_load, which runs once, so the pool is made once", explanation: "on_load runs in the host. A pool made there would be shared by every worker through the fork, its connections used by several processes at once." }
  - { text: "pre_fork, just before the workers are forked", explanation: "pre_fork also runs in the host, so whatever it opens crosses the fork too." }
explanation: "post_fork is the first point at which code runs in the worker that will use what it opens. on_ready also runs there, but is meant for saying the worker serves."
```
