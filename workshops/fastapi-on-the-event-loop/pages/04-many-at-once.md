---
title: Many at once
requires: [verify:more-sync-threads]
---

# Many at once

Each `/wait` path operation waits a fifth of a second, a different
way: `await asyncio.sleep`, `time.sleep` in a plain `def`, and
`time.sleep` handed to `asyncio.to_thread`. `load.py` sends fifty
requests to one of them at once and says how long they took. Start
with the `async def`.

```{execute}
:id: load-async
:session: client
:wait: prompt
python load.py {{ app_port }} /wait/async 50
```

About a quarter of a second: all fifty waited on the loop together,
each as a task that awaited. Now the plain `def`.

```{execute}
:id: load-sync
:session: client
:wait: prompt
python load.py {{ app_port }} /wait/sync 50
```

About a second and a half, seven rounds: FastAPI hands a plain `def`
to AnyIO's threads, but Muru limits AnyIO to its own eight sync
threads, so all but eight waited for one. Now `asyncio.to_thread`.

```{execute}
:id: load-to-thread
:session: client
:wait: prompt
python load.py {{ app_port }} /wait/to-thread 50
```

About a second and a half again: seven rounds of the same eight.
`--sync-threads` sizes both, the pool behind `asyncio.to_thread` and
how many threads AnyIO may use, so it is the one to size for an
application with many plain `def` path operations, that hands much of
its work to `asyncio.to_thread`, or that runs Django's `sync_to_async`.
Stop the service and start it with fifty.

```{interrupt}
:id: stop-one
:session: server
```

```{execute}
:id: start-fifty
:session: server
:wait: 4s
muructl run main:app --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --sync-threads 50
```

```{execute}
:id: load-to-thread-again
:session: client
:wait: prompt
python load.py {{ app_port }} /wait/to-thread 50
```

```{verify}
:id: more-sync-threads
:label: Fifty sync threads take fifty at once
:substrate: shell
:trigger: after:load-to-thread-again
out=$(python load.py {{ app_port }} /wait/to-thread 50 2>&1); s=$(printf '%s\n' "$out" | sed -n 's/.* took \([0-9.]*\) s$/\1/p'); [ -n "$s" ] && python -c "import sys; sys.exit(0 if float('$s') < 1.0 else 1)" && echo "$out" || { echo "${out:-Nothing answers on port {{ app_port }}.} Start the service with --sync-threads 50 with the action above."; exit 1; }
```

A quarter of a second again. Neither pool limits the loop itself:
`--concurrency`, a thousand by default, is how many requests a worker
holds at once, and the edge queues the rest.
