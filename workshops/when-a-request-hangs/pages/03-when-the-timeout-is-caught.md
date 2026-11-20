---
title: When the timeout is caught
requires: [quiz:caught-timeout, verify:hard-replaced]
---

# When the timeout is caught

`muru.RequestTimeout` is a `BaseException`, not an `Exception`, so a
handler that catches `Exception` to log and carry on lets it through.
A bare `except:` does not. `/sync` retries an upstream that never
answers, in a loop whose bare `except:` catches every failure, and
everything else with it.

```{editor-highlight}
:id: show-sync
:title: Show the retry loop in accounts.py
:path: accounts.py
:match: except:  # noqa: E722
```

Restart the service with a hard timeout of seven seconds beside the
soft one.

```{interrupt}
:id: stop-soft
:session: server
```

```{execute}
:id: start-hard
:session: server
:wait: 3s
muructl run accounts:application --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --timeout soft=2s --timeout hard=7s
```

```{quiz}
:id: caught-timeout
question: "`/sync` is asked for. What happens when it passes the two second soft timeout?"
options:
  - { text: "RequestTimeout is raised in the loop, the bare except catches it, and the loop goes on until the hard timeout replaces the worker", correct: true }
  - { text: "The request is answered 504, as /report was", explanation: "The 504 comes from the exception leaving the application. Here the loop catches it." }
  - { text: "The loop stops, because RequestTimeout is a BaseException", explanation: "Being a BaseException keeps it out of except Exception. A bare except catches every exception, BaseException included." }
explanation: "A bare except swallows the soft timeout's exception like any other. The hard timeout, which needs nothing from the stuck code, is what ends it."
```

```{execute}
:id: ask-sync
:session: client
:wait: prompt
curl -s -w '%{http_code} after %{time_total} s\n' -o /dev/null http://127.0.0.1:{{ app_port }}/sync
```

```{verify}
:id: hard-replaced
:label: A new worker serves after the hard timeout
:substrate: shell
:trigger: after:ask-sync
curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/health | grep '^ok$' && echo "A new worker serves." || { echo "Nothing answers /health on port {{ app_port }}. Check the terminal on the left."; exit 1; }
```

`504` after about seven seconds. In the terminal on the left:

- two seconds in, the soft timeout's line, `at accounts.py line ... in
  fetch_upstream`, and no traceback: the loop caught the exception;

- seven seconds in, `a request has run for ... s, past the hard
  timeout of 7 s; replacing it`, the access log line, `504` with
  `reason=hard_timeout`, a new worker started, `gave up 1 request for
  the edge to answer`, and every thread's stack;

- then `replaced by pid ...`, and the new worker's `is ready`: it
  serves at once;

- about fifteen seconds later, after the hard drain grace,
  `exited after its drain grace`.

The request that condemned the worker is answered the moment the
worker is replaced. The grace is for the worker's other requests,
which get that long to finish on the old worker before it is killed.

The fix is in the code: `except Exception:` in place of the bare
`except:`, which lets the soft timeout through, and a limit on the
retries.
