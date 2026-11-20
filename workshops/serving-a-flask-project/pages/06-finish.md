---
title: Finish
---

# Finish

You have served a Flask project under `muructl run`.

- A factory has to be named as one, with `factory = true` or
  `--factory`. Otherwise Muru refuses it at load, naming the setting
  to add.

- Named, it runs in each worker after the fork, so the database pool
  it opens belongs to that worker. `factory_phase = "host"` builds the
  application once in the host, as gunicorn's `--preload` does, and
  shares whatever the factory opened between the workers.

- Muru sets the root logger's level before the project is imported,
  `WARNING` unless the table's `[tool.muru.logging.python]` says
  otherwise, and each record arrives tagged with its worker.

- `FLASK_PROPAGATE_EXCEPTIONS` in the table's `env`, read by the
  factory's `from_prefixed_env()`, lets Muru answer for a failing view
  with its error page and `reason=app_error`.

- Flask serves its static files from a worker until the project's
  `[[tool.muru.static]]` entry names the directory, after which the
  edge serves them, under `muructl run` and the daemon alike.

Click Finish below for where to go next.
