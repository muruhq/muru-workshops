---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

A Django project comes with `wsgi.py` and `asgi.py`, ready for any
server, and with habits formed under `manage.py runserver`. This
workshop serves a Django project under `muructl run`, first from
`wsgi.py` and then from `asgi.py`, and works through what is different
once `runserver` is not the server: who serves the static files, who
answers when a view raises, and where each kind of view runs.

The project, `mysite` with a `catalog` app of products, is in the
`mysite` directory of your workspace. Nothing you do here needs you to
type code.

This workshop has an environment of its own with `muructl` and Django
installed, at Muru release 0.1.0a20. Create it first; it takes a minute.

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
:title: If port {{ app_port }} is taken on your machine
The site is served on port {{ app_port }}. If something else already
uses that port, open the Variables dialog from the gear button in the
header of this panel and change `app_port`. Every command in the
workshop uses the new value.
```
