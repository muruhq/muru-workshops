---
title: A post_fork hook
requires: [verify:preloaded-serves, verify:server-stopped]
---

# A post_fork hook

Most things that are wrong at import time are right a moment later. A
`post_fork` hook runs in each worker right after it is forked from the
host, which is the place to open a socket or start a thread that each
worker needs of its own. Open the hooks module in your workspace.

```{file-open}
:title: Open hooks.py
:path: hooks.py
:area: viewer
```

Now stop the catalogue starting the metrics client at import.

```{file-open}
:title: Open catalog.py
:path: catalog.py
:area: viewer
```

```{editor-replace}
:id: move-to-hook
:title: Leave the metrics client to the hook
:path: catalog.py
:regex: true
:match: # Open the socket[\s\S]*?metrics\.client\.start\(\)
# The metrics client is started in each worker by post_fork in
# hooks.py, after the worker is forked from the host.
```

Start the catalogue again, still with `--preload true`, and with
`--hooks hooks` naming the hooks module.

```{execute}
:id: start-with-hook
:session: server
:wait: 3s
muructl run catalog:application --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --processes 2 --preload true --hooks hooks
```

No `preload:` lines this time: the import was clean, so the host
preloaded the catalogue and forked both workers from it. Each worker
then ran `post_fork`, which printed a line tagged with the worker and
started a metrics client of its own.

```{verify}
:id: preloaded-serves
:label: The catalogue answers with --preload true
:substrate: shell
:trigger: after:start-with-hook
curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/
```

Under `--preload true` it would not be serving at all unless the
import check had passed. Send it some requests.

```{execute}
:id: requests-with-hook
:session: client
:wait: prompt
for i in 1 2 3 4 5 6; do curl -s http://127.0.0.1:{{ app_port }}/; done
```

Within five seconds, both workers' senders report their counts again,
this time from workers forked from a preloaded host.

gunicorn has a `post_fork(server, worker)` hook in its configuration
file for the same purpose. What it does not have is the check that
tells you that you need it.

You have finished with the catalogue. Stop it in the terminal on the
left.

```{interrupt}
:id: stop-server
:session: server
```

```{verify}
:id: server-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-server
if curl -s -o /dev/null --max-time 2 http://127.0.0.1:{{ app_port }}/; then echo "The catalogue still answers on port {{ app_port }}. Stop it with the action above."; exit 1; fi; echo "The catalogue has stopped."
```
