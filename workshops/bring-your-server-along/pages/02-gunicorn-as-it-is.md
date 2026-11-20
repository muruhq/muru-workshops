---
title: gunicorn as it is
requires: [verify:gunicorn-serving]
---

# gunicorn as it is

Open the document on moving a deployment to Muru a step at a time. It
covers the managed server release this page deploys, the native
release the next pages move the traffic to, and, at the end, when to
choose which server.

```{file-open}
:title: Open the document on moving a deployment to Muru
:path: docs/cutting-over.md
:factory: Markdown Preview
:area: viewer
```

The application is an ordinary WSGI application. Its docstring has the
gunicorn command it is deployed with today. Each response says which
server ran it, from `SERVER_SOFTWARE`, which every WSGI server sets to
its own name and version.

```{file-open}
:title: Open orders/orders.py
:path: orders/orders.py
:area: viewer
```

Start the daemon in the terminal on the right.

```{execute}
:id: start-daemon
:session: client
:wait: prompt
muructl daemon start --listen 127.0.0.1:{{ app_port }}
```

Now deploy the application with that same gunicorn command, after
`--`, with `{bind}` where the address went. `--server gunicorn` names
the profile, which tells Muru how gunicorn binds and how it is
stopped.

```{execute}
:id: deploy-gunicorn
:session: client
:wait: prompt
muructl deploy orders orders --server gunicorn -- gunicorn --workers 2 --bind '{bind}' orders:application
```

The daemon started gunicorn on a Unix socket of its own, waited until
it answered, and told the edge to send it the application's requests.

```{execute}
:id: curl-gunicorn
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/
```

```{verify}
:id: gunicorn-serving
:label: gunicorn serves the application through the edge
:substrate: shell
:trigger: after:curl-gunicorn
out=$(curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/); printf '%s\n' "$out" | grep 'Served by gunicorn' || { printf '%s\n' "$out"; exit 1; }
```

```{hint}
:title: If the check fails
If `muructl daemon start` said the address was in use, change
`app_port` from the gear button in the header of this panel and start
it again, then deploy. If the deploy failed, `muructl logs orders`
shows what gunicorn printed.
```

`muructl release list` shows the release as one instance of the
`gunicorn` profile, and `show_processes.py` the gunicorn master and
its two workers beside the edge, under a log relay of their own that
writes what gunicorn prints to the release's log.

```{execute}
:id: list-gunicorn
:session: client
:wait: prompt
muructl release list orders
```

```{execute}
:id: show-gunicorn
:session: client
:wait: prompt
python show_processes.py {{ app_port }}
```

Last, declare the site's virtual host and route, from `routes.toml`;
the comment at its top says why the next page needs them.

```{execute}
:id: apply-routes
:session: client
:wait: prompt
muructl apply -f routes.toml
```
