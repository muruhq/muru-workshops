---
title: The processes behind it
requires: [verify:three-workers, quiz:how-many-python]
---

# The processes behind it

`show_processes.py` in your workspace finds the `muructl run` serving
port {{ app_port }} and lists every process below it, saying what each
one does. Run it in the terminal on the right.

```{execute}
:id: show-one-worker
:session: client
:wait: prompt
python show_processes.py {{ app_port }}
```

There are four processes. `muructl run` is the edge and the
controller, in Rust. `muructl relay run` is the log relay, in Rust
too, which writes what the host and the workers print to the
terminal, so a terminal that stops reading never holds up a request.
The first `python -m muru.host` is the host, which imported
`hello.py`. The second has the same command line because it is a fork
of the host: that is the worker, which serves the requests with your
code already loaded. gunicorn with `--preload` starts its workers the
same way, but there each worker also talks to clients. Here the worker
only ever talks to the edge.

`muructl run` started one worker of four threads, which is plenty on a
laptop. You can ask for more.

```{quiz}
:id: how-many-python
:type: text
question: "With `--processes 3`, how many Python processes will be running for the application?"
answer: "4"
wrong:
  - { text: "3", explanation: "Three workers, but the host they were forked from is a Python process too, and it stays running to replace any worker that dies." }
  - { text: "5", explanation: "Neither muructl process is Python: the edge, the controller and the log relay are written in Rust. Count the host and the workers." }
otherwise: "Count the host, which is a Python process, and one process for each worker."
explanation: "The host plus three workers makes four. The host stays running so it can fork a replacement for any worker that dies."
```

Stop the server, then start it again with three workers of two
threads each.

```{interrupt}
:id: stop-for-three
:session: server
```

```{execute}
:id: start-three-workers
:session: server
:wait: 3s
muructl run hello:application --port {{ app_port }} --processes 3 --threads 2
```

```{execute}
:id: show-three-workers
:session: client
:wait: prompt
python show_processes.py {{ app_port }}
```

```{verify}
:id: three-workers
:label: Three workers are serving
:substrate: shell
:trigger: after:show-three-workers
out=$(python show_processes.py {{ app_port }} 2>&1); printf '%s\n' "$out" | tail -n 1 | grep '^3 workers' || { printf '%s\n' "$out"; exit 1; }
```

Load the application a few times. The edge sends each request to the
worker with the fewest requests in flight, so the worker process id
in the page can change from one load to the next.

```{url-open}
:title: Load the application again
:when: web_proxy
:url: {{ jupyter_url }}proxy/{{ app_port }}/
:pane: app
:area: viewer
```

```{url-open}
:title: Load the application again
:when: not web_proxy
:url: http://127.0.0.1:{{ app_port }}/
:pane: app
:area: viewer
```
