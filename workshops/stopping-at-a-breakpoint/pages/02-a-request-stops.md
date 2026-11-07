---
title: A request stops
requires: [quiz:under-a-worker, verify:request-waiting]
---

# A request stops

Open the document on a breakpoint in a request. It says what
`breakpoint()` does under each server, with a diagram, and what
`muructl run` makes of it.

```{file-open}
:title: Open the document on a breakpoint in a request
:path: docs/breakpoints.md
:factory: Markdown Preview
:area: viewer
```

The shop charges for an item at `/checkout?item=NAME`, and calls
`breakpoint()` just before it does, with a `timeout` of five minutes
so that it waits while you read. A name that is not in the price list
charges nothing, which is the bug you will catch.

```{file-open}
:title: Open checkout.py
:path: checkout.py
:area: viewer
```

Start the shop in the terminal on the left, with two workers.

```{execute}
:id: start-shop
:session: server
:wait: 3s
muructl run checkout:application --port {{ app_port }} --processes 2
```

```{quiz}
:id: under-a-worker
question: A request for `/checkout` reaches one of the two workers and calls `breakpoint()`. What happens?
options:
  - { text: "The pdb prompt appears in the terminal on the left, as it would under flask run", explanation: "The worker is a forked process with no terminal of its own. The runtime gives breakpoint() another meaning there." }
  - { text: "The worker stops the request where it is and waits for a debugger to attach, up to the timeout the call gives", correct: true }
  - { text: "The request fails, because pdb has nowhere to read commands from", explanation: "That is what happens under a server that leaves pdb to read from a terminal the worker does not have. Muru's workers wait instead." }
explanation: "In a worker, breakpoint() stops the request and waits for muructl debug attach, for 60 seconds or the timeout the call gives. The terminal on the left says which worker waits and the command to run."
```

Ask for the checkout of a misspelt item, in the background so the
terminal on the right stays free, with the answer written to
`order.txt`.

```{execute}
:id: ask-checkout
:session: client
:wait: 2s
curl -s "http://127.0.0.1:{{ app_port }}/checkout?item=teapt" -o order.txt &
```

The terminal on the left says `debug.breakpoint: worker 0 (pid ...):
breakpoint() at .../checkout.py:17 waits 300 s for muructl debug attach
checkout --worker 0`, or worker 1. Nothing has come back to `curl`.
The run's own commands can find the request: its worker's status
shows one of its four threads busy, under THREADS, and how long it has
waited, under THREAD-OLDEST, and the stacks show where it is.

```{execute}
:id: debug-status
:session: client
:wait: prompt
muructl debug status checkout
```

```{execute}
:id: debug-stacks
:session: client
:wait: prompt
muructl debug stacks checkout
```

```{verify}
:id: request-waiting
:label: The request waits at the breakpoint
:substrate: shell
:trigger: after:debug-stacks
out=$(muructl debug stacks checkout 2>&1); printf '%s\n' "$out" | grep -q 'breakpoint(' && printf '%s\n' "$out" | grep -o 'serving GET /checkout[^ ]* for [0-9.]* s' || { printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}" | tail -n 5; exit 1; }
```

The stack ends at the `breakpoint()` line of `checkout.py`, under the
request it is serving and how long it has waited. The command found
the run without being told where it is: `muructl run` has an admin
socket of its own, named in its startup lines, and a command run from
the project's directory uses it.
