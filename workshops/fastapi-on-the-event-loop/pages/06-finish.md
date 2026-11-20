---
title: Finish
---

# Finish

You have found out what runs where on a worker's event loop.

- The lifespan runs once in each worker, after the fork and before
  the worker takes a request. One that fails at startup fails the
  worker, and `muructl run` stops after three failures.

- `async def` runs on the loop, `muru-loop`. A plain `def` path
  operation runs on AnyIO's threads, and `asyncio.to_thread` and
  `sync_to_async` on Muru's sync threads. `--sync-threads`, eight by
  default, limits both.

- A blocking call on the loop holds every request in the worker. The
  loop stall timeout replaces a worker whose loop has not run for its
  length, and the requests the stalled worker held are answered `502
  worker_stalled` at once, with its stacks in the log to say where it
  was.

Click Finish below for where to go next.
