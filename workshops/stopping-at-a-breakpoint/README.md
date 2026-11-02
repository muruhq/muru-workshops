# Stop a request at a breakpoint

Serves a small shop whose checkout calls `breakpoint()` before it
charges. Shows the worker waiting for a debugger under `muructl run`,
with the soft and hard timeouts standing aside, `muructl debug status`
and `muructl debug stacks` finding the request, and `muructl debug
attach` opening pdb on it from the other terminal, where the price it
is about to charge is read and changed before the request goes on. A
breakpoint nobody attaches to expires and the request carries on, and
a session in a worker with no breakpoint waiting runs on a thread of
its own and changes that one worker's state. Compares with what
`breakpoint()` does under `flask run`, `runserver`, gunicorn and
mod_wsgi.

About 20 minutes, in two terminals with a document and the code in an
area above them. It installs `muru` and `muructl` 0.1.0a15 into an
environment of its own, and serves on port 8080 unless you change it.
