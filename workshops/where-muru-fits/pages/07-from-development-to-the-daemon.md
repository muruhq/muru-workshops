---
title: From development to the daemon
requires: [verify:server-stopped]
---

# From development to the daemon

Back in the first document, every arrangement served new code by
replacing the processes that ran the old code. Open the last document,
which shows what Muru does instead when it runs as a daemon.

```{file-open}
:title: Open the document on the daemon and releases
:path: docs/releases.md
:factory: Markdown Preview
:area: viewer
```

The settings of a development run carry over to the daemon. `muructl
render` takes the same settings as the run and writes the release they
describe in the configuration the daemon reads, without needing a
daemon.

```{execute}
:id: render-release
:session: client
:wait: prompt
muructl render hello . --entrypoint hello:application --processes 3 --threads 2
```

Below the comments, the `[app.hello.release.r1]` table is the
application as a release: its source directory, its entrypoint, and
the three processes of two threads you asked for. A setting left at
its default is not written, and the daemon finds the Python to run it
on when the file is applied. `muructl apply` takes a file like this
one, and the workshops on the daemon start from there.

You have finished with the server. Stop it in the terminal on the
left.

```{interrupt}
:id: stop-server
:session: server
```

On Ctrl-C, the workers finish the requests they are serving, then
everything exits.

```{verify}
:id: server-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-server
if curl -s -o /dev/null --max-time 2 http://127.0.0.1:{{ app_port }}/; then echo "The server still answers on port {{ app_port }}. Stop it with the action above."; exit 1; fi; echo "The server has stopped."
```
