# Canary a release and let it roll back

Holds a new release beside the serving one on the Muru daemon, previews
it with the `Muru-Preview` header, and canaries it through 10% and 50%
of a steady stream of requests until it is promoted. Then canaries a
release with a bug, whose error rate gate rolls it back on its own
during the first step. Compares with a canary built from two
deployments and a load balancer.

About 30 minutes, in two terminals with a document and the code in an
area above them. It installs `muru` and `muructl` 0.1.0a15 into an
environment of its own, serves on port 8080 unless you change it, and
keeps the daemon's sockets in `/tmp/muru-canary`.
