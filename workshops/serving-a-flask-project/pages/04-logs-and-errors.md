---
title: Logs and errors
requires: [verify:info-logged, verify:muru-error-page]
---

# Logs and errors

The factory logs `application built in process N` and `/pool` logs
each time it is asked for, both at `INFO` through `app.logger`. The
terminal on the left has neither. The section of the document on
logging says why: Muru sets the root logger to `WARNING` unless the
project asks for more, and `app.logger` follows it.

Stop the shop, set the level in the project's table, and start it
again.

```{interrupt}
:id: stop-for-logging
:session: server
```

```{file-write}
:id: add-logging
:title: Set the logging level in shop/pyproject.toml
:path: shop/pyproject.toml
:mode: append
:open: true
:area: viewer


[tool.muru.logging.python]
level = "INFO"
```

```{execute}
:id: start-with-logging
:session: server
:wait: 3s
muructl run shop --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

Each worker now logs `INFO in __init__: application built in process
N`, in Flask's own format, tagged `muru.worker[0]:` and
`muru.worker[1]:`: one build per worker. Ask for the pool once more.

```{execute}
:id: ask-pool-logged
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/pool; echo
```

```{verify}
:id: info-logged
:label: The logging level is set in the table
:substrate: shell
:trigger: after:ask-pool-logged
grep -q '^level = "INFO"' shop/pyproject.toml && echo 'The table sets level = "INFO".' || { echo "shop/pyproject.toml has no logging level yet. Add it with the action above."; exit 1; }
```

The line `INFO in views: pool asked for in process N` appears above the
request's access log line.

Now a view that raises. `/stock` raises `RuntimeError` for a negative
stock count.

```{execute}
:id: ask-stock
:session: client
:wait: prompt
curl -s -w '\n%{http_code}\n' http://127.0.0.1:{{ app_port }}/stock
```

A 500 with Flask's own short page. Flask logged the traceback, which
the terminal on the left shows tagged with the worker, and the access
log line has no `reason=`, since Muru saw an ordinary response. The
document's last section says how to let the exception reach Muru: the
factory reads Flask settings from `FLASK_` variables, so the table's
`env` can set `FLASK_PROPAGATE_EXCEPTIONS`. Stop the shop, add it, and
start the shop again.

```{interrupt}
:id: stop-for-errors
:session: server
```

```{editor-insert}
:id: add-propagate
:title: Set FLASK_PROPAGATE_EXCEPTIONS in the table's env
:path: shop/pyproject.toml
:match: SHOP_DATABASE
FLASK_PROPAGATE_EXCEPTIONS = "true"
```

```{execute}
:id: start-propagating
:session: server
:wait: 3s
muructl run shop --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

Load `/stock` in the shop's pane.

```{url-open}
:title: Open /stock in the shop's pane
:when: web_proxy
:url: {{ jupyter_url }}proxy/{{ app_port }}/stock
:pane: shop
:area: viewer
```

```{url-open}
:title: Open /stock in the shop's pane
:when: not web_proxy
:url: http://127.0.0.1:{{ app_port }}/stock
:pane: shop
:area: viewer
```

```{verify}
:id: muru-error-page
:label: Muru answers for the failing view
:substrate: shell
:trigger: after:start-propagating
out=$(curl -s --max-time 2 -H 'Accept: text/html' http://127.0.0.1:{{ app_port }}/stock); printf '%s\n' "$out" | grep -q 'the stock count for Teapot is negative' && echo "Muru's error page shows the traceback." || { echo "The error page has no traceback. Check that the table's env sets FLASK_PROPAGATE_EXCEPTIONS and that the shop was started again."; exit 1; }
```

The pane shows Muru's development error page, with the traceback of
the view down to the `raise`, and the access log line ends
`reason=app_error`. Nothing in the project's code changed: the setting
came from the table, through the environment, to the factory.
