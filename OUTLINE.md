# Muru workshops: outline

The design of this course: how it is organised, what each workshop
covers, its name and format, and the decisions that cut across all of
them. It is a living document. Read it before adding a workshop, and
update it when one is added, changed or dropped: the status table at
the end records where each workshop stands, and the open questions
section shrinks as they are settled. The design is settled here, before
the first workshop of a collection is written.

## What this course is

Guided JupyterLab workshops on [Muru](https://github.com/muruhq/muru),
the routing edge, control plane and Python runtime for WSGI and ASGI
applications. They are for Python web developers who have deployed an
application with Apache and mod_wsgi, gunicorn, uvicorn or Granian, and
want to know what Muru is, why they would use it, and how.

**Meet Muru** (`introduction`, Part I, ten workshops) is the first
collection and is partly an advertisement. It says where Muru fits
among the servers learners know, shows what it does while they develop,
and shows the daemon deploying releases side by side, which is what the
other servers cannot do on their own. Every workshop puts the familiar
server's way briefly beside Muru's, in prose and diagrams. It assumes
the learner knows what a WSGI or ASGI application is and has run one
under some server. It uses only what is in a released version of Muru.

**Developing with muructl run** (`developing`, Part II, eight
workshops) takes the learner's own kind of project, Flask,
Django or FastAPI, through development under `muructl run` in depth.

Later collections go into depth on one area each (see "Later
collections"). They are candidates only until designed here.

Out of scope for the whole course: the WSGI and ASGI protocols
themselves, which
[wsgi-workshops](https://github.com/GrahamDumpleton/wsgi-workshops)
teaches, and developing Muru, which its own repository covers.

## Source material

Everything the workshops say about Muru comes from its documentation,
its source and the installed release, never from memory.

- `reference/muru` is a git submodule of the Muru repository at the
  tag of the release the workshops teach, `v0.1.0-alpha.17` (published
  on PyPI as 0.1.0a17). The user documentation under `docs/tutorials`,
  `docs/explanation` and `docs/howto` is authoritative for released
  behaviour. `CHANGELOG.md` says which release added what, which is how
  to tell whether a feature is released. The design specification
  under `docs/project/design` and the decision records under
  `docs/project/adr` describe intended design: read them for intent,
  and never as evidence that a release behaves a certain way.

- `muructl <command> --help` from the installed release is the
  reference for flags. Try anything against the real release before it
  goes into a page (see `AGENTS.md` for how).

- Part I draws on: `README.md`; `docs/tutorials/first-wsgi-app.md`;
  `docs/explanation/architecture.md`, `process-models.md` and
  `preload.md`; and the how-to pages `daemon.md`, `traffic.md`,
  `rollouts.md`, `static-files.md`, `compression.md`, `file-hints.md`,
  `error-pages.md`, `asgi.md`, `mounts.md`, `starlette-and-fastapi.md`,
  `flask-and-django.md` and `managed-servers.md`.

- Unreleased work is on Muru's `develop` branch. Plan later
  collections from a checkout of it, but write no workshop against it:
  a workshop is written once its features are in a release, and the
  submodule and the pins move to that release first.

- For the other servers, their own documentation:
  [mod_wsgi](https://modwsgi.readthedocs.io/),
  [gunicorn](https://docs.gunicorn.org/) (its design, signals and
  deploying pages), [uvicorn](https://www.uvicorn.org/) (deployment),
  and [Granian](https://github.com/emmett-framework/granian). What a
  workshop says about them is kept to how they arrange processes and
  threads, who talks to clients, and what new code takes, and is
  checked against those pages.

Checked against 0.1.0a8 on CPython 3.14.8, macOS, on 2026-10-27, for
workshop 1:

- `muructl run` is one Rust process holding the edge and the
  controller. It starts a host, `python -m muru.host`, which imports
  the application and forks the workers, whose command line is the
  host's. Under the daemon, `muructl daemon run` is the parent of a
  separate edge (`muructl edge run`) and of each release's host.

- An exception in the application gives 500 with `reason=app_error`
  and the worker carries on. A worker that exits mid-request gives 502
  with `reason=worker_crashed` and a short plain text body naming the
  reason and the request id, and the host forks a replacement. The
  edge did not retry in 0.1.0a8 or 0.1.0a9. From 0.1.0a10 it sends a
  request to another worker when no worker has read it (the worker
  could not be connected to, or closed before the request head reached
  it), marked `retried` in the access log, and never sends again a
  request a worker has read, whatever its method. Workshop 1's POST to
  `/crash` is read before the worker exits, so it is still 502
  `worker_crashed` (checked on 0.1.0a10), and the quiz's explanation
  says when the edge does retry.

- Responses carry `server: muru` and `x-request-id`, and the environ
  carries `muru.request_id`. From 0.1.0a11 the environ carries
  `SERVER_SOFTWARE` as `muru/0.1.0a11`; before that there was none.

- The application answers through jupyter-server-proxy at
  `<jupyter>/proxy/<port>/` and is not refused framing.

- `muructl run` starts the development dashboard on `127.0.0.1:8081`
  by default and says so in a startup line; from 0.1.0a11 the line
  after it names the run's admin socket, and `--reload` adds a
  `watching` line after that. If that port is
  taken it prints `no dashboard: Address already in use` and serves the
  application all the same, so workshop 1 leaves the dashboard at its
  default and needs no variable for its port.

- The dashboard's pages use relative addresses (since 0.1.0a7), and
  every page, script, fragment and `v1/history` answers through
  `<jupyter>/proxy/<port>/`. Since 0.1.0a8 its pages send
  `frame-ancestors 'self'`, so a page of the same origin may frame
  them. Checked in Chrome: in an iframe inside JupyterLab at
  `<jupyter>/proxy/<port>/` the dashboard renders and its fragments
  refresh, while an iframe of `http://127.0.0.1:<port>/` is refused,
  because a different port is a different origin. A dashboard page
  therefore opens in a pane only under `:when: web_proxy`, and in a
  browser tab (no `:pane:`) under `not web_proxy`.

- `muructl run`'s dashboard needs no sign-in. The daemon's dashboard
  needs a session for every page, from a link that `muructl dashboard
  login --url <jupyter>/proxy/<port>/` prints under the proxied
  address, which workshops on the daemon have to provide.

Checked against 0.1.0a8 on CPython 3.14, macOS, on 2026-10-27, for
workshops 2 to 5:

- A dashboard port that is taken does not stop `muructl run`: it
  prints `no dashboard: Address already in use` and serves the
  application all the same.

- Flask (3.1.3) catches an exception in a view and answers with its
  own plain 500 page, so the access log line has no reason and the
  client sees no traceback. The page is Muru's only with
  `PROPAGATE_EXCEPTIONS = True`, which Muru's
  `docs/howto/flask-and-django.md` says since 0.1.0a9 (before, it said
  the page was always Muru's); workshop 2's `shop.py` sets it and says
  why. With it, the edge answers `reason=app_error`, with the
  traceback as HTML, as plain text, or as `application/problem+json`
  for `Accept: application/json`.

- Worker output is tagged `muru.worker[N].stdout:` for standard output
  and `muru.worker[N]:` for standard error, and `logging` arrives
  tagged with no configuration. Without `PYTHONUNBUFFERED`, printed
  lines sit in the worker's buffer; every manifest sets it.

- `--access-log errors` keeps 4xx, 5xx and requests slower than
  `--slow` (1s); the dashboard still has every request.

- `--reload` starts a new release (new host and workers) and switches
  once it is ready: 35 requests at ten a second across a reload, none
  failed. A syntax error gives `reload failed: ... release r2 keeps
  serving`, and the failed attempt uses up r3, so the fix is r4.

- `--https` with `MURU_CACHE_DIR` relative to the workspace writes
  `certs/dev.pem` there. mkcert is used when its authority is found;
  `CAROOT` naming an empty or missing directory makes the certificate
  self-signed even with mkcert installed. `curl --cacert dev.pem`
  trusts the self-signed certificate on macOS curl and on OpenSSL 3.5
  (checked with Python's `ssl`). Over TLS the environ has
  `SERVER_PROTOCOL` `HTTP/2.0`, `wsgi.url_scheme` `https` and
  `muru.tls` with `version` and `alpn`.

- The import check reports a connected UDP socket (`left a connected
  socket (fd 3, to 127.0.0.1:8125)`) and a thread (`left a thread
  running`), falls back under `auto` with `worker N imported ...`
  lines, and under `--preload true` exits with `preload is true, so
  the import check failing stops the release`. Hooks get a `Context`
  with `worker_id` (not `worker`); an exception in `post_fork` stops
  the worker, and after three failed starts the host gives up.

- A view that sleeps 0.1s and one that spends 0.1s of thread CPU time,
  40 requests eight at a time, medians from the JSON access log
  (10 CPUs): one process of one thread, both about 10 a second with
  `queue` about 700ms; one process of eight threads, `/wait` 74 a
  second with no queue, `/compute` 10 a second with no queue and `app`
  about 780ms; two processes of four, `/wait` 74, `/compute` 20 with
  `app` about 390ms.

- gunicorn (master): `--reload` restarts each worker on a change and
  is incompatible with `--preload`; a `SyntaxError` under reload makes
  the worker serve a 500 with the traceback (`util.make_fail_app`).
  No access log unless `--access-logfile`, default format the combined
  log; an exception is logged as `Error handling request`. uvicorn
  (master): `--reload` terminates and restarts the server process; an
  access log by default with no timing; an exception is logged as
  `Exception in ASGI application` and answered with plain text
  `Internal Server Error`; workers are started with multiprocessing's
  spawn.

Checked against 0.1.0a8 on CPython 3.14, macOS, on 2026-10-27, for
workshops 6 to 10:

- `muructl run` with no entrypoint reads `[tool.muru]` and its
  `[tool.muru.mounts.NAME]` tables, and says `using [tool.muru] from
  ./pyproject.toml`. Flask (3.1.3) at `/` sees `SCRIPT_NAME` empty;
  FastAPI (0.162.0) at `/api` sees `root_path` `/api` and the whole
  `path`, on the thread `muru-loop`, in the same worker processes. A
  WSGI thread's name is `Dummy-1`, so the workshop does not show it.
  The access log adds `mount=api`. A page in a pane at
  `<jupyter>/proxy/<port>/` opens a WebSocket to a relative `api/echo`
  and gets the echo (checked in Chrome).

- Checked again against 0.1.0a9. The startup lines add `muru.host[N]:
  mount api: api:app is served as ASGI`, the serving line ends `with 2
  workers of 4 threads and an event loop of concurrency 1000`, and
  `muru: mount api serves /api from api:app` follows it. A WebSocket
  has two access log lines with the same `id=`: `101 GET /api/echo 0B
  1.1ms queue=... app=... mount=api worker=1` when the application
  accepts it, and `101 GET /api/echo 42B 1.8ms websocket=closed
  by=client code=1000 received=1 sent=1 ...` when it closes, the time
  being how long it was open. (In 0.1.0a8 there was one line, written
  on close.) The development dashboard, through jupyter-server-proxy
  too (checked in Chrome), has a "WebSockets open" tile, a WebSockets
  table by endpoint and by socket (opened, open for, release, path,
  client, messages each way, worker, request id) shown only when one
  is open, and a chart of requests in flight and WebSockets open;
  `/v1/websockets` gives the same as JSON with `open` first. The "In
  flight" tile stays at 0 with sockets open, while the workers table's
  in-flight column counts them; the workshop names only the tile.

- With a WebSocket open, Ctrl-C on `muructl run` stops it in about
  0.3 seconds on 0.1.0a9 (`websocket_drain_grace` is 0s by default):
  the client gets close 1001 "the server is going away" and the log
  `websocket=closed by=edge code=1001`. Behind jupyter-server-proxy
  the browser sees 1005 instead, as the proxy does not pass the code
  on, so the page shows only "closed". In 0.1.0a8 the same stop took
  about ten seconds and sent no close frame.

- The daemon with `MURU_STATE_DIR`, `MURU_LOG_DIR`, `MURU_CACHE_DIR`
  and `MURU_CONFIG` relative to the working directory starts, deploys,
  writes each release's log there, and `muructl logs` reads it. A
  deploy without `--python` uses `python3` from the `PATH` the daemon
  was started with, the workshop's environment.

- Under four clients at about 150 requests a second, a deploy and a
  rollback left no request unanswered. A replaced release is
  `retained`, warm until 30 minutes later, with its host and one
  worker; `release list` still shows its configured `2x4`.

- `Muru-Preview` does not reach a held release on a daemon with no
  host or route declared: the request goes to the serving release. With
  a default host and one route applied, the header and the
  `muru_preview` cookie both reach it. The rollouts guide implies the
  first works too; to raise with Muru.

- `rollout canary --steps 10,50 --hold 10s --min-requests 20 --wait`
  promotes a good release in about 21 seconds, and rolls back one that
  fails one request in five during the 10% step within about 2
  seconds (`gate failed at 10%: 5xx rate 14.81% over the limit of
  1.00% (baseline 0.00%)`). `--wait` exits 0 either way.

- In an applied file, every path is relative to the file from
  0.1.0a11 (`source`, `sendfile_roots`, error page files and a static
  route's `static` directory; before that only `source` was, and
  workshop 9 filled in absolute paths with `sed`). Static files get
  `ETag`, `Last-Modified`, `Cache-Control` from `cache`, 304 on
  `If-None-Match`, and the `.gz` beside the file for a gzip client
  (7417 bytes to 383); the access log says `reason=static`. JSON from
  the application is compressed with Brotli (4700 bytes to 190 in the
  trial). `X-Muru-Sendfile` within `sendfile_roots` is sent with static
  headers and ranges (206). An application's own 404 is not replaced by
  `error_pages` without `error_override`. Maintenance answers 503 with
  `Retry-After: 60` and the `503:maintenance` page, and static routes
  go on serving.

- A gunicorn (26.2.0) managed release deploys in under half a second,
  answers through the edge (`server: muru`) with `SERVER_SOFTWARE`
  `gunicorn/26.2.0`, lists as `1 gunicorn`, and runs as gunicorn's
  master and workers under the daemon. A native release of the same
  directory, held, canaried against it and promoted, then a rollback
  to gunicorn, left no request unanswered.

## Meet Muru

### Shape of the Meet Muru collection

**Where it fits (1).** The learner can say how Muru divides the work
of serving an application, and how that differs from the servers they
know.

**Developing with it (2 to 6).** The learner can run their own
application under `muructl run`, read what it reports, develop against
HTTPS and HTTP/2, rely on the import check before fork, size processes
and threads, and serve WSGI and ASGI from one server.

**Running it (7 to 10).** The learner can deploy releases to the
daemon without dropping a request, canary a release and watch it roll
back, let the edge do what nginx used to, and bring an existing
gunicorn deployment under Muru unchanged.

Each workshop is 20 to 30 minutes, six to nine pages including welcome
and finish, about four and a half hours in all. Each is self-contained:
it ships its own application and documents, installs its own
environment, and restates in a sentence anything an earlier workshop
showed.

### The Meet Muru workshops

### 1. `where-muru-fits`: Where Muru fits among Python web servers

Which process talks to clients, which runs your code, and what does
new code take, under the servers you know and under Muru?

The welcome page creates the environment (`muructl`) and runs `muructl --version`. Page 2 opens
`docs/serving-python.md` in the viewer area: Apache with mod_wsgi
(embedded and daemon mode), nginx in front of gunicorn (arbiter,
workers that accept on the shared socket, `sync` and `gthread`,
`--preload`, HUP), uvicorn (event loop per worker, a supervisor that
spawns workers), and Granian (Rust threads and Python in each worker),
each with a Mermaid diagram, ending in a table of who talks to
clients, who runs the code, whether they are the same process, and
what new code takes. A quiz asks in which arrangement a process other
than the one running the code reads the request: mod_wsgi daemon mode.

Page 3 opens `docs/muru-processes.md` (edge, host, workers,
controller; `muructl run` as one Rust process with the edge and the
controller inside; the table again with a Muru row) and `hello.py`,
then starts `muructl run hello:application --port {{ app_port }}`
in the server terminal, leaving the startup line about the dashboard
to workshop 2. Page 4 shows the application
in a pane through jupyter-server-proxy, reads the access log line
field by field (`queue`, `app`, `worker`, `id`), and runs `curl -i` to
see `server: muru` and `x-request-id`. A quiz asks which process wrote
the access log line: the edge, since only it can measure `queue`.

Page 5 runs `show_processes.py`, which lists the `muructl` process,
the host and the worker with what each does. A text quiz asks how many
Python processes `--processes 3` gives (4: the host and three
workers), then the server is restarted that way and listed again.
Page 6 sends `GET /boom` (500, `reason=app_error`, the worker carries
on), asks what a client gets when its worker dies mid-POST (502 from
the edge), sends `POST /crash`, and lists the processes to show the
replacement forked from the same host. Page 7 opens `docs/releases.md`
(the daemon, a separate edge, releases side by side, blue/green,
canary, preview, rollback), runs `muructl run ... --print-config` to
show the development run as a release table, and stops the server.

- Format: two terminals and files, with a viewer area for the
  documents and the application. Ships `hello.py`,
  `show_processes.py`, `docs/serving-python.md`,
  `docs/muru-processes.md` and `docs/releases.md`.

- Requires: `muructl==0.1.0a17`; `curl` and `ps`.

- Source: `docs/explanation/architecture.md`,
  `docs/tutorials/first-wsgi-app.md`, `docs/howto/daemon.md`, and the
  other servers' documentation listed under Source material.

- Length: 25 minutes.

### 2. `what-muructl-run-tells-you`: Serve an app and read what it tells you

What does `muructl run` report while you develop, and where do you
look when something goes wrong?

The welcome page creates the environment (`muru`, `muructl`, Flask).
Page 2 opens `docs/where-output-goes.md` (gunicorn, uvicorn and
`muructl run` on requests, your output and failures, with Mermaid
diagrams and a table) and `shop.py`, a Flask application with a view
that prints, a slow report view that logs a warning, and a product
view that raises `KeyError` for product 9, with
`PROPAGATE_EXCEPTIONS` set and a comment saying why. It starts
`muructl run shop:app --port {{ app_port }} --dashboard
127.0.0.1:{{ dashboard_port }} --processes 2` and reads each startup
line. Page 3 asks for a product (the `.stdout` tagged line and the
access log line, field by field), quizzes how the report's logging
warning will be tagged (`muru.worker[N]:`, standard error), and asks
for the report (1.5s of `app`).

Page 4 opens product 9 in a pane (Muru's error page with the
traceback), fetches it as JSON through `python -m json.tool`, checks
for `"reason":"app_error"`, and quizzes what reason Flask's own 404
for `/nothing` gets in the log (none: a reason only appears on a
response Muru made). Page 5 restarts with `--access-log errors`,
quizzes how many lines the seven requests of `send_requests.py` give
(3: the 500, the 404 and the slow report), and runs it. Page 6 opens
the dashboard in a pane through the proxy (a browser tab without
one), sends five rounds, describes what it shows, and stops the shop.

- Format: two terminals and files, viewer area. Ships `shop.py`,
  `send_requests.py` and `docs/where-output-goes.md`.

- Requires: `muructl==0.1.0a17`, `flask==3.1.3`;
  `curl`. Variables `app_port` (8080) and `dashboard_port` (8081).

- Source: `docs/tutorials/first-wsgi-app.md`, `docs/howto/logging.md`,
  `docs/howto/dashboard.md`, `docs/howto/error-pages.md`,
  `docs/reference/errors.md`, `docs/howto/flask-and-django.md`.

- Length: 25 minutes.

### 3. `reload-and-https-in-development`: Reload, HTTPS and HTTP/2 on your laptop

How close to production can a development run be?

Page 2 opens `docs/reloading.md` (what gunicorn's and uvicorn's
`--reload` and a `muructl run` development run, which reloads without
a flag, replace, what requests get meanwhile, and
what a change that fails to import leaves serving, with diagrams and a
table) and `greeting.py`, whose first line carries `GREETING` and the
host's process id and whose second the scheme, protocol and
`muru.tls`. It starts `muructl run greeting:application --port
{{ app_port }}`, with no flag, and reads the `watching` line. Page 3
starts `watch.py`, which polls ten
times a second and stops a second after the first change, then
changes `GREETING` with an `editor-replace`: the terminal shows
`switched to release r2`, `watch.py` shows the new host and `0
failed`, and a check reads its `watch.log`.

Page 4 quizzes what requests get after saving a syntax error (the
previous release's answer; the wrong options are gunicorn's and
uvicorn's behaviour), drops the colon from the `def` line while
changing the greeting, shows `release r2 keeps serving` and the old
greeting, then puts the colon back and shows release r4. Page 5
restarts with `--https --https-port {{ https_port }}`, reads the
self-signed certificate line, curls over HTTP (`http`, HTTP/1.1),
quizzes which protocol arrives over HTTPS (HTTP/2.0), curls with
`--cacert muru-cache/certs/dev.pem`, greps curl's verbose output for
ALPN, explains why the pane cannot show it, and stops the server. The
manifest sets `MURU_CACHE_DIR` to `muru-cache` and `CAROOT` to a
missing directory under it, so the certificate stays in the workspace
and is self-signed on every machine.

- Format: two terminals and files, viewer area. Ships `greeting.py`,
  `watch.py` and `docs/reloading.md`.

- Requires: `muructl==0.1.0a17`; `curl`. Variables
  `app_port` (8080) and `https_port` (8443).

- Source: `docs/tutorials/first-wsgi-app.md`, `docs/howto/https.md`,
  gunicorn's `workers/base.py` and `config.py`, uvicorn's
  `supervisors/basereload.py`.

- Length: 20 minutes.

### 4. `import-once-fork-safely`: Import once, fork safely

What goes wrong when an application opens a connection at import time
and is then forked, and what does Muru do about it?

Page 2 opens `docs/preload-and-fork.md` (what a fork copies, shares
and loses, with a diagram; gunicorn `--preload` and its `post_fork`,
mod_wsgi daemon mode, uvicorn's spawned workers; Muru's check, its
three modes as a flow diagram and a table, and the hooks) and
`catalog.py`, which starts the metrics client in `metrics.py` at
import: a connected UDP socket to a statsd agent on 8125 and a thread
that sends the counts every five seconds and prints a line. A text
quiz asks how many threads the forked child will have (1), then
`fork_demo.py` imports the catalogue and forks with nothing in the
way: the child has only the main thread, and the same socket from the
same port. Python's fork `DeprecationWarning` shows because the fork
is in the script run.

Page 3 starts `muructl run catalog:application --processes 2` and
reads the `preload:` lines and the fallback, sends six requests, and
points at each worker's own sender reporting. Page 4 quizzes what
`--preload true` does (refuse to start) and shows it. Page 5 opens
`hooks.py` (`post_fork` starts the client), removes the start from
`catalog.py` with an `editor-replace`, starts with `--preload true
--hooks hooks`: no `preload:` lines, a `post_fork` line from each
worker, and their senders reporting from workers forked from a
preloaded host. It notes gunicorn's `post_fork(server, worker)` hook
and stops the server.

- Format: two terminals and files, viewer area. Ships `metrics.py`,
  `catalog.py`, `hooks.py`, `fork_demo.py` and
  `docs/preload-and-fork.md`.

- Requires: `muructl==0.1.0a17`; `curl`.

- Source: `docs/explanation/preload.md`, `muructl run --help`,
  gunicorn's `preload_app` setting, uvicorn's `_subprocess.py`.

- Length: 25 minutes.

### 5. `processes-threads-and-the-gil`: Processes, threads and the GIL

How many processes and threads should an application have, and why?

Page 2 opens `docs/processes-and-threads.md` (the GIL with a diagram;
a table of gunicorn `sync` and `gthread`, mod_wsgi daemon mode,
uvicorn, Granian and Muru; where Muru's requests wait, with a diagram;
reading `queue` against `app`; free-threaded Python) and `work.py`,
whose `/wait` sleeps 0.1s and `/compute` spends 0.1s of thread CPU
time. `load.py` sends 40 requests to each path, eight at a time, and
reads the edge's records from `--access-log-file requests.jsonl`, printing
the rate and the median total, `queue` and `app` times, after a line
with the CPUs it may use (allowing for a cgroup quota).

Page 3 runs one process of one thread: both views about 10 a second,
most of the time in `queue`. Page 4 quizzes what eight threads do to
`/compute` (the same rate, with the waiting moved from `queue` into
`app`), then shows it, with `/wait` about eight times faster. Page 5
quizzes what limits more processes (the CPUs), runs two processes of
four threads (`/compute` doubles where there are two CPUs; with one
it cannot), and stops the server. Free-threaded Python is described in
the document only: the workshop's environment is a regular 3.14, and
Binder has no free-threaded interpreter.

- Format: two terminals and files, viewer area. Ships `work.py`,
  `load.py` and `docs/processes-and-threads.md`.

- Requires: `muructl==0.1.0a17`; `curl`.

- Source: `docs/explanation/process-models.md`, gunicorn's design
  documentation, Granian's README, mod_wsgi's `WSGIDaemonProcess`
  defaults.

- Length: 30 minutes.

### 6. `wsgi-and-asgi-together`: WSGI and ASGI from one server

Can one server run a Flask application and a FastAPI application, with
WebSockets, side by side, and show what the sockets are doing?

Page 2 opens `docs/two-interfaces.md` (what gunicorn, uvicorn, Granian
and mod_wsgi each take, the two servers and proxy a mixed site usually
needs, with a diagram; mounts in one worker's threads and event loop,
with a diagram; the edge carrying WebSockets), then `pyproject.toml`,
whose `[tool.muru]` table has `web:app` as the default mount and
`api:app` as the mount `api` at `/api`, with two processes, and
`web.py` (Flask: a page at `/` whose script opens a WebSocket to
`api/echo` relative to itself, and `/about`) and `api.py` (FastAPI:
`/about` and the WebSocket `/echo`). It starts `muructl run --port
{{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}` with no
entrypoint and reads the mount's startup lines. Page 3 curls Flask's `/about`
(`SCRIPT_NAME` empty), quizzes where FastAPI runs (the same workers,
on the event loop), and curls `/api/about` (thread `muru-loop`,
`root_path` `/api`), pointing at `mount=api` in the access log. Page 4
opens the page in a pane, where the WebSocket echoes through
jupyter-server-proxy, and points at its handshake line (`101`, written
when FastAPI accepts it), then runs `say.py`, whose socket opens and
closes at once, and reads its closing line (`websocket=closed
by=client code=1000 received=1 sent=1`, same `id=`). Page 5 runs
`listen.py` to hold five more sockets open, opens the dashboard in a
pane (a browser tab without jupyter-server-proxy), and reads the
"WebSockets open" tile (six), the WebSockets table and the chart,
noting that a socket is not a request in flight; stops `listen.py`
(five closing lines, the count back to one); quizzes what happens to
the page's socket when the site stops; and stops the site, which
closes it with `by=edge code=1001` at once.

- Format: two terminals and files, viewer area. Ships `pyproject.toml`,
  `web.py`, `api.py`, `say.py`, `listen.py` and
  `docs/two-interfaces.md`. Variables `app_port` (8080) and
  `dashboard_port` (8081).

- Requires: `muructl==0.1.0a17`, `flask==3.1.3`,
  `fastapi==0.162.0`, `websockets==17.3`; `curl`.

- Source: `docs/howto/mounts.md`, `docs/howto/starlette-and-fastapi.md`,
  `docs/howto/asgi.md`, `docs/howto/logging.md`,
  `docs/howto/dashboard.md`, `docs/howto/timeouts.md`,
  `docs/explanation/process-models.md`.

- Length: 25 minutes.

### 7. `deploying-without-downtime`: Deploy without dropping a request

What does a deploy look like when the new release starts beside the
old one?

Page 2 opens `docs/deploying.md` (gunicorn's `HUP` and, with
`--preload`, `USR2`; a mod_wsgi daemon restart; two deployments behind
a load balancer; the Muru daemon, with diagrams and a table), starts
`muructl daemon start --listen 127.0.0.1:{{ app_port }}`, shows the
503 with nothing deployed and `muructl daemon status`. Page 3 deploys
`releases/v1` (`greeter.py`, which names its release from
`muru.context()`, and a `pyproject.toml` with the entrypoint and two
processes) as `greeter`, and lists the releases. Page 4 starts
`traffic.py` in the left terminal (four clients without cookies,
counts every two seconds by the text after "Served by", errors and
requests with no answer), quizzes how many requests go unanswered (0),
deploys `releases/v2` and lists `r1` as retained. Page 5 rolls back,
stops the traffic and checks its totals in `traffic.log` for `no
answer: 0`. Page 6 runs `show_processes.py` (the daemon, the edge, each
release's host and workers), quizzes what `muructl daemon stop`
without `--shutdown` does to requests (nothing: the edge and hosts go
on serving), and shuts the daemon down.

- Format: two terminals and files, viewer area. Ships `releases/v1`,
  `releases/v2`, `traffic.py`, `show_processes.py` and
  `docs/deploying.md`.

- Requires: `muructl==0.1.0a17`; `curl`, `ps`.
  Variables `app_port` (8080) and `muru_run_dir` (`/tmp/muru-deploy`).

- Source: `docs/howto/daemon.md`, gunicorn's signals documentation.

- Length: 30 minutes.

### 8. `canary-a-release`: Canary a release and let it roll back

How do you try a new release on a share of the traffic, and back out
when it misbehaves?

Page 2 opens `docs/canary.md` (a canary built from two deployments and
weights; a rollout under the daemon: hold, preview, steps, gates
judged against the baseline, promotion and rollback), starts the
daemon, deploys `releases/v1` and applies `routes.toml` (a default host
and one route, which the previews need). Page 3 deploys `releases/v2`
with `--hold`, shows it held, and previews it with `Muru-Preview: r2`.
Page 4 starts `traffic.py` and runs `muructl rollout canary
greeter@r2 --steps 10,50 --hold 10s --min-requests 20 --wait`, about
20 seconds, then `rollout status` shows it promoted. Page 5 holds
`releases/v3` (one request in five is a 500), quizzes when its
rollout ends (in the 10% step, once it has 20 requests), runs the same
canary, which rolls back within seconds, shows the reason in `rollout
status` and `r3` kept warm, stops the traffic and shuts the daemon
down.

- Format: two terminals and files, viewer area. Ships `releases/v1`
  to `v3`, `routes.toml`, `traffic.py` and `docs/canary.md`.

- Requires: `muructl==0.1.0a17`; `curl`. Variables
  `app_port` (8080) and `muru_run_dir` (`/tmp/muru-canary`).

- Source: `docs/howto/rollouts.md`, `docs/howto/traffic.md`.

- Length: 30 minutes.

### 9. `what-nginx-was-for`: What you would have put nginx in front for

What does the edge do that a proxy in front of an application server
usually does?

Page 2 opens `docs/nginx-and-the-edge.md` (a typical nginx
configuration for the shop, and a table of what replaces each part)
and `site.toml`, whose paths are relative to it, starts the daemon
and applies it: the
release of `site/app/shop.py` with `sendfile_roots`, `error_override`
for 404 with `html_only`, and `error_pages` for 404 and
`503:maintenance`; a default host; a static route at `/static/` with a
one-hour cache; a route to the application. Page 3 shows the style
sheet's headers, a conditional request answered 304, the precompressed
`app.css.gz` sent to a gzip client, quizzes which process sent it (the
edge) and shows `reason=static` in the access log. Page 4 compares the
catalogue's size with and without Brotli, opens `report()`, which
answers with `X-Muru-Sendfile`, and fetches the report and a range of
it (206). Page 5 shows the site's 404 page for HTML and the
application's for curl, turns maintenance on (503, `Retry-After` and
the maintenance page, static files still served) and off, and shuts
the daemon down.

- Format: two terminals and files, viewer area. Ships `site/` (the
  application, static files with a `.gz` variant, a report, two error
  pages), `site.toml` and `docs/nginx-and-the-edge.md`.

- Requires: `muructl==0.1.0a17`; `curl`, `sed`.
  Variables `app_port` (8080) and `muru_run_dir` (`/tmp/muru-edge`).

- Source: `docs/howto/static-files.md`, `compression.md`,
  `file-hints.md`, `error-pages.md`, `virtual-hosts.md`.

- Length: 30 minutes.

### 10. `bring-your-server-along`: Try Muru without changing your deployment

Can an existing gunicorn deployment move to Muru one step at a time?

Page 2 opens `docs/cutting-over.md` (a managed server release, a
native release canaried against it, and when to choose which server)
and `orders/orders.py`, whose responses name `SERVER_SOFTWARE`
(`gunicorn/26.2.0`, then `muru/0.1.0a17`), starts the daemon and
deploys `muructl deploy orders orders
--server gunicorn -- gunicorn --workers 2 --bind '{bind}'
orders:application`, shows gunicorn answering through the edge, the
release as `1 gunicorn`, the gunicorn master and workers under the
daemon, and applies `routes.toml`. Page 3 deploys the same directory
with `--entrypoint orders:application --processes 2 --hold` and
previews it. Page 4 canaries it against gunicorn under `traffic.py`
until it is promoted. Page 5 quizzes what a rollback to gunicorn does
(moves the traffic at once), rolls back, checks the traffic's totals
and shuts the daemon down. This is the one workshop that installs
another server.

- Format: two terminals and files, viewer area. Ships `orders/`,
  `routes.toml`, `traffic.py`, `show_processes.py` and
  `docs/cutting-over.md`.

- Requires: `muructl==0.1.0a17`, `gunicorn==26.2.0`;
  `curl`, `ps`. Variables `app_port` (8080) and `muru_run_dir`
  (`/tmp/muru-server`).

- Source: `docs/howto/managed-servers.md`, `docs/howto/rollouts.md`.

- Length: 30 minutes.

### Topics the Meet Muru collection leaves out

- **Running the other servers to compare.** Installing gunicorn,
  uvicorn, Granian or mod_wsgi to show their process trees beside
  Muru's was considered and dropped: a description of their process and
  thread models, with a diagram, says what the comparison needs.
  Workshop 10 is the exception, for the reason given there.

- **Benchmarks.** Throughput figures depend on the machine, and a
  shared Binder container is no place to measure them.

- **systemd, service users, secrets and log rotation.** Linux and
  root only, so they belong to a collection on running Muru as a
  service.

- **Anything only on Muru's develop branch** until it is released:
  uploads, client classes and rate limits, overlays, gRPC mounts, scale
  to zero, profiling and the debugger.

## Developing with muructl run

Collection id `grahamdumpleton.me/muru/developing`, title "Developing
with muructl run", index at `collections/developing/collection.json`.
The id never changes.

### Shape of the Developing collection

Meet Muru's workshops 2 to 6 show what `muructl run` does with a small
application of the workshop's own. This collection takes the learner's
kind of project, Flask, Django or FastAPI, through a working day under
`muructl run`: where its settings live, what each framework needs to
be told, the hooks that run around the fork, reload and HTTPS set up
for a real project, and what to do when a request hangs. Each workshop
names the Meet Muru workshop it builds on and restates that in a
sentence rather than repeating it.

Eight workshops of 20 to 30 minutes, about three and a half hours in
all, on the
same pattern as Meet Muru: an environment of its own pinned to the
release, two terminals, documents with diagrams in the viewer area,
and the application in a pane through jupyter-server-proxy where a
page helps. The framework workshops (2 to 4) can be taken in any order
after the first; a learner who uses only one framework takes that one.
Each edits the project through actions (`file-write` appends,
`editor-insert`, `editor-replace`), so the learner still types nothing.

### What was checked against 0.1.0a17

Checked on CPython 3.14 in a scratch environment holding `muructl`
alone, and self-tested on CPython 3.14, macOS, on 2026-11-04, when the
pins moved from 0.1.0a16 to 0.1.0a17 (the a16 record below stands for
what it does not restate):

- `--access-log` takes `on`, `errors` or `off` alone, and a file is
  named with `--access-log-file PATH` (muruhq/muru#343): workshop I.5
  starts its runs with `--access-log-file requests.jsonl`, and given a
  200 and a 404, `--access-log errors --access-log-file FILE` writes the
  404 alone to the file and nothing to the terminal. `--access-log
  errors` and `access_log = "errors"` mean what they did.

- With `MURU_WHEEL_DIR` naming a directory holding the release's wheel
  for the interpreter, `MURU_OFFLINE=1` and an empty `MURU_CACHE_DIR`,
  `muructl check` provides the library from that directory; without
  the variable it refuses, naming it. The daemon, with `[tools] offline
  = true` and its cache in the workspace, takes the library from
  `MURU_WHEEL_DIR` when its table names no `wheel_dir`
  (muruhq/muru#344) and serves. Either way the first line still says
  `fetched the runtime library ... once` (muruhq/muru#354).

- The orders service's `SERVER_SOFTWARE` under Muru is
  `muru/0.1.0a17`. Nothing else in the release changes what a workshop
  shows: the daemon's `[logs]` choices, faster static files and
  descriptor hints, retries to upstreams, `server_instances` in
  `release show` and the renamed `status` counts touch nothing a
  workshop writes.

### What was checked against 0.1.0a16

Checked on CPython 3.14 in a scratch environment holding `muructl`
alone, and self-tested on CPython 3.14, macOS, on 2026-11-03, when the
pins moved from 0.1.0a15 to 0.1.0a16 and `muru` left every
environment (the a15 record below stands for what it does not
restate):

- With no `muru` in the environment, a development run's first lines
  are `muru: fetched the runtime library
  muru-0.1.0a16-cp314-cp314-<platform>.whl, once` and `muru: runtime
  library 0.1.0a16 from <cache>/runtime/0.1.0a16/cp314`; once the
  cache has it, the second line alone. `<cache>` is `~/.cache/muru`
  on Linux and `~/Library/Caches/muru` on macOS, or `MURU_CACHE_DIR`.
  Workshop I.2 names the line.

- `muructl check app:application --python python` in a directory with
  a one-line WSGI application fills the same cache, which is how the
  Binder and Codespaces setup does it. With the cache filled,
  `MURU_OFFLINE=1 muructl run` serves.

- The orders service's `SERVER_SOFTWARE` under Muru is
  `muru/0.1.0a16`. Nothing else in the release changes what a
  workshop shows: per-group recycling, the configuration reference,
  the uWSGI profile and the stricter refusal of zero and empty values
  touch nothing a workshop writes.

### What was checked against 0.1.0a15

Checked on CPython 3.14 in a scratch environment, and self-tested on
CPython 3.14, macOS, on 2026-11-02, when the pins moved from 0.1.0a12
to 0.1.0a15 (the a12 record below stands for what it does not
restate):

- A development run's first line is now `muru: runtime library
  0.1.0a15 from the environment`, or the second after `muru: using
  [tool.muru] from ...` when the project has a table. The rest of the
  startup lines read as the a12 record says. Workshop I.2 names the new
  line.

- Lines written to a file, and what `muructl logs` prints, start with
  the full UTC time (`2026-11-02T07:48:54.891Z`); lines in a terminal
  do not. Every check matches within a line, so the time changes none.

- The stricter names of 0.1.0a14 (lowercase letters, digits and
  hyphens for classes, rate limits, mounts, groups and environment
  variables) refuse nothing a workshop writes.

- Commands, `muructl exec`, the MCP server, handoff between WSGI and
  ASGI, `muructl build`, `muructl check` and `muructl serve` are new
  and taught nowhere yet.

- On Linux with CPython 3.14, `muructl debug stacks` reads a worker
  from outside and loses every frame below the first call from C into
  Python (muruhq/muru#306), so a request waiting at `breakpoint()`
  shows Muru's hook and not `checkout.py`. Workshop II.8's
  `request-waiting` check fails there, on CI and on Binder, and passes
  on macOS and on 3.15.

### What was checked against 0.1.0a12

Checked on CPython 3.15 in a scratch environment, and self-tested on
CPython 3.14, macOS, on 2026-10-31, when the pins moved to 0.1.0a12
(the a11 record below stands for what it does not restate):

- A development run reloads with no flag. Its `development mode` line
  reads `error pages show tracebacks, nothing is persisted, the run
  reloads on change and only loopback is served`, and its last line is
  `muru: watching /abs/project for changes to **/*.py`, after the
  dashboard and admin socket lines. With `--no-reload`, or `reload =
  false` in the run table, the line reads `nothing is persisted and
  only loopback is served` and there is no `watching` line; `--reload`
  over `reload = false` turns it back on. Every workshop that starts
  `muructl run` therefore shows the `watching` line, and none of them
  edits a `.py` file while a run it did not mean to reload is serving
  (pyproject.toml edits do not count as source).

- `[tool.muru.run]` in the project's `pyproject.toml`: `muructl run
  notes` with `port`, `access_log = "errors"` and `dashboard = "off"`
  serves on the table's port with no dashboard line. A `[run]` table
  in `muru.local.toml` beside it adds `muru: using [run] from
  notes/muru.local.toml` after the `using [tool.muru]` line, and its
  `port` wins over the table's; a `--port` flag wins over both. The
  line `muru: muru.local.toml is not covered by the project's
  .gitignore; add it, since the file is for this machine alone` is
  printed only when the project has a `.gitignore` that does not name
  the file (`gitignore_covers` in `muructl`), so workshop II.1 writes one
  with `__pycache__/` in the terminal to show it; a shipped dot file
  would not do, since the contents API cannot write hidden files and
  publishing leaves them out. A key outside
  `[run]` in the local file is refused: `notes/muru.local.toml: tool is
  not a key of muru.local.toml, which holds the [run] table only; the
  application's settings belong in notes/pyproject.toml`. A misspelt
  run key lists the sixteen keys the table takes, `port` to
  `compression`.

- The menu project with `[tool.muru.run]` holding `port`, `https_port`,
  `https_only = true`, `hosts = ["menu.test"]`, `tls_cert`, `tls_key`,
  `reload_include` and `reload_exclude`: plain `muructl run menu`
  serves HTTPS with HTTP redirecting to it, `TLS certificate from
  certs/server.pem` (relative to the project), and the `watching` line
  with the patterns and the exception; `https_only` alone implies
  HTTPS. `--no-https-only` over the table serves both plainly.
  `--print-config` writes two `[[listener]]` tables, the HTTPS one with
  `tls = true`, and nothing of the run table; the release is
  `[app.app.release.r1]`, named after the module.

- Issues 206 and 207 in Muru (one snapshot push per deploy, and the
  edge keeping its connections across an apply) change nothing the
  workshops show.

### What was checked against 0.1.0a11

Checked on CPython 3.14, macOS, on 2026-10-30, when the pins moved to
0.1.0a11 (the a10 record below stands for what it does not restate):

- `breakpoint()` in a WSGI request under `muructl run --processes 2`:
  the terminal prints `muru: debug.breakpoint: worker 0 (pid N):
  breakpoint() at /abs/checkout.py:17 waits 300 s for muructl debug
  attach checkout --worker 0` (the call's `timeout`, 60 s without
  one); `muructl debug status checkout` shows the request in flight
  and the worker `ready`; `muructl debug stacks checkout` shows the
  thread `serving GET /checkout?item=teapt for 10.0 s` ending at the
  `breakpoint()` line; with `--timeout soft=2s --timeout hard=8s` set
  (the hard timeout must exceed the soft by 5 s or the run refuses to
  start) the request still waits at 10 s with no timeout line.
  `muructl debug attach checkout` with no `--worker` takes the waiting
  worker: `muru: attached to worker 0 at /abs/checkout.py:17; the end
  of input lets the code go on`, pdb's two lines, `(Pdb)`; `p item,
  price` gives `('teapt', 0)`, an assignment changes the frame, and
  `continue` prints `muru: the session in worker 0 has ended` and the
  request answers 200 after its wait (`app=10.03s`). The terminal
  logs `debug.attached: a debugger session opened in worker 0` and
  `debug.detached: worker 0 (pid N): the debugger session at
  /abs/checkout.py:17 ended`. `muructl debug attach checkout
  < /dev/null` attaches and lets the code go on at once. A breakpoint
  nobody attaches to logs `debug.breakpoint_expired: worker 0 (pid
  N): nobody attached to breakpoint() at /abs/checkout.py:21 in 5 s;
  carrying on` and the request answers. With none waiting, `attach
  --worker 0` says `attached to worker 0 at a thread of its own` in
  the runtime's `_debug.py` frame, where the application's module
  must be imported to be reached (`import checkout; checkout.PRICES`);
  `muructl debug exec checkout -- 'import checkout;
  checkout.PRICES["cup"]'` prints `worker 0 (pid N):` then the value
  for each worker, and the event `debug.exec: ran code in every
  worker: ...`. `muructl logs --access --lines 1` and `muructl status`
  (`run pid N version 0.1.0-alpha.11`, `app checkout@r1`, `project
  DIR`) work from the project directory with no flag. macOS prints
  `stacks and profiles come from inside the workers, as reading them
  from outside is not available here (Cannot get task port ...)` at
  every stacks read, which the pages do not quote.

- `[[tool.muru.static]]` with `path = "/static/"` and `dir =
  "shop/static"` in the Flask project: the startup line `muru: static
  /static/ from shop/shop/static`; the stylesheet answers from the edge
  with `ETag` and `Last-Modified` (no `Cache-Control` without `cache`),
  the terminal's access log line `200 GET /static/shop.css 112B 0.0ms
  reason=static id=...` with no `worker=`, and `muructl logs --access`
  shows the same line with `release=shop@r1 host=127.0.0.1` added.

- `SERVER_SOFTWARE` is `muru/0.1.0a11` in the WSGI environ. A worker's
  `print()` without `flush=True` reaches the terminal as
  `muru.worker[0].stdout: ...`.

- A factory named without `factory = true`: `muru.host[N]: cannot load
  shop:create_app: RuntimeError: shop:create_app takes no required
  arguments, so it cannot be a WSGI application; if it is an
  application factory, set factory = true in [tool.muru], or give
  --factory when the entrypoint is named on the command line`, then
  `Error: the host exited with exit status: 1 before its workers were
  ready`, exit 1.

- Timeouts on `accounts.py`: with `soft=2s hard=7s`, `/sync` answers
  `504 after 7.58 s`, `reason=hard_timeout`, the host logs `a request
  has run for 7.6 s, past the hard timeout of 7 s; replacing it`, the
  stacks, a new worker, `gave up 1 request for the edge to answer`,
  and about eight seconds later `did not stop, killing` and `replaced
  by pid`. With `gil_stall=10s`, `check.py` reports `/check: 502 after
  10.2 s` and `/health: 502 after 9.2 s`, both `reason=worker_stalled`,
  the host logs `gave up 2 requests`, the `faulthandler` stacks, and
  the kill follows. With `soft=2s hard=7s gil_stall=10s` together,
  `/check` is `504 after 7.5 s` (`hard_timeout`) and `/health` `502
  after 21.6 s` with `reason=worker_crashed`: the other request of a
  worker condemned by the hard timeout waits out the grace and the
  kill even though the GIL stall timeout also fires at 10 s. FastAPI
  with `loop_stall=5s`: `/stall: 502 after 4.7 s` and `/where/async:
  502 after 3.7 s`, both `worker_stalled`.

- `--reload-include '**/*.html' --reload-include '**/*.json'
  --reload-exclude 'data/last-visit.json'` prints `muru: watching
  /abs/menu for changes to **/*.py, **/*.html, **/*.json, except
  data/last-visit.json` as the last startup line. `--tls-cert
  certs/server.pem --tls-key certs/server.key` are read under the
  project (`--chdir menu`), so `menu/certs/` holds them, and the line
  is still `TLS certificate from certs/server.pem`.

- An applied file's paths: `source` and a route's `static` resolve
  from the file's directory; a release's `error_pages` files resolve
  from its `source` (documented), so the pages moved under
  `site/app/pages`; `sendfile_roots` is joined to the file's directory
  but left relative when `-f` names a relative file (`"./site/reports"
  must be an absolute path`), so page 2 applies `"$PWD/site.toml"`
  (not raised as an issue yet; see the report of 2026-10-30).

- Startup lines are now `serving`, `development mode`, `static` (when
  declared), `TLS certificate` (with `--tls-cert`), `dashboard`,
  `admin socket /tmp/muru-UID/runs/PORT/admin.sock`, then `watching`
  with `--reload`; the dashboard line is no longer last.

### What was checked against 0.1.0a10

Checked on CPython 3.14, macOS, on 2026-10-28, for workshops 1 to 7
of this collection:

- `[tool.muru]` takes `entrypoint`, `interface`, `reflection`,
  `grpc_web_origins`, `factory`, `factory_phase`, `processes`,
  `threads`, `sync_threads`, `concurrency`, `scaling`, `preload`,
  `hooks`, `python`, `groups`, `mounts`, `logging`, `max_requests`,
  `max_lifetime`, `timeouts`, `memory`, `env`, `accel_redirect`,
  `cgi_local_redirect`, `sendfile_roots`, `sendfile_header`,
  `error_pages`, `error_override` and `maintenance`; an unknown key
  stops the run with a TOML parse error naming the line and listing
  those keys. No port, reload, HTTPS, access log or dashboard key. A
  flag wins over the table, then the table, then the default. A
  project directory as the argument, or `--chdir` with an entrypoint,
  finds the table (`using [tool.muru] from notes/pyproject.toml`), and
  the host runs there. The table's `env` wins over the same variable
  set in the shell. `--print-config` writes `[[listener]]`, `[limits]`
  and `[app.NAME.release.r1]` with `timeouts` and `env` tables, the
  name from the entrypoint's module, and includes flags such as
  `--processes`. In development `muru.context().release` was `dev` for
  every release, r2 and r3 included; from 0.1.0a11 it is the release
  the terminal names, `r1` and then `r2`, and `muru.context().app` is
  the run's label, the entrypoint's module with underscores as
  hyphens.

- Flask 3.1.3: a factory named without `factory = true` was served as
  the application, and each request failed `TypeError: create_app()
  takes 0 positional arguments but 2 were given` (500,
  `reason=app_error`); from 0.1.0a11 the run refuses it at load,
  `cannot load shop:create_app: RuntimeError: shop:create_app takes no
  required arguments, so it cannot be a WSGI application; if it is an
  application factory, set factory = true in [tool.muru], or give
  --factory ...`, and exits. The table's `factory` applies only to the
  table's entrypoint. With it, each worker logs `worker 0 serves
  shop:create_app as WSGI`, and each worker's pool is made in its own
  process; with `factory_phase = "host"` the host builds it once and
  both workers report the host's pid, and the import check says
  nothing about an SQLite connection (a file). Muru sets the root
  logger to `WARNING`, so `app.logger.info` is dropped until
  `[tool.muru.logging.python] level = "INFO"`, after which Flask's
  default handler writes `[time] INFO in module: ...` tagged by worker.
  `FLASK_PROPAGATE_EXCEPTIONS = "true"` in the table's `env`, read by
  `app.config.from_prefixed_env()`, gives Muru's page and
  `reason=app_error`.

- Django 6.1.2: `startproject`'s `wsgi.py` preloads in about 80 ms and
  the workers fork from it. Under `muructl run` with `DEBUG = True`,
  `/static/admin/css/base.css` is 404 (`Not Found` logged by Django):
  only `runserver` serves static files. Muru's
  `docs/howto/flask-and-django.md` says `django.contrib.staticfiles`
  serves them "from the application as usual", which is wrong; to
  raise with Muru. `staticfiles_urlpatterns()` in `urls.py` fixes it
  in development. `--reload` on the project directory picks up
  `urls.py` and `settings.py`. `DEBUG_PROPAGATE_EXCEPTIONS = True`
  gives `reason=app_error`, and a JSON client gets `"reason":
  "app_error"`. jupyter-server-proxy passes JupyterLab's own `Host`, so
  the shipped settings have `ALLOWED_HOSTS = ["*"]`, with a comment
  saying why. From `asgi.py`, `2 workers of concurrency 1000`; a sync
  view runs on a `ThreadPoolExecutor` thread, an async view on
  `muru-loop`; under WSGI the async view ran on an event loop Django
  started. Static files under ASGI log Django's warning about
  `StreamingHttpResponse` and synchronous iterators, so the workshop
  does not load them there.

- FastAPI 0.162.0: with 50 requests at once, `/wait/async` (await
  `asyncio.sleep(0.2)`) takes 0.25 s, plain `def` with `time.sleep`
  0.45 s (on `AnyIO worker thread`, 40 at once), `asyncio.to_thread`
  1.44 s on `muru-sync_N` (8), 0.26 s with `--sync-threads 50`, and a
  blocking `time.sleep` in `async def` 10.2 s, which itself tripped
  the 10 s loop stall timeout, so the workshop sends 20 (4.1 s). A
  lifespan that raises fails the worker (`exited with status 1,
  restarting`, twice) and after three failures `muructl run` exits
  (`the host exited ... before its workers were ready`). With
  `--timeout loop_stall=5s`, a 30 s `time.sleep` on the loop is caught
  at 5.1 s (`worker.loop_stalled`), a new worker serves at once, and
  the stalled request and an innocent one on the same worker both got
  502 `worker_crashed` after about 19 s (hard drain grace and
  shutdown); from 0.1.0a11 both are answered 502 `worker_stalled` at
  the stall (4.7 s and 3.7 s), the host logging `gave up 2 requests
  for the edge to answer`, and the kill follows about fifteen seconds
  later. macOS adds `stacks and profiles come from inside the workers,
  as reading them from outside is not available here: Cannot get task
  port`, which the pages do not quote.

- Hooks: `on_load` and `pre_fork` once in the host (printed untagged),
  `post_fork` then `on_ready` in each worker; a reload runs the new
  release's four, then `switched to release r2`, then the old workers'
  `on_drain` and `on_exit`; `SIGUSR1` to a worker runs its
  `on_reopen_logs` only; with `--preload false` each worker logs
  `worker 0 imported ...` and runs `on_load`, `pre_fork`, `post_fork`,
  `on_ready`, and the host none; an ASGI lifespan starts between
  `post_fork` and `on_ready` and shuts down between `on_drain` and
  `on_exit`.

- Reload: only `**/*.py` counts by default; `--reload-include`
  replaced the default up to 0.1.0a10 (an `app.py` change no longer
  reloaded when only `**/*.html` was given) and adds to it from
  0.1.0a11, where an exclude wins over an include and the startup line
  `muru: watching DIR for changes to **/*.py, **/*.html, **/*.json,
  except data/last-visit.json` names what is watched; including
  `**/*.json` makes a file the
  application writes on each request start a release every time;
  `--reload-exclude 'data/last-visit.json'` stops it. A 3 s request in
  flight finishes 200 on the old release with the old template. HTTPS:
  `--host menu.test` gives `self-signed certificate for localhost,
  127.0.0.1, ::1, menu.test (created, ...)`, `reused` while the names
  stay the same and `created` again when they change; `curl --resolve`
  with `--cacert` proves the name. `--https-only` says `https://...
  (http://... redirects to it)` and answers plain HTTP `307 Temporary
  Redirect` keeping the path and query. trustme 1.2.1 (`python -m
  trustme -d certs -i ...`, the directory must exist) writes
  `server.pem`, `server.key` and `client.pem` (the CA); `--tls-cert`
  and `--tls-key` paths were relative to where `muructl` ran up to
  0.1.0a10 and are relative to the project (`--chdir`) from 0.1.0a11,
  so the workshop makes them under `menu/certs`; the line is `TLS
  certificate from certs/server.pem`.

- Timeouts: `--timeout soft=2s` on Python code answers 504
  `reason=soft_timeout` and logs `ran past the soft timeout of 2 s at
  accounts.py line N in ...`; `muru.RequestTimeout` is a
  `BaseException`. A bare `except:` around a call that waits swallows
  it, and `--timeout hard=7s` replaces the worker at 7.1 s; the client
  gets 502 after about 22 s. (An exception raised in the `except`
  block itself escapes, which an earlier draft of the code did.) The
  regex `^([a-z]+)+$` on 34 letters and `!` holds the GIL; no soft
  timeout line appears. Alone, the hard timeout replaces its worker at
  7.1 s; with a second request sent to the same worker a second later,
  the hard timeout never fires, with or without a soft timeout, and
  only the GIL stall timeout replaces the worker (30 s by default; 10 s
  in the workshop, both requests 502 after about 25 s). To raise with
  Muru. So the workshop shows the hard timeout on swallowed Python and
  the GIL stall timeout on C. `--access-log-exclude /health` and
  `--access-log errors --slow 1s` behave as documented.

### The Developing workshops

### 1. `settings-in-the-project`: Keep the run settings with the project

Where should a project's server settings live, so the next person runs
it the same way?

Page 2 opens `docs/where-settings-live.md` (gunicorn's five sources,
uvicorn's and Granian's command lines and environment variables,
mod_wsgi's directives, and Muru's table, with a diagram), then
`notes/notes.py` and `notes/hooks.py`, and starts `NOTES_TITLE="Team
notes" muructl run notes:application --chdir notes --processes 2
--threads 2 --hooks hooks --timeout soft=5s --port {{ app_port }}`.
Page 3 appends the `[tool.muru]` table with `timeouts` and `env`
tables and runs `muructl run notes --port {{ app_port }}`. Page 4
appends `[tool.muru.run]` with `port` and `access_log = "errors"` and
runs plain `muructl run notes`, writes `notes/muru.local.toml` with
`[run] port = {{ other_port }}` and reads the `using [run]` line and
the warning that a `.gitignore` written in the terminal does not cover
it, adds the file to `.gitignore`, and quizzes where `reload_include` belongs
(the run table, not the local file or `[tool.muru]`). Page 5 quizzes
a flag against the table, runs `--processes 1`, then misspells
`threads` and puts it right. Page 6 writes `--print-config` to
`notes-config.toml`, opens it and reads its three parts, with nothing
of the run table in them.

- Builds on Meet Muru 6. Variables `app_port` (8080) and `other_port`
  (8090). Requires the pins only.

- Length: 25 minutes.

### 2. `serving-a-flask-project`: A Flask project under muructl run

What does a Flask project need to change to run under Muru?

Ships `shop/` (a `create_app` factory reading `FLASK_` settings, a
pool of one SQLite connection opened when it is made, views, a
template and a stylesheet) and `docs/flask-and-muru.md`. Page 2
quizzes and shows the factory served without `factory = true`, then
adds it and opens the shop in a pane. Page 3 shows a pool per worker
from `/pool`, then `factory_phase = "host"` and one pool for both,
and removes it. Page 4 sets `[tool.muru.logging.python] level =
"INFO"`, shows Flask's own 500 for `/stock`, adds
`FLASK_PROPAGATE_EXCEPTIONS` to the table's `env`, and shows Muru's
page in the pane. Page 5 shows Flask serving `/static/shop.css` from a
worker and points at the daemon's static routes.

- Builds on Meet Muru 2 and 4. Requires `flask==3.1.3`.

- Length: 25 minutes.

### 3. `serving-a-django-project`: A Django project under muructl run

What changes when `runserver` is not the server?

Ships `mysite/` (`startproject` and `startapp` output from Django
6.1.2, with a `Product` model, a migration that adds three, a sync
`index`, a failing `stock`, an async `ping`, and `ALLOWED_HOSTS =
["*"]`) and `docs/django-and-muru.md`. Page 2 runs `python
mysite/manage.py migrate` and starts `muructl run mysite --port
{{ app_port }}`, which reloads on change as a development run does. Page 3 opens the unstyled admin, quizzes who
serves `/static/`, adds `staticfiles_urlpatterns()` and reloads it.
Page 4 shows Django's debug page for `/stock`, adds
`DEBUG_PROPAGATE_EXCEPTIONS`, and shows Muru's. Page 5 runs `/ping`
under WSGI, then `muructl run mysite.asgi:application --chdir mysite`,
quizzes where a sync view runs, and stops.

- Builds on Meet Muru 4. Requires `django==6.1.2`.

- Length: 30 minutes.

### 4. `fastapi-on-the-event-loop`: FastAPI and Starlette on the event loop

What runs where in a FastAPI application under Muru?

Ships `main.py` (a lifespan that loads `prices.json`, `/where/*` and
`/wait/*` in each kind, and `/stall`), `prices.json`, `load.py`,
`stall.py` and `docs/the-event-loop.md`. Page 2 starts two workers,
quizzes a missing `prices.json`, renames it away and back. Page 3
asks the three `/where` paths, quizzing the plain `def`. Page 4 loads
the three `/wait` kinds with 50 requests and reruns `to-thread` with
`--sync-threads 50`. Page 5 quizzes and loads `/wait/blocking` with
20, then runs `stall.py` with `--timeout loop_stall=5s`.

- Builds on Meet Muru 5 and 6. Requires `fastapi==0.162.0`.

- Length: 30 minutes.

### 5. `every-hook-in-order`: Hooks from load to exit

When does each hook run, in which process?

Ships `hooks.py` (all seven, each printing where it ran),
`greeting.py`, `events.py` (a raw ASGI application with a lifespan),
`reopen.py` and `docs/hooks.md`. Page 2 starts two workers and
quizzes where a pool goes. Page 3 quizzes new `on_ready` against old
`on_drain` under the run's own reload, and changes the greeting. Page
4 sends `SIGUSR1` to one worker. Page 5 runs `--preload false`, then
`events.py`, and stops it to show the lifespan's place.

- Builds on Meet Muru 4. Requires the pins only.

- Length: 25 minutes.

### 6. `reload-and-https-your-way`: Reload and HTTPS beyond the defaults

How do you fit reload and HTTPS to a real project?

Ships `menu/` (a template, a data file, and an application that writes
`data/last-visit.json` on each request and has a 3 s `/slow`),
`slow.py` and `docs/reload-and-https.md`. Pages 2 to 4, under the
development run's own reload with no flag: the default misses a
template change; includes for `.html` and `.json`; every request
reloading; the exclude; a dish added; `/slow` in flight during a
template change. Page 5: `--https --host menu.test` and `--https-only`.
Page 6: trustme's CA and `--tls-cert`. Page 7 writes
`menu/pyproject.toml` with `[tool.muru]` and a `[tool.muru.run]` table
holding every flag of the workshop as a key, runs plain `muructl run
menu`, quizzes where a teammate's port belongs (`muru.local.toml`),
and shows `--print-config` writing two listeners and nothing of the
table. The manifest
sets `MURU_CACHE_DIR` and `CAROOT` as Meet Muru 3 does.

- Builds on Meet Muru 3. Variables `app_port` (8080) and `https_port`
  (8443). Requires `trustme==1.2.1`.

- Length: 30 minutes.

### 7. `when-a-request-hangs`: When a request hangs

What happens to a request that never finishes, and how do you find
where it is stuck?

Ships `accounts.py` (`/report` waiting for a file, `/sync` retrying
with a bare `except:`, `/check` with a backtracking regular
expression, `/export` of 1.5 s, `/health`), `check.py`, `mixed.py`
and `docs/timeouts.md`. Page 2: soft timeout on `/report`. Page 3:
`/sync` with soft and hard timeouts, and a quiz. Page 4: `/check` with
`/health` beside it under `--timeout gil_stall=10s`, and a quiz. Page
5: `--access-log-exclude /health`, then `--access-log errors --slow
1s`.

- Builds on Meet Muru 2. Requires the pins only.

- Length: 25 minutes.

### 8. `stopping-at-a-breakpoint`: Stop a request at a breakpoint

What does `breakpoint()` do in a request under a server with worker
processes, and how do you get a debugger onto it?

Ships `checkout.py`, a shop whose `/checkout?item=NAME` calls
`breakpoint(timeout=300)` before charging `PRICES.get(item, 0)`, so a
misspelt item charges nothing, `/refund` with `breakpoint(timeout=5)`,
and `docs/breakpoints.md` (what `flask run`, `runserver`, gunicorn,
uvicorn and mod_wsgi do with a breakpoint, with a diagram). Page 2
starts the shop with `--processes 2`, quizzes what the breakpoint does
in a worker, sends `/checkout?item=teapt` in the background with the
answer to `order.txt`, and finds the waiting request with `muructl
debug status` and `muructl debug stacks`. Page 3 attaches without
`--worker`, reads `p item, price` (`('teapt', 0)`), sets `price = 12`,
continues, and checks `order.txt`. Page 4 restarts with `--timeout
soft=2s --timeout hard=8s`, quizzes whether the timeouts fire on a
waiting request, shows the request still in flight at ten seconds,
lets it go with `attach < /dev/null`, and asks for `/refund`, which
expires in five seconds and carries on. Page 5 attaches to worker 0
with nothing waiting, `import checkout`, changes `checkout.PRICES`,
and shows with `muructl debug exec` that only worker 0 changed. No
`--single`: with two workers the event names the one that waits and
`attach` finds it.

- Builds on Meet Muru 2 and workshop 7. Requires the pins only.

- Length: 20 minutes.

### Left out of the Developing collection

- **`--port auto` and `muructl serve-static`.** Checked (`--port auto`
  picks a free port for the application and prints it in the serving
  line, and leaves the dashboard on 8081), and left out to keep
  workshop 1 to its subject.

- **Worker groups, memory limits, recycling** go to the sizing
  collection; **uploads and connection limits** to the edge collection;
  **`muructl debug`** to the collection on seeing inside a running
  service; **mounts and WebSockets** beyond Meet Muru 6 to the WSGI,
  ASGI and gRPC collection.

## Naming

Directory names are kebab-case phrases naming the question a workshop
answers, not the mechanism, with no numeric prefix. Titles are sentence
case. Names are unique across the course. Collection ids are
`grahamdumpleton.me/muru/<collection>`, chosen once and never changed,
since a collection's id is its identity to subscribers and to
analytics.

Names taken: the ten Meet Muru workshops, and the eight of
Developing with muructl run.

## Later collections

Candidates, not yet designed. Each goes into depth on one area, and
each waits until its features are released.

- **Developing with muructl run**: written; see above.

- **Running Muru as a service**: the daemon, deploy and releases,
  apply, export and diff, virtual hosts and TLS, behind a proxy,
  secrets, users, logs and rotation, `daemon upgrade`, systemd.

- **Releases and traffic**: blue/green, canaries and their gates,
  bucketing, sticky sessions, previews, A/B cohorts, maintenance mode.

- **What the edge does for you**: static files, compression, file
  hints, internal redirects, error pages, authentication sub-requests,
  upstreams, connection limits, uploads, client classes, rate limits
  and overlays.

- **Sizing and keeping workers healthy**: process models, the GIL and
  free-threading, worker groups, timeouts, recycling, memory limits,
  the autoscaler, scale to zero, schedules and node budgets.

- **Seeing inside a running service**: the access log, metrics,
  events and webhooks, the dashboard, and `muructl debug` with
  profiling, tracing, memory and the debugger.

- **Moving an existing application to Muru**: from gunicorn, uvicorn,
  Granian and mod_wsgi, with managed server releases and a mapping of
  settings. Muru's own migration guides are still to be written
  (none in 0.1.0a10).

- **WSGI, ASGI and gRPC together**: mounts, WebSockets, gRPC mounts, and
  handing requests across between WSGI and ASGI once that is released
  (not in 0.1.0a10).

## Decisions that cut across the workshops

**JupyterLab only, Python 3.14.** The workshops run servers and
terminals, which JupyterLite cannot. Python 3.14 is what Binder and the
Codespaces image provide; 3.15 is acceptable where a workshop needs it
and the hosts have it.

**Muru is installed per workshop, pinned.** Each workshop declares an
`environment` whose `requirements.txt` pins `muructl` to the release in
`reference/muru`, written the PyPI way (`0.1.0a17`). An exact pin needs
no `--pre`. The runtime library, `muru`, is not installed: muructl puts
the copy matching its own version on the application's path, unpacked
once into its user cache, or into the workspace where a workshop sets
`MURU_CACHE_DIR` or runs the daemon. The Binder and Codespaces setup
puts the library's wheel for the image's Python in its wheelhouse and
names it to every session as `MURU_WHEEL_DIR` (in `binder/start` and
`.devcontainer/start.sh`), which muructl and the daemon read before
PyPI, and fills the user cache from it, so no workshop's first run
fetches anything. The extension puts the environment first on `PATH` in
the terminals, so `muructl` finds the environment's Python with no
activation step. No workshop step uses uv or `uv tool install`: uv is
not on Binder, and nothing but muructl's cache is written under the home
directory. The README tells learners to `uv tool install muructl`
afterwards, as Muru's own documentation does.

**Released features only.** A workshop uses only what is in the release
it pins. The pin, the submodule and every workshop's requirements move
together, with `just bump-muru` and a full `just test-all`.

**The format is two terminals and files, with a viewer area.** The
layout `tour` puts a named area, `viewer`, above two terminals side by
side: `server` on the left for the long-running command, `client` on
the right for requests and inspection. Documents, shipped files and
the application's pane open in the viewer area.

**Comparisons are prose and diagrams.** Where it helps, a workshop
ships Markdown documents under `files/docs/`, each with Mermaid
diagrams, and opens them with `file-open` and `:factory: Markdown
Preview` in the viewer area, where there is room to read them. The
instructions say what to look for and stay short. Other servers are
described, never installed, except in workshop 10.

**Learners never type code.** Every command and file change arrives
through an action. Shipped helpers such as `show_processes.py` do the
inspecting, so the commands on the page stay short.

**Ports are variables.** `app_port` (default 8080) for HTTP, and in
later workshops `https_port` (8443) and `dashboard_port` (8081), Muru's
own defaults. A hint on the page that starts a server says how to
change the port from the Variables dialog if it is taken. Servers bind
`127.0.0.1` only, and are stopped before the finish page.

**Progress is reported from Binder and Codespaces.** Both report
anonymous progress events to the workshops' own analytics service,
`https://workshop-analytics.grumpys.work/events`, the one the wrapt
workshops use, so it can be seen where a workshop loses people. The
sink and one ingest token are declared once, in `collection.yaml` at
the root of the repository, which `just index` copies into every
collection index; each deployment's settings only turn reporting on
with `report: always`. One token serves every collection and every
deployment: the collection is identified by the `id` in its index,
which every event carries, and the host and frontend say where the
event came from. The token is public by construction, since the
indexes are. Each welcome message tells the visitor that progress is
reported and what is never sent. Someone who subscribes from their own
JupyterLab is offered the same sink as a checkbox in the trust dialog,
off unless ticked.

**Showing a server in a pane.** Through jupyter-server-proxy at
`{{ jupyter_url }}proxy/{{ app_port }}/` under `:when: web_proxy`, with
a loopback `url-open` under `not web_proxy`. jupyter-server-proxy is a
runtime dependency in `pyproject.toml`, so it is on Binder, in
Codespaces and in a local `just lab`. HTTPS cannot be shown in a pane
through the proxy, so HTTPS and HTTP/2 are shown with curl.

**Daemon state stays in the workspace; its sockets do not.** A
workshop that runs the daemon sets `MURU_STATE_DIR`, `MURU_LOG_DIR`,
`MURU_CACHE_DIR` and `MURU_CONFIG` to paths relative to the workspace
(`muru/state` and so on) in its manifest `env`, which works because
every terminal and check runs there. The run directory cannot follow:
it must be absolute, since a release's host runs elsewhere, and short,
since a socket's path is limited to about a hundred bytes (104 on
macOS), and a workspace inside a checkout is too deep. So each such
workshop declares a variable `muru_run_dir`, exported to terminals and
checks as `MURU_RUN_DIR`, defaulting to `/tmp/muru-<word>` (`deploy`,
`canary`, `edge`, `server`), which the learner can change. A fixed
directory of the workshop's own also keeps it apart from a daemon the
learner runs, whose default on macOS is `/tmp/muru-UID`. The daemon is
started in the background with `muructl daemon start --listen
127.0.0.1:{{ app_port }}`, and stopped with `muructl daemon stop
--shutdown` before the finish page; the run directory's few small
files stay behind in `/tmp`.

**Prediction before execution, sparingly.** The audience is
experienced, so a quiz appears only where predicting the result teaches
something: a count, which process did something, what a client gets.
Never on what the page has just said.

**Checks guard what the next step needs.** A `verify` follows a step a
later page depends on, such as a server that must be up, usually a
`shell` check with curl or a shipped helper, shaped to one line on
success.

**Platforms.** `linux` and `macos`, as Muru's wheels are. Commands are
POSIX and `ps` is called with POSIX options (`-e -o pid=,ppid=,args=`)
so they work on both.

**Done** means lint is clean, `just test <name>` is green, the
workshop is in the index and the README, and its entry here is true.

## Extension features the workshops use

- `environment` with `requirements.txt`, created by `environment-create`
  as the first step of the welcome page; terminals, captures and checks
  get it on `PATH`.

- The `tour` layout: `{ name: viewer, tabs: [] }` as the placeholder
  above `terminal:server` and `terminal:client` in columns. Workshop 1
  settled it.

- `file-open` with `:factory: Markdown Preview` and `:area: viewer` for
  the documents. JupyterLab renders Mermaid blocks in the preview.

- `url-open` with `:pane: app` and `:area: viewer`, in the
  `web_proxy` pair described above, with the `web-proxy` capability.
  Sending the pane the same URL again reloads it, which is how a page
  shows a different worker answering.

- `execute` with `:wait: 3s` to start a server, `interrupt` to stop it,
  and a new `execute` with its own id to start it again.

- `editor-replace` with `:match:`, and with `:regex: true` for an edit
  across lines, to change shipped code: the greeting and the syntax
  error in workshop 3, moving the metrics start into a hook in
  workshop 4. The `write-files` capability comes with it.

- `url-open` without `:pane:` for the dashboard where there is no
  proxy, since its own loopback address is another origin and cannot
  be framed.

- Manifest `env` for settings every command needs, such as
  `MURU_CACHE_DIR` and `CAROOT` in workshop 3, with paths relative to
  the workspace.

- A `shell` check that waits for a file a helper writes, up to ten
  seconds, where the helper outlasts the check's settle time
  (`watch.log` in workshop 3).

- `shell` checks with output shaped as the style guide gives:
  `out=$(...); printf '%s\n' "$out" | tail -n 1 | grep ... || { printf
  '%s\n' "$out"; exit 1; }`.

## Known blockers

- **The daemon's sockets need a short run directory.** A release's
  worker sockets are `RUN/apps/APP/RID/RID/worker-N.sock`, about 31
  bytes plus the application's name below the run directory, and a
  path past the platform's limit (104 bytes on macOS, 108 on Linux)
  stops the edge or the release ("path must be shorter than SUN_LEN").
  `muructl daemon start` then waits its full 30 seconds before saying
  the daemon did not answer. A relative run directory lets the daemon
  start but not a release, whose workers never come up. Worked around
  with `muru_run_dir` under `/tmp`; see the decision on daemon state.
  muruhq/muru#82 makes the daemon say so at start.

- **A breakpoint under `muructl run` could not be attached to** up to
  0.1.0a10: the debug commands went through the daemon and answered
  `no daemon is running`. Fixed in 0.1.0a11 (muruhq/muru#68
  and #69): the run has an admin socket, and workshop II.8 attaches.

- **The course scaffold's welcome messages repeat the description.**
  `course init` in jupyterlab-workshop 0.30.0 writes "workshops: Guided
  JupyterLab workshops on ..." into both welcome messages and
  `AGENTS.md`. Fixed by hand here.

## Open questions

- **The analytics ingest token** is borrowed for now: `collection.yaml`
  holds the wrapture workshops' token (`sub` `wrapture-workshops`,
  expiring 2027-09-21), since the events are told apart by the
  collection id anyway. Issue one of this course's own with
  `workshop-analytics token issue --name muru-workshops --expires
  <date>`, put it in `collection.yaml` and run `just index`.

## Status

Workshops are written in collection order. Workshop 1 was written
first, on its own, to settle the format before the rest. Workshops 2
to 5 followed together, against 0.1.0a8, and then 6 to 10. All ten were
self-tested again against 0.1.0a9 when it was pinned, and workshop 6
was rewritten for its WebSocket logging and dashboard. All ten passed
their self-tests again on 0.1.0a10, which needed no change to any
workshop beyond the pin and workshop 1's note on retries.

Developing with muructl run was planned and written against 0.1.0a10
on 2026-10-28, each workshop checked against the release first and
self-tested as a copy on scratch ports.

On 2026-10-30 the pins moved to 0.1.0a11, which fixed what nine
muru-workshops issues waited on: both collections were brought up to
the release (relative paths in workshop I.9's site file, the orders
service's `SERVER_SOFTWARE`, `print()` without `flush=True`, the Flask
factory refused at load, the Flask project's static entry, the
additive `--reload-include` and project-relative `--tls-cert`,
requests answered at the hard timeout and at a stall, and the admin
socket's startup line) and workshop II.8 was written, every workshop
self-tested again.

On 2026-10-31 the pins moved to 0.1.0a12, the release that carries the
default reload and the run table (muru#85), which the two issues here
waited on: six workshops stopped passing or explaining `--reload`, the
start-up line descriptions gained the `watching` line, workshop II.1
gained a page on `[tool.muru.run]` and `muru.local.toml`, workshop II.6
gained a page moving every flag into the run table, and every workshop
self-tested again.

On 2026-11-03 the pins moved to 0.1.0a16, and `muru` left every
workshop's requirements, since muructl supplies the runtime library
itself (muru#127, muru-workshops#13): the welcome pages and READMEs
name `muructl` alone, workshop I.2 explains where the library comes
from, the Binder and Codespaces setup fills muructl's cache, and every
workshop self-tested again.

On 2026-11-04 the pins moved to 0.1.0a17. Workshop I.5 and the output
document of I.2 name the access log's file with `--access-log-file`
(muru#343, muru-workshops#16), and the Binder and Codespaces setup puts
the runtime library's wheel in its wheelhouse and names it to every
session as `MURU_WHEEL_DIR`, so the six workshops that keep muructl's
cache or the daemon's state in their workspace fetch nothing either
(muru#344, muru-workshops#14). Every workshop self-tested again.

### Meet Muru

| Workshop | Status |
| -------- | ------ |
| 1. `where-muru-fits` | Done |
| 2. `what-muructl-run-tells-you` | Done |
| 3. `reload-and-https-in-development` | Done |
| 4. `import-once-fork-safely` | Done |
| 5. `processes-threads-and-the-gil` | Done |
| 6. `wsgi-and-asgi-together` | Done |
| 7. `deploying-without-downtime` | Done |
| 8. `canary-a-release` | Done |
| 9. `what-nginx-was-for` | Done |
| 10. `bring-your-server-along` | Done |

### Developing with muructl run

| Workshop | Status |
| -------- | ------ |
| 1. `settings-in-the-project` | Done |
| 2. `serving-a-flask-project` | Done |
| 3. `serving-a-django-project` | Done |
| 4. `fastapi-on-the-event-loop` | Done |
| 5. `every-hook-in-order` | Done |
| 6. `reload-and-https-your-way` | Done |
| 7. `when-a-request-hangs` | Done |
| 8. `stopping-at-a-breakpoint` | Done |

Planned: designed in the outline, not yet written. Written: the pages
exist and lint is clean. Done: `just test <name>` is green, and the
workshop is in the index and the README.
