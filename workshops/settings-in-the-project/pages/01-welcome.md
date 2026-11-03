---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

Everyone who works on a project should serve it the same way, and the
way to make sure of that is to write its server settings down with it.
This workshop starts a project under a long `muructl run` command line
and moves the settings into the project, into a `[tool.muru]` table in
its `pyproject.toml`. Along the way it puts where gunicorn, uvicorn,
Granian and mod_wsgi keep their settings beside Muru's.

The project, a small WSGI application in the `notes` directory of your
workspace, is already there. Nothing you do here needs you to type
code.

This workshop has an environment of its own with `muructl` installed, at
release 0.1.0a16. Create it first; it takes a minute.

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
The project is served on port {{ app_port }}. If something else
already uses that port, open the Variables dialog from the gear button
in the header of this panel and change `app_port`. Every command in
the workshop uses the new value.
```
