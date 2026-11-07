---
title: Blocking the loop
requires: [quiz:blocking-fifty, verify:stall-replaced, verify:service-stopped]
---

# Blocking the loop

`/wait/blocking` is an `async def` that calls `time.sleep(0.2)`
instead of awaiting: the mistake of calling a blocking library from a
coroutine.

```{quiz}
:id: blocking-fifty
question: "Twenty requests to `/wait/blocking` arrive at once. About how long until the last is answered?"
options:
  - { text: "About four seconds: each holds the loop for a fifth of a second, one after another", correct: true }
  - { text: "About a fifth of a second, as for the async def that awaits", explanation: "A task that never awaits never gives the loop back, so the others cannot run meanwhile." }
  - { text: "About a fifth of a second, because Muru moves blocking calls to threads", explanation: "Nothing can move a call that is already running on the loop. Only the code can hand it to a thread." }
explanation: "time.sleep holds the loop's thread. Twenty of them run one after another, twenty times a fifth of a second."
```

```{execute}
:id: load-blocking
:session: client
:wait: prompt
python load.py {{ app_port }} /wait/blocking 20
```

About four seconds. Every other request to this worker waited behind
them too, whatever its path.

A call that blocks for much longer is what the loop stall timeout is
for. `/stall` blocks the loop for thirty seconds. Restart the service
with a loop stall timeout of five seconds.

```{interrupt}
:id: stop-fifty
:session: server
```

```{execute}
:id: start-stall
:session: server
:wait: 4s
muructl run main:app --port {{ app_port }} --timeout loop_stall=5s
```

`stall.py` asks for `/stall`, and a second later for `/where/async`,
an innocent request that would normally take a millisecond. It takes
about five seconds to report.

```{execute}
:id: run-stall
:session: client
:wait: prompt
python stall.py {{ app_port }}
```

```{verify}
:id: stall-replaced
:label: The stalled worker was replaced
:substrate: shell
:trigger: after:run-stall
out=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/where/async); printf '%s\n' "$out" | grep -o '"thread":"muru-loop"' && echo "A new worker serves." || { echo "${out:-Nothing answers on port {{ app_port }}.}"; exit 1; }
```

Both requests got `502`. In the terminal on the left:

- five seconds in, the event `worker.loop_stalled: worker 0 (pid
  ...): the event loop has not run for 5.1 s, past the loop stall
  timeout of 5 s`, then `replacing it`, the two access log lines,
  `502` with `reason=worker_stalled`, a new worker started, and `gave
  up 2 requests for the edge to answer`;

- the stalled worker's threads' stacks, with `muru-loop` in `stall` at
  `main.py`'s `time.sleep(30)`, which is where to look, then the new
  worker's `is ready`;

- about fifteen seconds later, after the hard drain grace and the
  shutdown timeout, `did not stop, killing` and `replaced by pid ...`.

The innocent request shared the stalled worker's loop, so it shared
its fate, and both were answered the moment the stall was caught: a
stalled loop can finish nothing, so there is nothing to wait for. The
timeout bounded how long the worker held requests; only the code can
save them, by awaiting, or by handing the call to a thread.

You have finished with the service. Stop it in the terminal on the
left.

```{interrupt}
:id: stop-service
:session: server
```

```{verify}
:id: service-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-service
for i in 1 2 3 4 5; do curl -s -o /dev/null --max-time 1 http://127.0.0.1:{{ app_port }}/prices || { echo "The service has stopped."; exit 0; }; sleep 1; done; echo "The service still answers on port {{ app_port }}. Stop it with the action above."; exit 1
```
