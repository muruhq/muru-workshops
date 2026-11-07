---
title: The dashboard
requires: [verify:dashboard-up, verify:shop-stopped]
---

# The dashboard

A startup line gave the dashboard's address. It is served on
loopback only, needs no sign-in while you develop, and is read-only.
Open it.

```{url-open}
:title: Open the dashboard
:when: web_proxy
:url: {{ jupyter_url }}proxy/{{ dashboard_port }}/
:pane: dashboard
:area: viewer
```

```{url-open}
:title: Open the dashboard in a new browser tab
:when: not web_proxy
:url: http://127.0.0.1:{{ dashboard_port }}/
```

```{verify}
:id: dashboard-up
:label: The dashboard answers on port {{ dashboard_port }}
:substrate: shell
:trigger: page-enter
curl -sS --max-time 2 -o /dev/null -w '%{http_code}\n' http://127.0.0.1:{{ dashboard_port }}/ | grep '^200$'
```

Send it something to show: five rounds of the same seven requests,
which takes about eight seconds because of the slow report.

```{execute}
:id: send-rounds
:session: client
:wait: prompt
python send_requests.py {{ app_port }} 5
```

The page refreshes every two seconds. Look for:

- the last minute: requests per second, median and 95th percentile
  latency, and the count of 5xx responses, which are the failing
  product's;

- the two workers, each with its busy threads of its four in the
  Threads column, since a WSGI request holds a thread;

- the charts of requests, errors and latency over time;

- the recent requests and the recent output, the same lines the
  terminal shows, which `--access-log errors` only thinned out in the
  terminal: the dashboard still has every request.

gunicorn and uvicorn have nothing like it. The same figures are at
`/metrics` on the dashboard's address, in the Prometheus format, for a
monitoring system to collect.

You have finished with the shop. Stop it in the terminal on the left.

```{interrupt}
:id: stop-shop
:session: server
```

```{verify}
:id: shop-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-shop
if curl -s -o /dev/null --max-time 2 http://127.0.0.1:{{ app_port }}/; then echo "The shop still answers on port {{ app_port }}. Stop it with the action above."; exit 1; fi; echo "The shop has stopped."
```
