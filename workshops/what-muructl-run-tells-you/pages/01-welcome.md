---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

`muructl run` is how you serve an application under Muru while you
develop. This workshop is about what it tells you as it runs: what
each startup line means, what the access log records, where your own
code's output goes, what a failing request looks like in a browser and
to an API client, and what the dashboard shows. Along the way it puts
gunicorn's and uvicorn's way of reporting the same things beside
Muru's.

The application is a small Flask shop, `shop.py`, already in your
workspace. Nothing you do here needs you to type code.

This workshop has an environment of its own with `muructl` and Flask
installed, at Muru release 0.1.0a17. Create it first; it takes a minute.

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
:title: If port {{ app_port }} or {{ dashboard_port }} is taken on your machine
The application is served on port {{ app_port }} and its dashboard on
port {{ dashboard_port }}. If something else already uses either of
them, open the Variables dialog from the gear button in the header of
this panel and change `app_port` or `dashboard_port`. Every command in
the workshop uses the new values.
```
