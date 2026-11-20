---
title: A canary that fails
requires: [quiz:when-it-ends, verify:r3-rolled-back, verify:daemon-stopped]
---

# A canary that fails

The third version has a bug: one request in five fails with a 500.

```{file-open}
:title: Open releases/v3/greeter.py
:path: releases/v3/greeter.py
:area: viewer
```

Hold it as `r3`, beside `r2`.

```{execute}
:id: deploy-v3-held
:session: client
:wait: prompt
muructl deploy greeter releases/v3 --hold
```

```{quiz}
:id: when-it-ends
question: You canary `r3` with the same settings. When does the rollout end?
options:
  - { text: "After both steps have run, when the results are judged", explanation: "Gates are checked every second once the step has its minimum of requests, and a failing gate acts at once." }
  - { text: "During the 10% step, about as soon as `r3` has served 20 requests", correct: true }
  - { text: "It does not end on its own: someone has to abort it", explanation: "Rolling back on a failing gate is what the gates are for. `muructl rollout abort` is there for when you want out without one." }
explanation: "Once `r3` has served `--min-requests` in the step, its 5xx rate of about 20% is checked every second against the 1% limit and against `r2`'s, which is 0%. The gate fails, and the rollout takes `r3` out at once."
```

```{execute}
:id: canary-r3
:session: client
:wait: prompt
muructl rollout canary greeter@r3 --steps 10,50 --hold 10s --min-requests 20 --wait
```

In the terminal on the left, `release r3` takes about one answer in
ten, with errors beside it, for a few seconds at most, then the
answers are all `release r2` again.

```{execute}
:id: status-r3
:session: client
:wait: prompt
muructl rollout status greeter
```

The message says which gate failed, at which step, and with what
numbers, `r3`'s 5xx rate beside `r2`'s. `r3` is out of traffic and
kept for ten minutes, so its logs and workers can be looked at. The
list may show it `draining` for a moment, then `retained`, kept for
inspection and not a rollback target:

```{execute}
:id: list-r3
:session: client
:wait: prompt
muructl release list greeter
```

```{verify}
:id: r3-rolled-back
:label: The canary of r3 rolled back
:substrate: shell
:trigger: after:status-r3
out=$(muructl rollout status greeter 2>&1); printf '%s\n' "$out" | grep ' r3 .*rolled_back' || { printf '%s\n' "$out"; exit 1; }
```

Stop the traffic. Its totals count every answer from each release,
with the errors `r3` gave while it had its share.

```{interrupt}
:id: stop-traffic
:session: server
```

You have finished with the daemon. `--shutdown` drains every release,
stops the hosts and the edge, then the daemon.

```{execute}
:id: stop-daemon
:session: client
:wait: prompt
muructl daemon stop --shutdown
```

```{verify}
:id: daemon-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-daemon
if curl -s -o /dev/null --max-time 2 http://127.0.0.1:{{ app_port }}/; then echo "Something still answers on port {{ app_port }}. Stop the daemon with the action above."; exit 1; fi; echo "The daemon and everything under it have stopped."
```
