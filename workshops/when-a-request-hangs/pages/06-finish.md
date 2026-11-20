---
title: Finish
---

# Finish

You have watched Muru deal with requests that never finish.

- The soft timeout raises `muru.RequestTimeout` in a request stuck in
  Python code, answers `504` with `reason=soft_timeout`, and says where
  the request was. The worker goes on serving.

- Code that catches the soft timeout's exception, as a bare `except:`
  does, runs on until the hard timeout replaces its worker.

- A request stuck in C code holding the GIL cannot be interrupted, and
  freezes every thread of its worker. The GIL stall timeout, on by
  default, replaces the worker.

- The request that condemned a worker is answered when the worker is
  replaced, `504` with `reason=hard_timeout`; the request that stalled
  a worker is answered `502` with `reason=worker_stalled`; and each
  thread's stack is in the log.

- `--access-log errors` with `--slow` keeps only what needs attention,
  and `--access-log-exclude` drops the health checks.

Click Finish below for where to go next.
