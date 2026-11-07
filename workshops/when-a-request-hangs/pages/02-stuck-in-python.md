---
title: Stuck in Python
requires: [verify:soft-timeout]
---

# Stuck in Python

Open the document on when a request hangs. It covers what gunicorn,
uvicorn and mod_wsgi do, and Muru's three timeouts in the worker, with
a diagram and a table; the pages that follow try each.

```{file-open}
:title: Open the document on when a request hangs
:path: docs/timeouts.md
:factory: Markdown Preview
:area: viewer
```

`accounts.py` has three paths that hang. `/report` waits for a file,
`report.ready`, that nothing creates.

```{file-open}
:title: Open accounts.py
:path: accounts.py
:area: viewer
```

Start the service with a soft timeout of two seconds.

```{execute}
:id: start-soft
:session: server
:wait: 3s
muructl run accounts:application --port {{ app_port }} --timeout soft=2s
```

```{execute}
:id: ask-report
:session: client
:wait: prompt
curl -s -w '%{http_code} after %{time_total} s\n' -o /dev/null http://127.0.0.1:{{ app_port }}/report
```

```{verify}
:id: soft-timeout
:label: The soft timeout answers for /report
:substrate: shell
:trigger: after:ask-report
curl -s -o /dev/null --max-time 10 -w '%{http_code}\n' http://127.0.0.1:{{ app_port }}/report | grep '^504$' || { echo "/report did not answer 504. Check that the service was started with --timeout soft=2s."; exit 1; }
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "Address already in use" means
another program has port {{ app_port }}: change `app_port` from the
gear button in the header of this panel, then start the service again.
```

`504` after two seconds. In the terminal on the left:

- `request.soft_timeout: worker 0 (pid ...): request ... GET /report
  ran past the soft timeout of 2 s at accounts.py line ... in
  application, ...`: where the request was, without a debugger;

- the traceback of `muru.RequestTimeout`, raised in the request's
  thread at the `time.sleep` it was in;

- the access log line, `504 GET /report ... reason=soft_timeout`.

The worker went on serving: the soft timeout cost one request, and the
code could catch `muru.RequestTimeout` to clean up first.
