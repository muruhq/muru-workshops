---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

You may already have an application running under gunicorn, and
want to try Muru without betting the deployment on it. This workshop
runs the gunicorn command you deploy with today, unchanged, under the
Muru daemon, then moves the traffic to Muru's own workers a share at a
time, with gunicorn a rollback away throughout.

It is the one workshop that installs another server, because running
it is the point. The application, an orders service, is in `orders/`
in your workspace. Nothing you do here needs you to type code.

This workshop has an environment of its own with `muructl` installed, at
release 0.1.0a16, and gunicorn 26.2.0. Create it first; it takes a
minute.

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

The daemon this workshop starts is its own, apart from any Muru daemon
you run yourself. It keeps its state, logs and cache under `muru/` in
your workspace, and its sockets in `{{ muru_run_dir }}`, which has to
be a short path because a socket's path is limited to about a hundred
bytes.

```{hint}
:title: If port {{ app_port }} is taken on your machine
The daemon serves on port {{ app_port }}. If something else already
uses that port, open the Variables dialog from the gear button in the
header of this panel and change `app_port`. Every command in the
workshop uses the new value. `muru_run_dir` is there too, should
`{{ muru_run_dir }}` be in use.
```
