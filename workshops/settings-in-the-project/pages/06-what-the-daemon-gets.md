---
title: What the run uses and what the daemon gets
requires: [verify:config-written, verify:project-stopped]
---

# What the run uses and what the daemon gets

With settings in four places, it helps to see where each one came
from. `--print-config` prints the settings a run would use, each with
its source, and exits without serving. Stop the project, then ask what
a run with one process would use.

```{interrupt}
:id: stop-project
:session: server
```

```{execute}
:id: print-settings
:session: client
:wait: prompt
muructl run notes --processes 1 --print-config
```

Every layer is there. `processes` came from the command line, the
entrypoint, `threads` and `hooks` from `[tool.muru]`, `port` from
`muru.local.toml` and `access_log` from `[tool.muru.run]`, and the
rest are defaults. The output has the shape of the project's own
tables, the application's settings and then a `[run]` table, and ends
with the interpreter the run would use.

The application's table is not only for `muructl run`. Deploying the
project directory to Muru's daemon reads the same `[tool.muru]`, so
the settings that serve it on your laptop become its release's
settings. `muructl render` writes the release a deploy of the project
would make, as a file in the daemon's format, and needs no daemon.
Write it beside the project as `muru.daemon.toml`, the name a file in
the daemon's format takes when it is kept with code.

```{execute}
:id: render-release
:session: client
:wait: prompt
muructl render notes notes > muru.daemon.toml
```

```{file-open}
:title: Open muru.daemon.toml
:path: muru.daemon.toml
:area: viewer
```

```{verify}
:id: config-written
:label: The release is written in the daemon's format
:substrate: shell
:trigger: after:render-release
grep '^\[app.notes.release.r1\]' muru.daemon.toml || { echo "muru.daemon.toml has no release in it. Write it with the action above."; exit 1; }
```

Below the comments is one release, `[app.notes.release.r1]`: its
source directory, then what `[tool.muru]` says, the entrypoint, two
processes, two threads and the hooks module, with the soft timeout and
the title in tables of their own. A setting left at its default is not
written. The `--processes 1` was for one run, so it is not here.

Nothing of `[tool.muru.run]` or `muru.local.toml` is in it, and no
listener. How a checkout is served on a laptop is not the daemon's
business, and where the daemon listens is in its own configuration
file. `muructl apply -f muru.daemon.toml` would make the daemon match
the file, and `muructl deploy` makes the same release from the project
directory itself, so `[tool.muru]` is the one place the application's
settings live.

gunicorn has `--print-config` too, which prints the settings its five
sources add up to. Muru's also names the source of each, and `muructl
render` goes a step further: what it writes is what the daemon runs.

```{verify}
:id: project-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-project
for i in 1 2 3 4 5; do curl -s -o /dev/null --max-time 1 http://127.0.0.1:{{ app_port }}/ || { echo "The project has stopped."; exit 0; }; sleep 1; done; echo "The project still answers on port {{ app_port }}. Stop it with the action above."; exit 1
```
