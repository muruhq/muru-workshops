---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

Muru imports your application once and forks its workers from the
process that imported it, as gunicorn does with `--preload`. That
makes workers cheap to start and lets them share memory, and it has a
well-known trap: anything the import opened or started, such as a
database connection or a background thread, does not survive a fork
the way you would expect. This workshop springs the trap on purpose,
then shows what Muru checks before it forks, and how to keep the
preload with a hook.

The application is a small catalogue service, `catalog.py`, that
counts its requests with a metrics client, `metrics.py`. Both are
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
The application is served on port {{ app_port }}. If something else
already uses that port, open the Variables dialog from the gear button
in the header of this panel and change `app_port`. Every command in the
workshop uses the new value.
```
