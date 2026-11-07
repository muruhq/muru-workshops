---
title: Welcome
requires: [verify:muructl-installed]
---

# Welcome

How close to production can a development run be? This workshop
looks at two things that decide it. The first is what happens when
you save a change: what the server replaces, whether requests are
refused while it does, and what is left serving when the change does
not even import. The second is HTTPS, which you need on your laptop to
test HTTP/2 and anything that behaves differently behind TLS.

The application, `greeting.py`, is already in your workspace. Its
responses say which release served them and how the request arrived.
Nothing you do here needs you to type code: every change to it comes
from an action.

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
:title: If port {{ app_port }} or {{ https_port }} is taken on your machine
The application is served over HTTP on port {{ app_port }}, and over
HTTPS on port {{ https_port }} on the last page. If something else
already uses either of them, open the Variables dialog from the gear
button in the header of this panel and change `app_port` or
`https_port`. Every command in the workshop uses the new values.
```
