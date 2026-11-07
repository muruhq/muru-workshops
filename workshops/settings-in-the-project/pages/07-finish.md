---
title: Finish
---

# Finish

You have moved a project's server settings into the project.

- gunicorn keeps settings in a Python file and four other places,
  uvicorn and Granian on the command line and in environment
  variables, and mod_wsgi in the Apache configuration. Muru keeps them
  in a `[tool.muru]` table in `pyproject.toml`, or in a `muru.toml`.

- `[tool.muru]` holds what the application is wherever it runs: its
  entrypoint, processes, threads, hooks, timeouts and environment
  variables. `[tool.muru.run]` holds how a checkout is served while
  someone works on it: the port, HTTPS, the reload patterns, the access
  log and the dashboard, each a flag of `muructl run` as a key. A
  `muru.local.toml` beside the project holds one machine's own `[run]`
  table, never committed, and the run warns until `.gitignore` names
  it.

- A flag wins over the local file, and the local file over the
  project's tables, for one run; a key a table does not know stops the
  run with a list of the keys it does.

- `--print-config` prints the settings a run would use and where each
  came from. `muructl render` writes the release a deploy would make,
  in the daemon's format, from `[tool.muru]` alone, with nothing of
  the run table, which the daemon never reads.

Click Finish below for where to go next.
