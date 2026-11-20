---
title: Name the factory
requires: [quiz:factory-unnamed, verify:shop-up]
---

# Name the factory

Open the document on a Flask project and its server. Read the section
on building the application, which covers what `flask run`, gunicorn,
mod_wsgi and Muru each do with a factory, with a diagram; the rest of
it comes up on later pages.

```{file-open}
:title: Open the document on a Flask project and its server
:path: docs/flask-and-muru.md
:factory: Markdown Preview
:area: viewer
```

The shop's factory, `create_app` in `shop/shop/__init__.py`, reads
Flask settings from the environment, opens the database pool in
`shop/shop/db.py`, and registers the views.

```{file-open}
:title: Open shop/shop/__init__.py
:path: shop/shop/__init__.py
:area: viewer
```

```{file-open}
:title: Open shop/shop/db.py
:path: shop/shop/db.py
:area: viewer
```

The project's table names `shop:create_app` as the entrypoint, with
two worker processes and the database's file in the environment, but
does not say that `create_app` is a factory.

```{file-open}
:title: Open shop/pyproject.toml
:path: shop/pyproject.toml
:area: viewer
```

```{quiz}
:id: factory-unnamed
question: The shop is started as the table stands, with `create_app` not marked as a factory. What happens?
options:
  - { text: "It starts, and every request fails, because each one calls create_app as if it were the application", explanation: "Muru looks at the callable when it loads it. One that takes no arguments cannot take a request's environ and start_response, so it is refused before any request." }
  - { text: "It serves normally: Muru sees that create_app takes no arguments and calls it", explanation: "Muru does not guess. A callable entrypoint is the application unless the project says it is a factory, and one that cannot be an application is refused with a message saying what to set." }
  - { text: "It refuses to start, because create_app takes no arguments and so cannot be a WSGI application", correct: true }
explanation: "A WSGI application takes environ and start_response. When Muru loads an entrypoint that takes no required arguments it refuses it, naming factory = true as the setting to add if it is a factory, rather than letting every request fail."
```

Start the shop in the terminal on the left.

```{execute}
:id: start-unnamed
:session: server
:wait: prompt
muructl run shop --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

It does not start. The host says `cannot load shop:create_app:
RuntimeError: shop:create_app takes no required arguments, so it
cannot be a WSGI application; if it is an application factory, set
factory = true in [tool.muru] ...`, and `muructl run` exits. Mark the
entrypoint as a factory and start it again.

```{editor-insert}
:id: add-factory
:title: Mark the entrypoint as a factory in shop/pyproject.toml
:path: shop/pyproject.toml
:match: processes = 2
factory = true
```

```{execute}
:id: start-factory
:session: server
:wait: 3s
muructl run shop --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

The workers now say `worker 0 serves shop:create_app as WSGI`: each
called the factory and is serving what it returned. Open the shop.

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

```{verify}
:id: shop-up
:label: The shop lists its products
:substrate: shell
:trigger: after:start-factory
out=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/); printf '%s\n' "$out" | grep -q '<li>Teapot</li>' && echo "The shop lists its products." || { printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}" | tail -n 5; exit 1; }
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "is in use by", followed by a
program and its process id, means another program has the port it
names, {{ app_port }} or the dashboard's {{ dashboard_port }}: change
`app_port` or `dashboard_port` from the gear button in the header of
this panel, then start the shop again. `cannot load shop:create_app`
means the table does not yet say `factory = true`: add it with the
action above and start the shop again.
```
