---
title: Finish
---

# Finish

You have fitted reload and HTTPS to a project.

- A development run reloads on change, counting `**/*.py` under the
  project's directory as source. `--reload-include` adds patterns to
  that, `--reload-exclude` keeps files the application writes from
  starting a release, and an exclude wins over an include, so
  `--reload-exclude '**/*.py'` watches the included patterns alone.
  `--no-reload` turns reloading off for a run.

- A reload starts the new release beside the old one. A request in
  flight finishes on the old release, with the old code.

- `--host` adds a name to the development certificate, `--https-only`
  answers plain HTTP with a 307 to the same path over HTTPS, and
  `--tls-cert` with `--tls-key` serves a certificate of your own, read
  from the project's directory.

- Every one of those flags has a key in the project's `[tool.muru.run]`
  table, so `muructl run` on its own serves a checkout the way the
  project says. A flag wins over the table for one run, and a
  `muru.local.toml` beside the project holds one machine's own `[run]`
  table. `--print-config` shows which settings came from the table, and
  `muructl render` shows that the daemon gets none of them.

Click Finish below for where to go next.
