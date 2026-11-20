---
title: Muru in one picture
requires: [verify:server-up]
---

# Muru in one picture

Muru gives each job to a different kind of process: an **edge** in
Rust that talks to clients, a **host** that imports your code once, and
**workers** forked from the host that run it. Open the second
document, which shows how they fit together, and how `muructl run` runs
them on your machine while you develop.

```{file-open}
:title: Open the document on how Muru serves an application
:path: docs/muru-processes.md
:factory: Markdown Preview
:area: viewer
```

The application is one WSGI function in `hello.py`. Each response
says which worker process served it and which process it was forked
from. Two paths fail on purpose, which a later page uses.

```{file-open}
:title: Open hello.py
:path: hello.py
:area: viewer
```

Start the application in the terminal on the left. The argument is
`module:callable`, as for most WSGI servers.

```{execute}
:id: start-server
:session: server
:wait: 3s
muructl run hello:application --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

Read what it printed, from the top. The lines starting `muru.host` are
the host: it imported `hello.py`, found the callable was a WSGI
application, and started one worker. The lines starting `muru:` are
`muructl` itself, saying where it serves, with how many workers and
threads, and what development mode does differently. The lines after
that name the development dashboard, which the next workshop explains,
the run's process id and admin socket, the directory `muructl`'s own
commands reach this run from, and the directory the run watches so a
saved change starts a new release, which workshop 3 shows.

```{verify}
:id: server-up
:label: The application answers on port {{ app_port }}
:substrate: shell
:trigger: after:start-server
curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "is in use by", followed by a
program and its process id, means another program has the port it
names, {{ app_port }} or the dashboard's {{ dashboard_port }}: change
`app_port` or `dashboard_port` from the gear button in the header of
this panel, then start the server again. If it says nothing at all
yet, give it a few seconds and click Check.
```
