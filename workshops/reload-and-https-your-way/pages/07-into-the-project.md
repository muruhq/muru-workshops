---
title: Into the project
requires: [quiz:flag-or-table, verify:served-from-table, verify:project-stopped-table]
---

# Into the project

The last command line carried five flags, and the reload ones before
it three more. Everyone who checks the project out would have to type
them, and so would you next week. Read the document's last section:
the flags of `muructl run` that say how a checkout is served have keys
of the same names in a `[tool.muru.run]` table, beside the
`[tool.muru]` table that says what the application is.

The project has no `pyproject.toml` yet. Write one with both tables:
the entrypoint, and every flag of this workshop as a key.

```{file-write}
:id: write-table
:title: Write menu/pyproject.toml with the run table
:path: menu/pyproject.toml
:open: true
:area: viewer
[project]
name = "menu"
version = "0.1.0"

# What the application is.
[tool.muru]
entrypoint = "app:application"

# How a checkout of it is served by muructl run; the daemon ignores
# this table.
[tool.muru.run]
port = {{ app_port }}
https_port = {{ https_port }}
https_only = true
hosts = ["menu.test"]
tls_cert = "certs/server.pem"
tls_key = "certs/server.key"
reload_include = ["**/*.html", "**/*.json"]
reload_exclude = ["data/last-visit.json"]
```

`muructl run` reads both tables from the project's directory, so the
command is now the directory alone.

```{execute}
:id: start-from-table
:session: server
:wait: 4s
muructl run menu
```

The first line, `muru: using [tool.muru] from menu/pyproject.toml`,
says where the settings came from, and the rest are the lines the flags
gave: HTTPS with HTTP redirecting to it, the certificate from
`certs/server.pem`, and the watched patterns with their exception.

```{execute}
:id: ask-from-table
:session: client
:wait: prompt
curl -s --cacert menu/certs/client.pem --resolve menu.test:{{ https_port }}:127.0.0.1 https://menu.test:{{ https_port }}/
```

```{verify}
:id: served-from-table
:label: The project is served from its run table
:substrate: shell
:trigger: after:ask-from-table
grep -q '^\[tool.muru.run\]' menu/pyproject.toml || { echo "menu/pyproject.toml has no [tool.muru.run] table yet. Write it with the action above."; exit 1; }; out=$(curl -sS --max-time 2 --cacert menu/certs/client.pem --resolve menu.test:{{ https_port }}:127.0.0.1 https://menu.test:{{ https_port }}/ 2>&1); printf '%s\n' "$out" | grep -o 'over https with HTTP/2.0' || { printf '%s\n' "${out:-Nothing answers on port {{ https_port }}.}"; exit 1; }
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "Address already in use" means
another program has port {{ app_port }} or {{ https_port }}: change
`app_port` or `https_port` from the gear button in the header of this
panel, write the table again so it has the new ports, and start the
project again.
```

A flag still wins over the table for one run, so `muructl run menu
--no-https-only` would serve plain HTTP again without touching the
file, and a key the table does not know stops the run with the list of
keys it does.

```{quiz}
:id: flag-or-table
question: A teammate's laptop already has port {{ app_port }} taken. Where does their port belong?
options:
  - { text: "In a `muru.local.toml` beside `pyproject.toml`, in a `[run]` table of its own", correct: true }
  - { text: "In `[tool.muru.run]`, changing `port` for everyone", explanation: "The table is committed with the project, so that would move every checkout to their port." }
  - { text: "In `[tool.muru]`, since the port is a setting of the application", explanation: "The port says how a checkout is served, not what the application is; `[tool.muru]` has no key for it." }
explanation: "`muru.local.toml` holds a `[run]` table with the same keys for one machine alone, never committed, and wins over the project's table as a flag wins over both. The first workshop of this collection shows it."
```

`--print-config` prints the settings a run would use, each with where
it came from, without serving anything. Stop the project and look at
the `[run]` table it prints.

```{interrupt}
:id: stop-from-table
:session: server
```

```{execute}
:id: print-config
:session: client
:wait: prompt
muructl run menu --print-config | sed -n '/^\[run\]/,/^$/p'
```

Every key the table sets is marked `[tool.muru.run] in
menu/pyproject.toml`, and the rest are defaults. `https` stays `false`:
it is the mode that serves HTTPS beside HTTP, and `https_only` the one
the table chose.

The daemon never reads the run table: `muructl deploy` of the project
takes `[tool.muru]` and ignores it. `muructl render` writes the release
a deploy would make, in the daemon's format, without needing a daemon.

```{execute}
:id: render-release
:session: client
:wait: prompt
muructl render menu menu
```

Below the comments, the release has its source and its entrypoint and
nothing else: no port, no certificate and no reload patterns.

```{verify}
:id: project-stopped-table
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-from-table
for i in 1 2 3 4 5; do curl -s -o /dev/null --max-time 1 http://127.0.0.1:{{ app_port }}/ || { echo "The project has stopped."; exit 0; }; sleep 1; done; echo "The project still answers on port {{ app_port }}. Stop it with the action above."; exit 1
```
