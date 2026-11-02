---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

Muru serves Python WSGI and ASGI applications. This workshop shows
where it fits beside the servers you may know already: Apache with
mod_wsgi, gunicorn, uvicorn and Granian. You read how each of them
divides the work of serving an application, then serve a small
application under Muru and look at the processes it uses instead.

The comparisons are short documents with diagrams, which open in the
area above the terminals. The application, `hello.py`, is already in
your workspace, and nothing you do here needs you to type code.

Muru comes in two parts: `muructl`, the command, and `muru`, the
runtime library that runs inside your application's Python. This
workshop has an environment of its own with both installed, at release
0.1.0a15. Create it first; it takes a minute.

```{environment-create}
:title: Create the workshop environment
```

```{hint}
:title: Is it safe to click again?
Yes. Once the environment exists, the action reports that it is ready
and does nothing else.
```

The environment is on the `PATH` of both terminals below, so `muructl`
is ready to run. Check the version in the terminal on the right.

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
in the header of this panel and change `app_port`. Every command in the
workshop uses the new value.
```
