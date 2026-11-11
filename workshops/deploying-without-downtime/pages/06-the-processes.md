---
title: The processes
requires: [quiz:daemon-stop, verify:daemon-stopped]
---

# The processes

`show_processes.py` in your workspace finds the daemon serving port
{{ app_port }} and lists every process below it.

```{execute}
:id: show-processes
:session: client
:wait: prompt
python show_processes.py {{ app_port }}
```

Under the daemon:

- **The edge**, a process of its own, holds the listening socket and
  every client's connection.

- **Each release has a host** that imported its code and forked its
  workers. `r1`, serving, has its two workers; `r2`, retained, has its
  host and one worker, kept warm.

- **Each release has a log relay** beside its host, which writes what
  the host and the workers print to the release's log, so a log that
  cannot keep up never holds up a request.

- **The daemon** decides what runs and tells the edge where to send
  requests, but no request passes through it.

```{quiz}
:id: daemon-stop
question: "`muructl daemon stop`, without options, stops the daemon process. What happens to requests to port {{ app_port }} afterwards?"
options:
  - { text: "They are refused until the daemon is started again", explanation: "The daemon is not on the request path. The edge holds the socket and the connections." }
  - { text: "They are served as before, by the edge and the releases", correct: true }
  - { text: "They queue at the edge until the daemon is back", explanation: "The edge has the routing it was last given and goes on using it. It does not need the daemon to serve." }
explanation: "`muructl daemon stop` detaches: the daemon exits, and the edge and the hosts go on serving. The next `muructl daemon start` takes them over. That is how the daemon is restarted or upgraded without costing a request. `--shutdown` stops everything."
```

You have finished with the daemon. `--shutdown` drains every release,
stops the hosts and the edge, then the daemon.

```{execute}
:id: stop-daemon
:session: client
:wait: prompt
muructl daemon stop --shutdown
```

```{verify}
:id: daemon-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-daemon
if curl -s -o /dev/null --max-time 2 http://127.0.0.1:{{ app_port }}/; then echo "Something still answers on port {{ app_port }}. Stop the daemon with the action above."; exit 1; fi; echo "The daemon and everything under it have stopped."
```
