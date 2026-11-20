---
title: Serve wsgi.py
requires: [verify:site-up]
---

# Serve wsgi.py

Open the document on a Django project and its server. Read the first
two sections, on who serves a project and what importing it once
means; the rest comes up on later pages.

```{file-open}
:title: Open the document on a Django project and its server
:path: docs/django-and-muru.md
:factory: Markdown Preview
:area: viewer
```

The project's `wsgi.py` is the one `startproject` wrote, and its
`pyproject.toml` names it in a `[tool.muru]` table, with two worker
processes.

```{file-open}
:title: Open mysite/mysite/wsgi.py
:path: mysite/mysite/wsgi.py
:area: viewer
```

```{file-open}
:title: Open mysite/pyproject.toml
:path: mysite/pyproject.toml
:area: viewer
```

The `catalog` app's migrations create a table of products and add
three. Run them, as you would for any new checkout of a project.

```{execute}
:id: migrate
:session: client
:wait: prompt
python mysite/manage.py migrate
```

Now start the site in the terminal on the left. A development run
reloads when a source file changes, so nothing has to be asked for.

```{execute}
:id: start-site
:session: server
:wait: 4s
muructl run mysite --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

`preloaded mysite.wsgi:application in ...` is the host importing
`wsgi.py` once, which ran `django.setup()`: the settings, the apps and
their models. Nothing in that left a connection open, so the two
workers were forked from it. `watching .../mysite for changes` is the
run watching the project's directory, as `runserver` does; `--no-reload`
would turn that off.

The front page is a plain `def` view that lists the products as JSON,
with the worker and thread that ran it.

```{execute}
:id: ask-index
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/; echo
```

```{verify}
:id: site-up
:label: The site lists its products
:substrate: shell
:trigger: after:ask-index
out=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/); printf '%s\n' "$out" | grep -q '"Teapot"' && echo "The site lists its products." || { printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}" | tail -n 5; exit 1; }
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "is in use by", followed by a
program and its process id, means another program has the port it
names, {{ app_port }} or the dashboard's {{ dashboard_port }}: change
`app_port` or `dashboard_port` from the gear button in the header of
this panel, then start the site again. "no such table:
catalog_product" means the migrations have not run: run them with the
action above.
```
