---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

Muru calls a project's hooks at seven points between importing the
application and a worker exiting. Knowing which process each runs in,
and when, is what lets you put a connection, a thread or a flush in the
right one. This workshop runs a hooks module that has all seven, each
printing where it ran, and reads the order from the terminal as the
workers start, are replaced and stop. Along the way it compares with
gunicorn's server hooks.

The hooks module, `hooks.py`, a WSGI application and an ASGI one are
already in your workspace. Nothing you do here needs you to type code.

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
The application is served on port {{ app_port }}. If something else
already uses that port, open the Variables dialog from the gear button
in the header of this panel and change `app_port`. Every command in
the workshop uses the new value.
```
