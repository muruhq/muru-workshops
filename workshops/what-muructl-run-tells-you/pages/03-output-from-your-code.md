---
title: Output from your code
requires: [quiz:where-logging-goes]
---

# Output from your code

The product view prints a line before it looks the product up. Ask
for a product from the terminal on the right.

```{execute}
:id: get-product
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/products/2
```

Two lines appear in the terminal on the left. The first is what the
view printed, tagged `muru.worker[N].stdout:` with the index of the
worker that ran it. The second is the edge's access log line for the
request: the status, method and path, the size, the total time, then
`queue` (how long the request waited for a free worker thread), `app`
(how long your code took), the worker and the request id.

Under gunicorn or uvicorn the printed line would arrive as it is, with
nothing to say which worker printed it.

The report view logs a warning with Python's `logging` before it does
something slow.

```{quiz}
:id: where-logging-goes
question: Python's `logging` writes to standard error unless configured otherwise. How will the warning from the report view be tagged?
options:
  - { text: "`muru.worker[N].stdout:`, like the printed line", explanation: "That tag is for standard output. The log relay tags standard error separately." }
  - { text: "`muru.worker[N]:`, for the worker's standard error", correct: true }
  - { text: "`muru:`, because muructl writes the log", explanation: "Lines starting `muru:` come from muructl itself. Your code's output is written by the release's log relay, tagged with the worker." }
explanation: "The log relay, a small process beside the host, writes each worker's standard error tagged `muru.worker[N]:` and its standard output tagged `muru.worker[N].stdout:`. Logging needs no configuring to arrive tagged."
```

```{execute}
:id: get-report
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/report
```

The warning arrives tagged with the worker, and the access log line
for the report shows about 1.5 seconds, nearly all of it `app`: the
time was spent in your code, not waiting for a worker.
