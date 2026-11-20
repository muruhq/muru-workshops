---
title: Other orders
requires: [verify:imports-in-workers, verify:lifespan-seen, verify:app-stopped]
---

# Other orders

When the import check finds an application unsafe to preload, or the
project sets `preload` to `false`, there is no import in the host for
the workers to share. Stop the application and start it that way.

```{interrupt}
:id: stop-reload
:session: server
```

```{execute}
:id: start-no-preload
:session: server
:wait: 3s
muructl run greeting:application --hooks hooks --processes 2 --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --preload false
```

```{verify}
:id: imports-in-workers
:label: The workers imported the application themselves
:substrate: shell
:trigger: after:start-no-preload
curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/
```

Each worker now says `worker 0 imported greeting:application`, and
runs `on_load` and `pre_fork` itself, in the worker, then `post_fork`
and `on_ready`. The host runs no hook at all. A `pre_fork` that closes
something before the fork still runs before `post_fork`, so the same
hooks module works either way.

An ASGI application adds its lifespan. `events.py` prints a line at
lifespan startup and shutdown. Stop the application and start
`events.py` with the hooks.

```{interrupt}
:id: stop-no-preload
:session: server
```

```{file-open}
:title: Open events.py
:path: events.py
:area: viewer
```

```{execute}
:id: start-events
:session: server
:wait: 3s
muructl run events:application --hooks hooks --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

```{verify}
:id: lifespan-seen
:label: The ASGI application answers
:substrate: shell
:trigger: after:start-events
curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/
```

In the worker, `lifespan startup` came between `post_fork` and
`on_ready`. Stop the application to see the other half.

```{interrupt}
:id: stop-events
:session: server
```

```{verify}
:id: app-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-events
for i in 1 2 3 4 5; do curl -s -o /dev/null --max-time 1 http://127.0.0.1:{{ app_port }}/ || { echo "The application has stopped."; exit 0; }; sleep 1; done; echo "The application still answers on port {{ app_port }}. Stop it with the action above."; exit 1
```

`on_drain`, then `lifespan shutdown`, then `on_exit`: the lifespan
runs inside the worker's hooks at both ends.
