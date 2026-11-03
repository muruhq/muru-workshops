---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

A canary gives a new release a small share of the real traffic
before the rest, and takes it out again if it does worse than the
release that serves. This workshop runs one on the Muru daemon twice
while a steady stream of requests runs: once for a release that is
fine, which is promoted, and once for a release with a bug, which
rolls itself back.

The three versions of the application are in `releases/v1`,
`releases/v2` and `releases/v3` in your workspace. Nothing you do here
needs you to type code.

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
