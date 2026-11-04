# Deploy without dropping a request

Starts the Muru daemon, with its state, logs and cache in the
workspace, deploys a small application, then deploys a new version
and rolls it back while a steady stream of requests runs, counting the
requests that go unanswered: none. Lists the daemon, the edge and each
release's host and workers. Compares with gunicorn's `HUP` and `USR2`,
a mod_wsgi daemon restart, and two deployments behind a load balancer.

About 30 minutes, in two terminals with a document and the code in an
area above them. It installs `muructl` 0.1.0a17 into an environment of
its own, serves on port 8080 unless you change it, and keeps the
daemon's sockets in `/tmp/muru-deploy`.
