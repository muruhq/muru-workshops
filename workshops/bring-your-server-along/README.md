# Try Muru without changing your deployment

Runs an application's existing gunicorn command, unchanged, as a
managed server release under the Muru daemon, deploys the same
application beside it as Muru's own workers, previews them, and moves
a steady stream of requests across with a canary judged against
gunicorn's numbers, then rolls back to gunicorn at once. The document
ends with when to choose which server. This is the one workshop that
installs another server, because running it is the point.

About 30 minutes, in two terminals with a document and the code in an
area above them. It installs `muructl` 0.1.0a16 and gunicorn into an
environment of its own, serves on port 8080 unless you change it, and
keeps the daemon's sockets in `/tmp/muru-server`.
