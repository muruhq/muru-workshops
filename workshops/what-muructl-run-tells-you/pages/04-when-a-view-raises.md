---
title: When a view raises
requires: [verify:problem-document, quiz:reason-for-404]
---

# When a view raises

There is no product 9, so the product view raises a `KeyError`. Open
that product in a pane, as a browser would.

```{url-open}
:title: Open product 9
:when: web_proxy
:url: {{ jupyter_url }}proxy/{{ app_port }}/products/9
:pane: shop
:area: viewer
```

```{url-open}
:title: Open product 9
:when: not web_proxy
:url: http://127.0.0.1:{{ app_port }}/products/9
:pane: shop
:area: viewer
```

The page is Muru's, not Flask's. It gives the status, the reason
`app_error`, the request id and the traceback, which in development
is what you want to see without going to the terminal. In the terminal
on the left, the same traceback is tagged with the worker, under the
line `ERROR muru: the application raised an exception`: Muru logs it
on its `muru` logger, so a project's own logging handlers get it too.
The access log line ends `reason=app_error` and the same id.

This works because `shop.py` sets `PROPAGATE_EXCEPTIONS`. Without it,
Flask catches the exception itself and answers with a plain 500 page
of its own, as gunicorn and uvicorn do.

An API client asks for JSON, and gets the same error as a problem
document (RFC 9457).

```{execute}
:id: get-problem
:session: client
:wait: prompt
curl -s -H 'Accept: application/json' http://127.0.0.1:{{ app_port }}/products/9 | python -m json.tool
```

The `traceback` field holds the traceback, and `request_id` the id the
access log line shows for this request.

```{verify}
:id: problem-document
:label: The edge answers JSON clients with a problem document
:substrate: shell
:trigger: after:get-problem
out=$(curl -s -H 'Accept: application/json' http://127.0.0.1:{{ app_port }}/products/9); printf '%s\n' "$out" | grep -o '"reason":"app_error"' || { printf '%s\n' "$out" | head -c 300; exit 1; }
```

A page that does not exist is different: Flask has a route table, and
answers 404 itself.

```{quiz}
:id: reason-for-404
question: What will the access log line for a request to `/nothing` say for its reason?
options:
  - { text: "`reason=not_found`", explanation: "The edge gives a reason only for a response it made itself. This 404 comes from Flask." }
  - { text: "Nothing: the line has no reason", correct: true }
  - { text: "`reason=app_error`", explanation: "`app_error` means your code raised. Answering 404 is an ordinary response." }
explanation: "A reason appears only when Muru made the response itself, as with `app_error` when your code raised. Flask's own 404 is an ordinary response from your application, so the line has no reason."
```

```{execute}
:id: get-nothing
:session: client
:wait: prompt
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:{{ app_port }}/nothing
```
