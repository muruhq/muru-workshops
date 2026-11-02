# Reload, HTTPS and HTTP/2 on your laptop

Compares what gunicorn's and uvicorn's `--reload` and a `muructl run`
development run, which reloads without a flag, replace when a file
changes, in a short document with diagrams, then reloads a small WSGI
application under `muructl run` while a client keeps asking for it: a
change switches to a new release with no request refused, and a change
with a syntax error leaves the previous release serving. Then serves
the same application over HTTPS with a development certificate and
shows HTTP/2 negotiated over TLS with curl.

About 20 minutes, in two terminals with a document and the application
in an area above them. It installs `muru` and `muructl` 0.1.0a15 into an
environment of its own, and serves on ports 8080 and 8443 unless you
change them.
