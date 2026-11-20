---
title: What needs attention
requires: [verify:errors-only, verify:service-stopped]
---

# What needs attention

A service that is checked by a load balancer every few seconds fills
its access log with `/health`. `mixed.py` sends a morning's mix: five
health checks, a user name check, an export that takes a second and a
half, a path that does not exist, and a last health check. Restart the
service with the health checks left out of the access log.

```{interrupt}
:id: stop-gil
:session: server
```

```{execute}
:id: start-exclude
:session: server
:wait: 3s
muructl run accounts:application --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --access-log-exclude /health
```

```{execute}
:id: run-mixed
:session: client
:wait: prompt
python mixed.py {{ app_port }}
```

Nine requests, three access log lines: the check, the export and the
`404`. Now keep only what needs attention: errors, and requests slower
than a second.

```{interrupt}
:id: stop-exclude
:session: server
```

```{execute}
:id: start-errors
:session: server
:wait: 3s
muructl run accounts:application --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --access-log errors --slow 1s
```

```{execute}
:id: run-mixed-errors
:session: client
:wait: prompt
python mixed.py {{ app_port }}
```

```{verify}
:id: errors-only
:label: The service answers the mix
:substrate: shell
:trigger: after:run-mixed-errors
python mixed.py {{ app_port }} | grep -c '' | grep -q '^9$' && echo "All nine requests were answered." || { echo "The mix was not answered. Check the terminal on the left."; exit 1; }
```

Two lines: the export, `1.51s`, and the `404`. With the timeouts of
the earlier pages set too, a soft timeout's `504` and a replaced
worker's `502` would be among them, which is what a project that
hangs now and then wants to see.

You have finished with the service. Stop it in the terminal on the
left.

```{interrupt}
:id: stop-errors
:session: server
```

```{verify}
:id: service-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-errors
for i in 1 2 3 4 5; do curl -s -o /dev/null --max-time 1 http://127.0.0.1:{{ app_port }}/health || { echo "The service has stopped."; exit 0; }; sleep 1; done; echo "The service still answers on port {{ app_port }}. Stop it with the action above."; exit 1
```
