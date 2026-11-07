---
title: A change while serving
requires: [verify:no-request-failed]
---

# A change while serving

`watch.py` in your workspace asks for the page ten times a second and
prints its first line whenever it changes, so you can see a reload
from a client's side. It stops one second after the first change, and
says how many requests it sent and how many failed. Start it in the
terminal on the right.

```{execute}
:id: start-watch
:session: client
:wait: 2s
python watch.py {{ app_port }}
```

Now change the greeting and save, as you would in your editor.

```{editor-replace}
:id: change-greeting
:title: Change the greeting to "Good morning"
:path: greeting.py
:match: GREETING = "Hello"
GREETING = "Good morning"
```

In the terminal on the left, `muructl` says which file changed, a new
host preloads the new code and starts its worker, and then:
`muru: switched to release r2`. Only after that does the old host
receive SIGTERM and stop.

In the terminal on the right, the first line changed from "Hello" to
"Good morning", and the host's process id changed with it: a new
release, not a restarted worker. The last line counts the requests.

```{verify}
:id: no-request-failed
:label: No request failed during the reload
:substrate: shell
:trigger: after:change-greeting
for i in 1 2 3 4 5 6 7 8 9 10; do [ -f watch.log ] && break; sleep 1; done; out=$(cat watch.log 2>/dev/null); printf '%s\n' "$out" | head -n 1 | grep ', 0 failed$' || { echo "watch.py has not finished yet, or requests failed: ${out:-no summary yet}" | head -n 4; exit 1; }
```

```{hint}
:title: If the check fails
`watch.py` stops one second after it sees the page change. If the
terminal on the right is still printing nothing new, look in the
terminal on the left for the reload, then click Check again.
```
