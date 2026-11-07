# What you would have put nginx in front for

Serves a small shop on the Muru daemon from one configuration file,
with no proxy in front, and checks with curl what the edge does that
nginx in front of an application server usually does: static files
with cache headers, conditional requests and precompressed variants,
compressed responses, a file the application names with
`X-Muru-Sendfile`, the site's own 404 page in place of the
application's, and maintenance mode. A document puts the nginx
configuration each one replaces beside it.

About 30 minutes, in two terminals with a document and the code in an
area above them. It installs `muructl` 0.1.0a20 into an environment of
its own, serves on port 8080 unless you change it, and keeps the
daemon's sockets in `/tmp/muru-edge`.
