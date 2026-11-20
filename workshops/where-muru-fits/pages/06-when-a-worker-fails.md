---
title: When a request or a worker fails
requires: [verify:worker-replaced, quiz:crash-answer]
---

# When a request or a worker fails

`hello.py` fails on purpose at two paths. `/boom` raises an exception
in your code. Send a request to it.

```{execute}
:id: curl-boom
:session: client
:wait: prompt
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:{{ app_port }}/boom
```

The status is 500. The terminal on the left shows the traceback,
tagged with the worker that raised it, and the access log line ends
`reason=app_error`. An exception in your code fails the request, not
the worker, which goes on serving.

`/crash` is worse: it ends the worker process outright, in the middle
of the request, as a segfault in a C extension or a call to
`os._exit()` would. Under gunicorn the master forks a replacement
worker, and the client's connection, which belonged to the worker that
died, is cut off, unless nginx is in front to answer for it. Here the
client's connection belongs to the edge. The request is a POST, the
kind that changes something on the server.

```{quiz}
:id: crash-answer
question: What will curl get back when the worker serving its POST dies?
options:
  - { text: "Nothing: the connection is closed with no response", explanation: "The connection is the edge's, and the edge is still running, so it can still answer." }
  - { text: "A 500 from the host, which saw its worker die", explanation: "The host forks a replacement, but it never handles requests." }
  - { text: "A 502 from the edge, saying the worker crashed", correct: true }
  - { text: "A 200, because the edge sends the request to another worker", explanation: "The edge sends a request to another worker only when no worker has read it yet. This one was read, and a POST may have changed something before the worker died, so sending it again could do that twice. The edge answers for the worker instead." }
explanation: "The edge answers 502 Bad Gateway with the reason `worker_crashed`, and the host forks a new worker to take the dead one's place."
```

```{execute}
:id: curl-crash
:session: client
:wait: prompt
curl -s -X POST -w '%{http_code}\n' http://127.0.0.1:{{ app_port }}/crash
```

The edge answered 502 with a short body giving the reason and the
request id. In the terminal on the left, the host reports that the
worker exited and that it started a new one. List the processes again:
one worker has a new process id and has been up only a few seconds,
and the host's is the same.

```{execute}
:id: show-after-crash
:session: client
:wait: prompt
muructl status --processes
```

```{verify}
:id: worker-replaced
:label: The host replaced the worker that died
:substrate: shell
:trigger: after:show-after-crash
out=$(muructl status --processes 2>&1); n=$(printf '%s\n' "$out" | grep -c ' worker  '); if [ "$n" = 3 ]; then echo "3 workers are serving"; else printf '%s\n' "$out"; exit 1; fi
```
