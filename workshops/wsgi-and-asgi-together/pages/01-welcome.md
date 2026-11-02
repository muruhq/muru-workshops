---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

A site often has two kinds of Python application: a WSGI one for its
pages and an ASGI one for an API or WebSockets. Most servers take one
or the other, so the site ends up with two servers and a proxy in
front. This workshop serves both from one `muructl run`, from the same
worker processes.

The site, a Flask application in `web.py` and a FastAPI application in
`api.py`, is already in your workspace with the `pyproject.toml` that
ties them together. Nothing you do here needs you to type code.

This workshop has an environment of its own with `muru`, `muructl`,
Flask, FastAPI and the `websockets` client installed, at Muru release
0.1.0a15. Create it first; it takes a minute.

```{environment-create}
:title: Create the workshop environment
```

The environment is on the `PATH` of both terminals below. Check the
version of `muructl` in the terminal on the right.

```{execute}
:id: muructl-version
:session: client
:wait: prompt
muructl --version
```

```{verify}
:id: muructl-installed
:label: muructl is installed
:substrate: shell
:trigger: after:muructl-version
muructl --version
```

```{hint}
:title: If port {{ app_port }} or {{ dashboard_port }} is taken on your machine
The site is served on port {{ app_port }} and its dashboard on port
{{ dashboard_port }}. If something else already uses either of them,
open the Variables dialog from the gear button in the header of this
panel and change `app_port` or `dashboard_port`. Every command in the
workshop uses the new value.
```
