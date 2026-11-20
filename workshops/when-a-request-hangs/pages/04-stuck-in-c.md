---
title: Stuck in C
requires: [quiz:soft-and-regex, verify:gil-stall-replaced]
---

# Stuck in C

`/check` validates a user name with `^([a-z]+)+$`. For a name of
thirty-four letters and a `!`, the nested `+` makes the matcher try
every way of splitting the letters before it gives up, which takes far
longer than anyone will wait. The matching happens in the `re`
module's C code, which holds the GIL throughout.

```{editor-highlight}
:id: show-pattern
:title: Show the pattern in accounts.py
:path: accounts.py
:match: USER_NAME = re.compile
```

```{quiz}
:id: soft-and-regex
question: "`/check` is asked about the long name, with the two second soft timeout set. What does the soft timeout do?"
options:
  - { text: "Nothing it can act on: its exception waits for the thread to run Python, which it does not until the match returns", correct: true }
  - { text: "It interrupts the match after two seconds and answers 504, as for /report", explanation: "The soft timeout is an exception raised in the thread, and a thread inside a C call that holds the GIL runs no Python to raise it in." }
  - { text: "It kills the thread running the match", explanation: "Python threads cannot be killed from outside; the soft timeout can only raise an exception in one." }
explanation: "While a C call holds the GIL, no Python runs in any thread of the worker, so nothing in the worker can act. A watchdog outside Python has to."
```

That watchdog is the GIL stall timeout, which replaces a worker in
which no thread has run Python for its length, thirty seconds by
default, with or without a request in flight. Restart the service with
it shortened to ten seconds, so the wait is shorter.

```{interrupt}
:id: stop-hard
:session: server
```

```{execute}
:id: start-gil
:session: server
:wait: 3s
muructl run accounts:application --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --timeout soft=2s --timeout gil_stall=10s
```

`check.py` asks `/check` about the long name and, a second later, asks
`/health`, an innocent request that answers at once. It reports when
both are done, `/check` in about ten seconds and `/health` some
fifteen seconds later.

```{execute}
:id: run-check
:session: client
:wait: prompt
python check.py {{ app_port }}
```

```{verify}
:id: gil-stall-replaced
:label: A new worker serves after the GIL stall timeout
:substrate: shell
:trigger: after:run-check
curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/health | grep '^ok$' && echo "A new worker serves." || { echo "Nothing answers /health on port {{ app_port }}. Check the terminal on the left."; exit 1; }
```

Both got `502`. In the terminal on the left:

- no soft timeout line at all: the thread never ran Python to raise
  it in;

- ten seconds in, the event `worker.gil_stalled: worker 0 (pid ...):
  no thread has run Python for 10... s, past the GIL stall timeout of
  10 s`, the line saying the worker is being replaced, `/check`'s
  access log line, `502` with `reason=worker_stalled`, a new worker,
  and `gave up 2 requests for the edge to answer`;

- each thread's stack, written by `faulthandler`, which needs no GIL,
  one of them at the `USER_NAME.match` line of `accounts.py`, then
  `replaced by pid ...`;

- about fifteen seconds later, `did not stop, killing`, `/health`'s
  access log line, `502` with `reason=worker_crashed`, and `exited
  after its drain grace`.

`/health` was never stuck itself. It went to the same worker, whose
four threads could not run a line of Python while the match held the
GIL, so it shared the stuck request's fate: a stalled worker cannot
finish anything. The host gave both requests up for the edge to
answer at once, as `gave up 2` says, and that is what Muru intends:
every request a stalled worker held answered `502` with
`reason=worker_stalled` when the stall is caught. In this release the
edge answers only the stuck one then, and `/health` waits for the old
worker to be killed (muruhq/muru#836). A hard timeout, had one been set, would have
replaced this worker at its length too, since a request was in flight,
answering it `504` with `reason=hard_timeout`; the GIL stall timeout
is the one that also catches a stall with no request at all, in a
hook or a background thread. The fix is in the code again: the nested
`+` adds nothing, and `^[a-z]+$` matches the same names in one pass.
