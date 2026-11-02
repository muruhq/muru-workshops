# Processes, threads and the GIL

Maps gunicorn's, mod_wsgi's, uvicorn's and Granian's process and
thread settings onto Muru's `--processes` and `--threads`, in a short
document with diagrams, then loads a view that waits and a view that
computes under one thread, eight threads, and two processes of four. A
shipped load script reads the edge's `queue` and `app` times for each
request from the JSON access log, which show threads helping the view
that waits and only processes helping the view that computes.
Free-threaded Python is described.

About 30 minutes, in two terminals with a document and the application
in an area above them. It installs `muru` and `muructl` 0.1.0a15 into an
environment of its own, and serves on port 8080 unless you change it.
