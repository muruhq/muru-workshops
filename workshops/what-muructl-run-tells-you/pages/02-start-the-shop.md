---
title: Start the shop
requires: [verify:shop-up]
---

# Start the shop

Each server reports what it is doing differently. Open the document
that compares what gunicorn, uvicorn and `muructl run` report while
you develop, and keep it open as you go.

```{file-open}
:title: Open the document on where a server's output goes
:path: docs/where-output-goes.md
:factory: Markdown Preview
:area: viewer
```

The shop is an ordinary Flask application. One setting in it,
`PROPAGATE_EXCEPTIONS`, matters on a later page; the comment above it
says why.

```{file-open}
:title: Open shop.py
:path: shop.py
:area: viewer
```

Start it in the terminal on the left, with two worker processes so
you can see output from more than one.

```{execute}
:id: start-shop
:session: server
:wait: 3s
muructl run shop:app --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --processes 2
```

Read the startup lines from the top:

- `muru: runtime library ... from ...` is `muructl` supplying `muru`,
  the part of Muru that runs inside your application's Python. It is
  not installed beside Flask: `muructl` keeps the copy matching its own
  version in its cache and puts it on your application's path. The
  first time it is needed, a line before this one says where it came
  from: fetched from PyPI, or unpacked from a directory of wheels.

- `muru.host[...]: preloaded shop:app` is the host, which imported
  `shop.py` once. The number in brackets is the host's process id.

- `is served as WSGI` says what the host found `shop:app` to be. Muru
  serves ASGI applications too, and works out which it has.

- `worker 0 started` and `worker 0 ... is ready` come in pairs, one
  for each worker forked from the host.

- `muru: serving shop:app on ...` is `muructl` itself, with the
  address, the workers and the threads each has.

- `muru: development mode: ...` lists what a development run does
  differently from the daemon, which is how Muru runs in production:
  error pages show tracebacks, nothing is kept between runs, the run
  reloads when a source file changes, and only loopback is served.

- `muru: dashboard on ...` is where the dashboard is, which the last
  page opens.

- `muru: pid ...` is the process id of `muructl run` itself, written
  to a file so that a script which started the run in the background
  can stop it.

- `muru: admin socket ...` is where `muructl`'s own commands, such as
  `muructl status` and `muructl logs --access`, reach this run from
  another terminal. It and the pid file are in a directory of the
  run's own, named after the run's instance ID.

- `muru: muructl commands run from ... reach this run` names the
  directory to run those commands from. With several runs on one
  machine, or a Muru daemon of your own, that is how a command finds
  this one. The terminal on the right is already there.

- `muru: watching ... for changes to **/*.py` names the directory the
  run watches for a change to reload on. Nothing in this workshop
  changes a file, so it stays quiet.

```{verify}
:id: shop-up
:label: The shop answers on port {{ app_port }}
:substrate: shell
:trigger: after:start-shop
curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "is in use by", followed by a
program and its process id, means another program has port
{{ app_port }}: change `app_port` from the gear button in the header
of this panel, then start the shop again. An error naming the
dashboard's address means the same for port {{ dashboard_port }}:
change `dashboard_port` and start the shop again. If nothing is
printed yet, give it a few seconds and click Check.
```
