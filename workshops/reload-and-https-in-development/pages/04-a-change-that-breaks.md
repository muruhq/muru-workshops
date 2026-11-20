---
title: A change that breaks
requires: [quiz:broken-reload, verify:old-release-serves, verify:fixed-release-serves]
---

# A change that breaks

Saving a file half way through an edit is ordinary while you develop,
and the half-written file often does not import.

```{quiz}
:id: broken-reload
question: You save `greeting.py` with a syntax error. What do requests to the application get under `muructl run`?
options:
  - { text: "A 500 with the traceback of the syntax error", explanation: "That is what gunicorn's reloader does: the replacement worker serves the traceback until the file is fixed." }
  - { text: "Nothing: the server is down until the next change", explanation: "That is uvicorn: the new server process exits, and nothing serves until you save again." }
  - { text: "The previous release's answer, as before the change", correct: true }
explanation: "The new release's host fails to import the code and exits before any request goes to it. The edge never switched, so the release that was serving goes on serving."
```

This edit changes the greeting again and drops the colon from the end
of the `def` line.

```{editor-replace}
:id: break-it
:title: Change the greeting and drop the colon
:path: greeting.py
:regex: true
:match: GREETING = "Good morning"\n\n\ndef application\(environ, start_response\):
GREETING = "Good evening"


def application(environ, start_response)
```

The terminal on the left shows the new host's `cannot load
greeting:application: SyntaxError`, then `muru: release r3 failed to
start: ... release r2 keeps serving`.

```{execute}
:id: curl-after-break
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/
```

Still "Good morning", from the same host as before.

```{verify}
:id: old-release-serves
:label: The previous release still serves
:substrate: shell
:trigger: after:curl-after-break
out=$(curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/ | head -n 1); printf '%s\n' "$out" | grep '^Good morning' || { echo "Expected the Good morning release, got: $out"; exit 1; }
```

Put the colon back, and the next release replaces it.

```{editor-replace}
:id: fix-it
:title: Put the colon back
:path: greeting.py
:regex: true
:match: start_response\)$
start_response):
```

The failed attempt was release r3, so the terminal on the left says
`switched to release r4`.

```{execute}
:id: curl-after-fix
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/
```

```{verify}
:id: fixed-release-serves
:label: The fixed release serves
:substrate: shell
:trigger: after:curl-after-fix
out=$(curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/ | head -n 1); printf '%s\n' "$out" | grep '^Good evening' || { echo "Expected the Good evening release, got: $out"; exit 1; }
```
