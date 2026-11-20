---
title: The processes behind it
requires: [verify:three-workers, quiz:how-many-python]
---

# The processes behind it

`muructl status --processes` asks the run for every process it started
and lists them as a tree, saying what each one is for. Run from the
directory the run was started in, as here, it finds the run on its
own. Run it in the terminal on the right.

```{execute}
:id: show-one-worker
:session: client
:wait: prompt
muructl status --processes
```

The first line is the edge's figures over the last second. Below it
are four processes. `run` is `muructl run` itself, the edge and the
controller, in Rust, with the port it serves. `host` is a Python
process that imported `hello.py`, with the release it belongs to,
`r1`. Under it, `relay` is the host's log relay, in Rust too, which
writes what the host and the workers print to the terminal, so a
terminal that stops reading never holds up a request. `worker` is a
fork of the host, worker 0, which serves the requests with your code
already loaded. gunicorn with `--preload` starts its workers the same
way, but there each worker also talks to clients. Here the worker only
ever talks to the edge.

Each row gives the process's uptime, CPU and memory, and a worker's
`BUSY` how many of its threads are serving a request. `ps` shows the
same processes by the names they give themselves, such as `muru worker
hello@r1 default/0 (run:{{ app_port }})`: the role, the release, the
worker's group and number, and the Muru instance it belongs to.

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
muructl run hello:application --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --processes 3 --threads 2
```

```{execute}
:id: show-three-workers
:session: client
:wait: prompt
muructl status --processes
```

```{verify}
:id: three-workers
:label: Three workers are serving
:substrate: shell
:trigger: after:show-three-workers
out=$(muructl status --processes 2>&1); n=$(printf '%s\n' "$out" | grep -c ' worker  '); if [ "$n" = 3 ]; then echo "3 workers are serving"; else printf '%s\n' "$out"; exit 1; fi
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
