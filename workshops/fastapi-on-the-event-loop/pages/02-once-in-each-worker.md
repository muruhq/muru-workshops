---
title: Once in each worker
requires: [quiz:lifespan-fails, verify:prices-served]
---

# Once in each worker

Open the document on FastAPI on an event loop. Read it through; each
of its sections comes up on the pages that follow.

```{file-open}
:title: Open the document on FastAPI on an event loop
:path: docs/the-event-loop.md
:factory: Markdown Preview
:area: viewer
```

`main.py` has a lifespan that loads `prices.json` and hands the prices
to every request, and path operations of every kind.

```{file-open}
:title: Open main.py
:path: main.py
:area: viewer
```

Start it with two worker processes in the terminal on the left.

```{execute}
:id: start-two
:session: server
:wait: 4s
muructl run main:app --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --processes 2
```

`prices loaded in process ...` appears twice, once from each worker:
the lifespan runs in each worker after the fork, before it takes a
request. The serving line says `2 workers of concurrency 1000`.

```{execute}
:id: ask-prices
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/prices; echo
```

```{verify}
:id: prices-served
:label: The service answers with the prices
:substrate: shell
:trigger: after:ask-prices
out=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/prices); printf '%s\n' "$out" | grep '"teapot":25' || { printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}"; exit 1; }
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "is in use by", followed by a
program and its process id, means another program has the port it
names, {{ app_port }} or the dashboard's {{ dashboard_port }}: change
`app_port` or `dashboard_port` from the gear button in the header of
this panel, then start the service again.
```

A lifespan that loads something is one that can fail to load it.

```{quiz}
:id: lifespan-fails
question: "`prices.json` is missing when the service starts. What happens?"
options:
  - { text: "Each worker fails to start; the host tries again, and after three failures muructl run stops", correct: true }
  - { text: "The service starts, and each request fails because request.state has no prices", explanation: "A worker takes requests only once its lifespan startup has finished, and this one raises." }
  - { text: "The workers start without a lifespan, since it raised", explanation: "That is for an application that raises before it has answered lifespan.startup at all, meaning it does not support lifespan. This one started the lifespan and then failed." }
explanation: "A lifespan that fails at startup fails the worker. muructl run retries a worker that fails to start, and stops when one fails three times."
```

Stop the service, move `prices.json` aside, and start it again.

```{interrupt}
:id: stop-two
:session: server
```

```{file-rename}
:id: hide-prices
:title: Rename prices.json to prices.json.saved
:path: prices.json
:to: prices.json.saved
```

```{execute}
:id: start-without-prices
:session: server
:wait: prompt
muructl run main:app --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

The worker's traceback ends `FileNotFoundError: ... 'prices.json'`,
and the host says `worker 0 (pid ...) exited with status 1,
restarting`. That happens twice, and after the third failure the host
says `worker 0 failed 3 times at start ... stopping`. `muructl run`
exits rather than serve with no worker. Put the file back.

```{file-rename}
:id: restore-prices
:title: Rename prices.json.saved back to prices.json
:path: prices.json.saved
:to: prices.json
```
