# Where Muru fits among Python web servers

Compares how Apache with mod_wsgi, gunicorn, uvicorn and Granian divide
the work of serving a Python web application, in short documents with
diagrams, then serves a small WSGI application under `muructl run` and
looks at the processes Muru uses instead: the edge, the host and the
workers. It ends with what happens when a request or a worker fails,
and how the same split lets the daemon run releases side by side.

About 25 minutes, in two terminals with the documents and the
application in a pane above them. It installs `muructl` 0.1.0a16 into an
environment of its own, and serves on port 8080 unless you change it.
