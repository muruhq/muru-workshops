---
title: One site, two interfaces
requires: [verify:site-up]
---

# One site, two interfaces

Open the document on serving WSGI and ASGI in one site. It covers what
gunicorn, uvicorn, Granian and mod_wsgi each take, the two servers and
the proxy that usually follow, and what Muru does instead.

```{file-open}
:title: Open the document on WSGI and ASGI in one site
:path: docs/two-interfaces.md
:factory: Markdown Preview
:area: viewer
```

The site's `pyproject.toml` says what to serve: Flask's `app` in
`web.py` as the default mount, at `/`, and FastAPI's `app` in `api.py`
as a mount named `api`, at `/api`, from two worker processes.

```{file-open}
:title: Open pyproject.toml
:path: pyproject.toml
:area: viewer
```

The two applications are ordinary Flask and FastAPI. Neither knows the
other is there, and neither knows about Muru.

```{file-open}
:title: Open web.py
:path: web.py
:area: viewer
```

```{file-open}
:title: Open api.py
:path: api.py
:area: viewer
```

Start the site in the terminal on the left. With no entrypoint on the
command line, `muructl run` reads the `[tool.muru]` table.

```{execute}
:id: start-site
:session: server
:wait: 5s
muructl run --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

The first line, `muru: using [tool.muru] from ./pyproject.toml`, says
where the settings came from. Then the host preloaded `web:app`, found
it to be WSGI and the `api` mount's `api:app` to be ASGI, and forked
two workers, each holding both applications from the same preload.

The serving line says what each worker has for them: `2 workers of 4
threads` for Flask, `and an event loop of concurrency 1000` for
FastAPI. The line after it says where the mount is, `mount api serves
/api from api:app`, and the dashboard line gives its address, which
a later page opens.

```{verify}
:id: site-up
:label: The site answers on port {{ app_port }}
:substrate: shell
:trigger: after:start-site
curl -sS --max-time 2 -o /dev/null -w '%{http_code}\n' http://127.0.0.1:{{ app_port }}/ | grep '^200$'
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "is in use by", followed by a
program and its process id, means another program has port
{{ app_port }}: change `app_port` from the gear button in the header
of this panel, then start the site again. An error naming the
dashboard's address means the same for port {{ dashboard_port }}:
change `dashboard_port` and start the site again. Importing FastAPI
takes a moment; if
nothing is printed yet, give it a few seconds and click Check.
```
