---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

Sooner or later a request waits for something that never comes, or
gets stuck in a call that never returns. This workshop serves a small
accounts service with two such requests and finds out what Muru does
about each: which timeout catches it, what the client gets, what else
is held up, and how the log points at the code to fix. Along the way
it compares with gunicorn, uvicorn and mod_wsgi.

The service, `accounts.py`, and two helpers that send requests are
already in your workspace. Nothing you do here needs you to type code.

This workshop has an environment of its own with `muructl` installed, at
release 0.1.0a17. Create it first; it takes a minute.

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
The service is served on port {{ app_port }}. If something else
already uses that port, open the Variables dialog from the gear button
in the header of this panel and change `app_port`. Every command in
the workshop uses the new value.
```
