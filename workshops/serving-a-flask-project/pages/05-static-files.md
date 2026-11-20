---
title: Static files
requires: [verify:edge-serves-static, verify:shop-stopped]
---

# Static files

Open the shop's front page again. Its stylesheet comes from Flask's
`static` folder, through `url_for('static', ...)`.

```{url-open}
:title: Open the shop
:when: web_proxy
:url: {{ jupyter_url }}proxy/{{ app_port }}/
:pane: shop
:area: viewer
```

```{url-open}
:title: Open the shop
:when: not web_proxy
:url: http://127.0.0.1:{{ app_port }}/
:pane: shop
:area: viewer
```

In the terminal on the left, the page and its stylesheet each have an
access log line, `200 GET /static/shop.css` with a `worker=`: Flask
read the file and sent it from a worker, taking one of its threads
for as long as that took. The project works with nothing else
configured, but a worker's thread is for the views.

The project can say which of its directories the edge serves itself.
Stop the shop and add the entry to its table: a path prefix and the
directory, relative to the project.

```{interrupt}
:id: stop-flask-static
:session: server
```

```{file-write}
:id: add-static-entry
:title: Add the static entry to shop/pyproject.toml
:path: shop/pyproject.toml
:mode: append


[[tool.muru.static]]
path = "/static/"
dir = "shop/static"
```

```{execute}
:id: start-edge-static
:session: server
:wait: 3s
muructl run shop --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

The startup lines include `muru: static /static/ from shop/shop/static`.
Open the shop once more, and look at the stylesheet's access log line.

```{url-open}
:title: Open the shop again
:when: web_proxy
:url: {{ jupyter_url }}proxy/{{ app_port }}/
:pane: shop
:area: viewer
```

```{url-open}
:title: Open the shop again
:when: not web_proxy
:url: http://127.0.0.1:{{ app_port }}/
:pane: shop
:area: viewer
```

`200 GET /static/shop.css` now ends `reason=static` and names no
worker: the edge answered from the directory, with an `ETag` and
`Last-Modified`, and the workers never saw the request. A path under
`/static/` that has no file still reaches Flask. `muructl logs
--access` reads the run's access log from the other terminal, which
the check below uses. It is run in `shop`, the project's directory,
which is how it finds this run rather than a Muru daemon of your own
that may be running.

```{execute}
:id: read-access-log
:session: client
:wait: prompt
curl -s -o /dev/null http://127.0.0.1:{{ app_port }}/static/shop.css; (cd shop && muructl logs --access --lines 1)
```

```{verify}
:id: edge-serves-static
:label: The edge serves the stylesheet
:substrate: shell
:trigger: after:read-access-log
curl -s -o /dev/null --max-time 2 http://127.0.0.1:{{ app_port }}/static/shop.css; out=$(cd shop && muructl logs --access --lines 1 2>&1); printf '%s\n' "$out" | grep 'GET /static/shop.css' | grep -o 'reason=static' || { printf '%s\n' "${out:-muructl logs --access found no access log line. Check that the shop is running in the terminal on the left.}"; exit 1; }
```

Under the daemon the same entry serves the directory from each
release's own source, with cache headers if the entry asks for them.
A static route in the daemon's configuration, which **What you would
have put nginx in front for** in the Meet Muru collection shows,
serves a directory that is not part of an application.

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
for i in 1 2 3 4 5; do curl -s -o /dev/null --max-time 1 http://127.0.0.1:{{ app_port }}/ || { echo "The shop has stopped."; exit 0; }; sleep 1; done; echo "The shop still answers on port {{ app_port }}. Stop it with the action above."; exit 1
```
