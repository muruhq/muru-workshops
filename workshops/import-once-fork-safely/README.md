# Import once, fork safely

Shows what a fork leaves behind when an application opens a socket and
starts a thread at import, as it would under gunicorn `--preload`: the
child has the same socket and none of the threads. Then serves the
application under `muructl run`, whose import check finds both before
it forks, falls back to an import in each worker under the default
`--preload auto` and refuses to start under `--preload true`, and moves
the work into a `post_fork` hook so the workers are forked from a
preloaded host again. Compares with gunicorn, mod_wsgi and uvicorn in a
short document with diagrams.

About 25 minutes, in two terminals with a document and the application
in an area above them. It installs `muructl` 0.1.0a16 into an
environment of its own, and serves on port 8080 unless you change it.
