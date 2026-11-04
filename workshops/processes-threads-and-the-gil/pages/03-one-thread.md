---
title: One thread
requires: [verify:one-thread-up, verify:one-thread-measured]
---

# One thread

Start with the smallest setting: one worker process with one thread,
which serves one request at a time, as gunicorn's `sync` worker does.

```{execute}
:id: start-one-thread
:session: server
:wait: 3s
muructl run work:application --port {{ app_port }} --processes 1 --threads 1 --access-log-file requests.jsonl
```

The access log goes to the file now, so the terminal shows only the
startup lines.

```{verify}
:id: one-thread-up
:label: The application answers on port {{ app_port }}
:substrate: shell
:trigger: after:start-one-thread
curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "Address already in use" means
another program has port {{ app_port }}: change `app_port` from the
gear button in the header of this panel, then start the application
again.
```

Load both views. This takes about eight seconds.

```{execute}
:id: load-one-thread
:session: client
:wait: prompt
python load.py {{ app_port }} /wait /compute
```

```{verify}
:id: one-thread-measured
:label: The load script measured both views
:substrate: shell
:trigger: after:load-one-thread
out=$(wc -l < requests.jsonl 2>/dev/null | tr -d ' '); [ "${out:-0}" -ge 80 ] && echo "$out requests in the access log" || { echo "Only ${out:-0} requests in requests.jsonl so far. Run the load script above."; exit 1; }
```

Both views serve about ten requests a second, and they look the same:
`app` is the tenth of a second each view takes, and `queue` is most of
the rest. With eight requests at a time and one thread, seven of them
are always waiting in the edge's queue for that thread.

Under gunicorn's `sync` worker the same seven would wait too, in the
listening socket's queue, where nothing would tell you.
