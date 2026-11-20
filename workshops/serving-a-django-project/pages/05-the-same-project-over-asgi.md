---
title: The same project over ASGI
requires: [quiz:sync-view-under-asgi, verify:views-under-asgi, verify:site-stopped]
---

# The same project over ASGI

The project has an `async def` view too, `/ping`, which says whether
it ran on an event loop and on which thread. Over WSGI each request
has a thread, and Django runs `/ping` in an event loop it starts for
the view.

```{execute}
:id: ping-wsgi
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/ping; echo
```

`asgi.py` serves the same project over ASGI, on each worker's event
loop. Stop the site, and start it from `asgi.py`. The entrypoint on
the command line wins over the table's for this run, and `--chdir`
still finds the table, so the processes still come from it.

```{interrupt}
:id: stop-wsgi
:session: server
```

```{execute}
:id: start-asgi
:session: server
:wait: 4s
muructl run mysite.asgi:application --chdir mysite --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

`mysite.asgi:application is served as ASGI`, and the serving line
says `2 workers of concurrency 1000`: each worker runs one event loop
that takes up to a thousand requests at once, in place of four
threads.

```{quiz}
:id: sync-view-under-asgi
question: The front page is a plain `def` view that queries the database. Over ASGI, where does it run?
options:
  - { text: "On a thread Django hands it to, so the event loop is not blocked", correct: true }
  - { text: "On the worker's event loop, like the async view", explanation: "A blocking view on the loop would stop every other request in the worker. Django runs sync views with sync_to_async." }
  - { text: "In a separate WSGI worker that Muru keeps for sync views", explanation: "There is one kind of worker here, running asgi.py; Django decides where each view runs." }
explanation: "Django's ASGI handler runs a sync view with sync_to_async, on a thread, and an async view on the event loop itself."
```

```{execute}
:id: ask-asgi
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/; echo; curl -s http://127.0.0.1:{{ app_port }}/ping; echo
```

```{verify}
:id: views-under-asgi
:label: The async view runs on the worker's loop
:substrate: shell
:trigger: after:ask-asgi
out=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/ping); printf '%s\n' "$out" | grep -o '"thread": "muru-loop"' || { printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}"; exit 1; }
```

The front page ran on one of Django's `ThreadPoolExecutor` threads, and
`/ping` on `muru-loop`, the worker's event loop. Over WSGI it was the
reverse: the request's thread for the sync view, an event loop started
for the async one. A project with mostly async views gains from
`asgi.py`; one with mostly sync views, which is most Django projects,
loses nothing by staying on `wsgi.py`.

You have finished with the site. Stop it in the terminal on the left.

```{interrupt}
:id: stop-site
:session: server
```

```{verify}
:id: site-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-site
for i in 1 2 3 4 5; do curl -s -o /dev/null --max-time 1 http://127.0.0.1:{{ app_port }}/ || { echo "The site has stopped."; exit 0; }; sleep 1; done; echo "The site still answers on port {{ app_port }}. Stop it with the action above."; exit 1
```
