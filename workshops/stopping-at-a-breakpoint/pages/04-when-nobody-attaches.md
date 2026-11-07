---
title: When nobody attaches
requires: [quiz:timeouts-aside, verify:refund-went-on]
---

# When nobody attaches

A request stuck in a debugger looks, from outside, like a request
that hangs. Restart the shop with a soft timeout of two seconds and a
hard timeout of eight, and ask for a checkout again.

```{interrupt}
:id: stop-plain
:session: server
```

```{execute}
:id: start-with-timeouts
:session: server
:wait: 3s
muructl run checkout:application --port {{ app_port }} --processes 2 --timeout soft=2s --timeout hard=8s
```

```{quiz}
:id: timeouts-aside
question: "`/checkout` is asked for and stops at its breakpoint. What has happened ten seconds later?"
options:
  - { text: "The soft timeout answered 504 at two seconds, and the breakpoint waits on in a request nobody is listening to", explanation: "The soft timeout is an exception raised in the request's thread, which is exactly what a debugger must not have thrown at it." }
  - { text: "The hard timeout replaced the worker at eight seconds", explanation: "A request waiting at a breakpoint is exempt from the hard timeout as well, or a slow reader would lose the worker." }
  - { text: "Nothing: the request still waits, and both timeouts stand aside until the session ends", correct: true }
explanation: "A WSGI request waiting at breakpoint() is exempt from the soft and hard timeouts, and the loop stall and GIL stall timeouts do not count a worker that is waiting. Once a session ends, the request goes on under the timeouts as usual."
```

```{execute}
:id: ask-checkout-again
:session: client
:wait: prompt
curl -s "http://127.0.0.1:{{ app_port }}/checkout?item=cup" -o order2.txt & sleep 10; muructl debug status checkout
```

Ten seconds in, the request still holds a thread of its worker, with
THREAD-OLDEST past ten seconds, and the terminal on the left has no
timeout line. The breakpoint waits, and the timeouts wait with it.
Attach with nothing to type, so the end of input lets the request go
on at once.

```{execute}
:id: attach-nothing
:session: client
:wait: prompt
muructl debug attach checkout < /dev/null
```

When nobody attaches at all, the wait runs out. `/refund` calls
`breakpoint()` with a `timeout` of five seconds. Ask for it and wait.

```{execute}
:id: ask-refund
:session: client
:wait: prompt
curl -s "http://127.0.0.1:{{ app_port }}/refund?item=cup"
```

Five seconds, then `refunded 3 for cup`. In the terminal on the left,
`debug.breakpoint` when the wait began and `debug.breakpoint_expired:
... nobody attached to breakpoint() at .../checkout.py:21 in 5 s;
carrying on`. A breakpoint nobody attaches to is a pause: the request
goes on as if the call were not there, which is what makes
`breakpoint()` safe to leave in while you develop.

```{verify}
:id: refund-went-on
:label: The refund went on when nobody attached
:substrate: shell
:trigger: after:ask-refund
out=$(muructl logs --access --lines 5 2>&1); printf '%s\n' "$out" | grep -o '200 GET /refund[^ ]* [0-9A-Za-z]* [0-9.]*s' || { printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}" | tail -n 5; exit 1; }
```
