# Reload and HTTPS for a real project

The defaults of `--reload` and `--https` suit a project of Python
files served on `localhost`. A real project has templates and data
files, writes files of its own, and is reached under other names.

## What counts as a change

```mermaid
flowchart LR
    F[a file changes] --> W{under a watched directory?}
    W -->|no| N[nothing]
    W -->|yes| I{matches an include?}
    I -->|no| N
    I -->|yes| X{matches an exclude?}
    X -->|yes| N
    X -->|no| R[a new release]
```

- gunicorn's `--reload` watches the Python modules the application
  imported, and `--reload-extra-file` adds files or glob patterns,
  such as templates.

- uvicorn's `--reload` watches `*.py` under the current directory;
  `--reload-dir` changes the directories, and `--reload-include` and
  `--reload-exclude` the patterns, which need the `watchfiles` package.

- Granian's `--reload` watches the working directory, or the paths
  `--reload-paths` names, for a change to any file, not only Python,
  that `watchfiles` does not ignore by default: version control and
  virtualenv directories, `__pycache__` and compiled `.pyc` files
  among them. `--reload-ignore-dirs`, `--reload-ignore-patterns`
  (regular expressions) and `--reload-ignore-paths` add to what it
  ignores.

- A `muructl run` development run watches `**/*.py` under the
  project's directory without being asked; `--no-reload` turns that
  off for a run. `--reload-dir` names other directories to watch,
  `--reload-include` the files that count as source and
  `--reload-exclude` files that never do, each repeatable, with paths
  relative to the watched directory.

`--reload-include` adds to the default rather than replacing it, so a
project that adds `**/*.html` still reloads on a changed module. An
include pattern wide enough to catch a file the application itself
writes, such as a cache or a record of the last visit, makes every
request that writes it start a new release, which is what
`--reload-exclude` is for. An exclude wins over an include, so
`--reload-exclude '**/*.py'` watches the included patterns alone. The
startup line `muru: watching ...` names the directories and patterns
watched.

## A request in flight

Under `muructl run`, a reload starts a new release beside the old one
and switches to it once it is ready. A request the old release had
already started finishes there, with the old code, and only new
requests reach the new one. gunicorn's reload replaces its workers
and uvicorn's the whole server process, and requests that arrive
meanwhile wait for one to be ready.

## HTTPS in development

`--https` serves HTTPS beside HTTP, on `--https-port`. With
[mkcert](https://mkcert.dev) installed and its CA trusted, Muru asks
it for a certificate that browsers trust; without it, Muru makes a
self-signed one. Either way the certificate is kept in Muru's cache
directory and reused while its names stay the same.

- `--host NAME` adds a name to the development certificate beside
  `localhost`, `127.0.0.1` and `::1`, for a project reached as
  `menu.test` through a hosts file entry or a tunnel. A new name makes
  a new certificate.

- `--https-only` answers plain HTTP with a redirect to the same path
  over HTTPS, to test what a site does behind a redirect from `http:`.

- `--tls-cert` and `--tls-key` serve a certificate of your own instead,
  such as one from your organisation's CA, or from a tool that makes a
  local CA for tests, as `trustme` does. A relative path is read from
  the project's directory.

gunicorn takes `--certfile` and `--keyfile` and uvicorn
`--ssl-certfile` and `--ssl-keyfile`, both for a certificate you make
yourself; neither makes one, and neither redirects HTTP to HTTPS.

## Into the project

Each flag above says how a checkout of the project is served rather
than what the application is, and each has a key of the same name,
in snake case, in a `[tool.muru.run]` table of the project's
`pyproject.toml` (a `[run]` table at the top level of a `muru.toml`),
beside the `[tool.muru]` table that names the entrypoint and the
workers.

```toml
[tool.muru]
entrypoint = "app:application"

[tool.muru.run]
port = 8080
https_port = 8443
https_only = true
hosts = ["menu.test"]
tls_cert = "certs/server.pem"
tls_key = "certs/server.key"
reload_include = ["**/*.html", "**/*.json"]
reload_exclude = ["data/last-visit.json"]
```

With the table, `muructl run` on its own is the whole command, and
everyone who checks the project out serves it the same way. `reload`
is a key too, `true` by default in development mode and `false` to turn
reloading off for good. A flag given as well wins over the table for
that run, and a boolean the table turns on has a flag to turn it off:
`--no-reload`, `--no-https`, `--no-https-only`. A `muru.local.toml`
beside `pyproject.toml`, never committed, holds a `[run]` table with the
same keys for one machine alone, between the flags and the project's
table.

The daemon ignores the run table: `muructl deploy` takes `[tool.muru]`
and nothing of how a laptop served the project. `muructl run
--print-config` prints the settings a run would use and where each came
from, the run table's among them, and `muructl render` writes the
release a deploy would make, from `[tool.muru]` alone.

gunicorn's `gunicorn.conf.py` holds every setting, how the server runs
included, and uvicorn and Granian have no file of their own: a project
that wants its flags kept writes a script or a `Makefile` target.
