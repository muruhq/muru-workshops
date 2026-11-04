---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

A `breakpoint()` in a request is the quickest way to find out what the
code is about to do with it. Under a server with worker processes it
is also the quickest way to lose a worker, since pdb has no terminal
to read from. This workshop serves a small shop whose checkout stops
at a breakpoint, and finds out what `muructl run` does with it: the
worker waits for a debugger, the timeouts stand aside, and
`muructl debug attach` opens pdb on the request from the other
terminal. Along the way it compares with `flask run`, `runserver`,
gunicorn and mod_wsgi.

The shop, `checkout.py`, is already in your workspace. Nothing you do
here needs you to type code.

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
The shop is served on port {{ app_port }}. If something else already
uses that port, open the Variables dialog from the gear button in the
header of this panel and change `app_port`. Every command in the
workshop uses the new value.
```
