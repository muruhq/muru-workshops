---
title: Where each kind runs
requires: [quiz:where-def-runs, verify:three-places]
---

# Where each kind runs

Start the service again, with one worker, so every request goes to the
same event loop.

```{execute}
:id: start-one
:session: server
:wait: 4s
muructl run main:app --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

Each `/where` path operation answers with the thread it ran on. The
first is an `async def`, which runs on the worker's event loop.

```{execute}
:id: where-async
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/where/async; echo
```

`muru-loop`, the thread the worker runs its event loop on. The next is
a plain `def`.

```{quiz}
:id: where-def-runs
question: "`/where/sync` is a plain `def` path operation. Which thread does it run on?"
options:
  - { text: "One of AnyIO's worker threads, where FastAPI sends plain def path operations", correct: true }
  - { text: "muru-loop, like the async def", explanation: "FastAPI never runs a plain def on the loop, since it might block it." }
  - { text: "One of Muru's sync threads, muru-sync_N", explanation: "Those are the loop's default executor, which asyncio.to_thread uses. FastAPI uses AnyIO's own threads instead." }
explanation: "FastAPI runs a plain def path operation with AnyIO's to_thread.run_sync, on AnyIO's worker threads. Muru's sync threads serve asyncio.to_thread and sync_to_async, and Muru limits AnyIO's threads to as many."
```

```{execute}
:id: where-sync
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/where/sync; echo
```

`AnyIO worker thread`. The last is an `async def` that hands the work
to a thread with `asyncio.to_thread`.

```{execute}
:id: where-to-thread
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/where/to-thread; echo
```

```{verify}
:id: three-places
:label: The three kinds run in three places
:substrate: shell
:trigger: after:where-to-thread
a=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/where/async); s=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/where/sync); t=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/where/to-thread); case "$a $s $t" in *muru-loop*AnyIO*muru-sync_*) echo "muru-loop, AnyIO worker thread, muru-sync";; *) printf '%s\n%s\n%s\n' "${a:-Nothing answers on port {{ app_port }}.}" "$s" "$t"; exit 1;; esac
```

`muru-sync_0`, one of Muru's sync threads: the loop's default
executor, which Muru sizes with `--sync-threads`. All three are in the
same worker process, and the same request could have used all three.
