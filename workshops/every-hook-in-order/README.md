# Hooks from load to exit

Runs a hooks module with all seven of Muru's lifecycle hooks, each
printing where it ran, and reads their order from the terminal: at
startup, through a reload that replaces the workers, when a worker
gets `SIGUSR1` to reopen its logs, when workers import the application
themselves with `--preload false`, and around an ASGI application's
lifespan. Compares with gunicorn's server hooks.

About 25 minutes, in two terminals with a document and the code in an
area above them. It installs `muructl` 0.1.0a20 into an environment of
its own, and serves on port 8080 unless you change it.
