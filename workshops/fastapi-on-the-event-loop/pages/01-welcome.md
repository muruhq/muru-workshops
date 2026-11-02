---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

A FastAPI application runs on an event loop, and so does every
request it serves, until some code decides otherwise. This workshop
serves a small FastAPI price service under `muructl run` and finds out
what runs where: the lifespan, `async def` and plain `def` path
operations, work handed to a thread, and a call that blocks the loop.
Along the way it compares with uvicorn and gunicorn.

The service, `main.py`, is already in your workspace with the prices
it loads and two helpers that send requests. Nothing you do here needs
you to type code.

This workshop has an environment of its own with `muru`, `muructl` and
FastAPI installed, at Muru release 0.1.0a15. Create it first; it takes
a minute.

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
