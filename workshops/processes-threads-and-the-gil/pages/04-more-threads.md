---
title: More threads
requires: [quiz:compute-with-threads, verify:eight-threads-up]
---

# More threads

Eight threads would give every request a thread at once. The view that
waits will clearly benefit.

```{quiz}
:id: compute-with-threads
question: With one process of eight threads, what happens to `/compute`?
options:
  - { text: "About eight times as many requests a second, and no queue", explanation: "The queue does empty, since every request gets a thread. But only one thread at a time can run Python on a regular interpreter." }
  - { text: "About the same requests a second, with the waiting moved from `queue` into `app`", correct: true }
  - { text: "No change at all: the same `queue` and `app` times", explanation: "Each request does get a thread straight away, so the edge's queue empties. The question is what the request does with the thread." }
explanation: "Every request gets a thread at once, so `queue` drops to nothing. But the eight threads take turns at the GIL, so each request's tenth of a second of computing is spread across about eight times as long, and `app` grows by what `queue` lost."
```

Stop the application, then start it with eight threads.

```{interrupt}
:id: stop-one-thread
:session: server
```

```{execute}
:id: start-eight-threads
:session: server
:wait: 3s
muructl run work:application --port {{ app_port }} --processes 1 --threads 8 --access-log-file requests.jsonl
```

```{verify}
:id: eight-threads-up
:label: The application answers on port {{ app_port }}
:substrate: shell
:trigger: after:start-eight-threads
curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/
```

```{execute}
:id: load-eight-threads
:session: client
:wait: prompt
python load.py {{ app_port }} /wait /compute
```

`/wait` now serves about eight times as many requests a second, with
no queue and `app` back at a tenth of a second: while one thread
sleeps, the others can run.

`/compute` serves about the same as before. Its `queue` emptied, but
its `app` time grew by the same amount: each request had a thread, and
spent the time waiting for the GIL instead of waiting in the edge's
queue. A large `app` time on a view that should be quick, with no
`queue`, is what that looks like.
