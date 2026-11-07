---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

A Flask project of any size builds its application in a factory,
reads its settings from the environment, opens a database pool, logs
through `app.logger` and serves a few static files. This workshop
serves such a project under `muructl run` and works through what it
has to tell Muru about each of those, beside what `flask run`,
gunicorn and mod_wsgi would need.

The project, a small shop in the `shop` directory of your workspace,
is already there. Nothing you do here needs you to type code.

This workshop has an environment of its own with `muructl` and Flask
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
The shop is served on port {{ app_port }}. If something else already
uses that port, open the Variables dialog from the gear button in the
header of this panel and change `app_port`. Every command in the
workshop uses the new value.
```
