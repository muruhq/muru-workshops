---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

How many processes and threads should an application have? Every
server asks you to choose, gunicorn with `--workers` and `--threads`,
mod_wsgi with `processes` and `threads`, Muru with `--processes` and
`--threads`, and the right answer depends on what your views spend
their time doing. This workshop measures it, with a view that waits
and a view that computes, under three settings, and reads the answer
from what Muru's edge records for each request.

The application, `work.py`, and the load script, `load.py`, are
already in your workspace. Nothing you do here needs you to type code.

This workshop has an environment of its own with `muructl` installed, at
release 0.1.0a20. Create it first; it takes a minute.

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
in the header of this panel and change `app_port`. Every command in the
workshop uses the new value.
```
