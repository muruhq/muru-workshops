# Serve an app and read what it tells you

Serves a small Flask application under `muructl run` and works through
what it reports while you develop: the startup lines, the access log
and its `--access-log errors` mode, your code's output tagged by the
worker that wrote it, the development error page with the traceback in
a browser pane, the same error as a problem document for an API client,
the request id that ties them together, and the dashboard. Compares
throughout with what gunicorn and uvicorn report.

About 25 minutes, in two terminals with a document, the application
and the dashboard in a pane above them. It installs `muru` and
`muructl` 0.1.0a15 and Flask into an environment of its own, and serves
on port 8080 with the dashboard on 8081 unless you change them.
