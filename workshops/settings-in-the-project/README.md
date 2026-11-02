# Keep the run settings with the project

Starts a small WSGI project under a long `muructl run` command line,
then moves its settings into the project: what the application is,
the processes, threads, hooks module, a timeout and an environment
variable, into `[tool.muru]`; how a checkout is served, the port and
the access log, into `[tool.muru.run]`; and one machine's own port
into a `muru.local.toml` that is never committed, with the warning the
run gives until `.gitignore` names it. Shows that a flag wins over all
of them for one run, what a misspelt key does, and what `muructl run
--print-config` writes for the daemon, with nothing of the run table
in it. Compares with where gunicorn, uvicorn, Granian and mod_wsgi
keep their settings.

About 25 minutes, in two terminals with a document and the project's
files in an area above them. It installs `muru` and `muructl`
0.1.0a15 into an environment of its own, and serves on ports 8080 and
8090 unless you change them.
