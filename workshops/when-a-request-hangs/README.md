# When a request hangs

Serves a small accounts service with three ways to hang: a view that
waits for a file that never appears, a retry loop whose bare `except:`
swallows the soft timeout's exception, and a user name check whose
regular expression backtracks, inside C code holding the GIL, for
longer than anyone will wait. Shows the soft timeout interrupting the
first and saying where it was, the hard timeout replacing the worker
running the second, the GIL stall timeout replacing the worker frozen
by the third while an innocent request on the same worker waits with
it, and `--access-log errors`, `--slow` and `--access-log-exclude`.
Compares with gunicorn, uvicorn and mod_wsgi.

About 25 minutes, in two terminals with a document and the code in an
area above them. It installs `muructl` 0.1.0a17 into an environment of
its own, and serves on port 8080 unless you change it.
