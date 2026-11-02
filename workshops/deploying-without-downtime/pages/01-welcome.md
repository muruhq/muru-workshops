---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

`muructl run` is for development. For an application that stays up,
Muru has a daemon: you start it once and deploy releases to it. This
workshop deploys a small application, then deploys a new version and
rolls it back while a steady stream of requests runs, and counts how
many go unanswered.

The two versions of the application are in `releases/v1` and
`releases/v2` in your workspace. Nothing you do here needs you to type
code.

This workshop has an environment of its own with `muru` and `muructl`
installed, at release 0.1.0a15. Create it first; it takes a minute.

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
