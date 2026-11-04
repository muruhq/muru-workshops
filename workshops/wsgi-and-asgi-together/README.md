# WSGI and ASGI from one server

Serves a Flask application at `/` and a FastAPI application at `/api`
from the same Muru worker processes, declared as mounts in the
project's `pyproject.toml`, shows the prefix each one sees
(`SCRIPT_NAME` for WSGI, `root_path` for ASGI), and talks to the
FastAPI side over WebSockets from a browser pane and from the
terminal, reading each socket's two access log lines and the sockets
open on the dashboard. Compares with what gunicorn, uvicorn, Granian
and mod_wsgi take, and the two servers and proxy the same site usually
needs.

About 25 minutes, in two terminals with a document, the code and the
site in an area above them. It installs `muructl` 0.1.0a17, Flask,
FastAPI and `websockets` into an environment of its own, and serves on
port 8080, with the dashboard on 8081, unless you change them.
