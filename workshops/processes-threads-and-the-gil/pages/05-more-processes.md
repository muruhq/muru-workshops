---
title: More processes
requires: [quiz:what-limits-processes, verify:two-processes-up, verify:server-stopped]
---

# More processes

Each process has a GIL of its own, so two processes can run Python at
the same time, given a CPU each. Keep eight threads in all, as two
processes of four.

```{quiz}
:id: what-limits-processes
question: What limits how much more processes help `/compute`?
options:
  - { text: "The number of CPUs the processes can run on", correct: true }
  - { text: "The number of threads in each process", explanation: "Threads take turns at their process's GIL. Adding them did not help `/compute` on the last page." }
  - { text: "The size of the edge's queue", explanation: "The edge only holds requests until a thread is free. It does not limit how fast they are served once they have one." }
explanation: "A process computing in Python keeps a CPU busy. Two processes can compute twice as fast only with two CPUs to run on, and beyond the number of CPUs more processes only take turns."
```

Stop the application, then start it with two processes of four
threads.

```{interrupt}
:id: stop-eight-threads
:session: server
```

```{execute}
:id: start-two-processes
:session: server
:wait: 3s
muructl run work:application --port {{ app_port }} --processes 2 --threads 4 --access-log-file requests.jsonl
```

```{verify}
:id: two-processes-up
:label: The application answers on port {{ app_port }}
:substrate: shell
:trigger: after:start-two-processes
curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/
```

```{execute}
:id: load-two-processes
:session: client
:wait: prompt
python load.py {{ app_port }} /wait /compute
```

`/wait` is as fast as with eight threads in one process, since there
are still eight threads. With two or more CPUs, as the first line
reports, `/compute` now serves about twice as many requests a second
as before, and its `app` time halves. With one CPU it cannot: the two
processes take turns on it.

That is the general rule on a regular interpreter: threads for views
that wait, and processes, up to the number of CPUs, for views that
compute. Most applications do some of each, so the right numbers for
production come from measuring under real traffic, which the `queue`
and `app` times in the access log let you do.

The document's last section, "Free-threaded Python", is about the
interpreter build without the GIL, where one process of many threads
can do what this page needed two processes for. Read it before you
finish.

You have finished with the application. Stop it in the terminal on the
left.

```{interrupt}
:id: stop-server
:session: server
```

```{verify}
:id: server-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-server
if curl -s -o /dev/null --max-time 2 http://127.0.0.1:{{ app_port }}/; then echo "The application still answers on port {{ app_port }}. Stop it with the action above."; exit 1; fi; echo "The application has stopped."
```
