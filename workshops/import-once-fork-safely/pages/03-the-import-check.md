---
title: The import check
requires: [verify:fallback-serves]
---

# The import check

Read the rest of the document, from "How servers handle it". gunicorn
with `--preload` would fork from the catalogue's import exactly as
`fork_demo.py` did. Muru's host checks the import first.

Serve the catalogue with two workers in the terminal on the left.

```{execute}
:id: start-auto
:session: server
:wait: 3s
muructl run catalog:application --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --processes 2
```

Read the lines starting `preload:`. The host imported the catalogue,
found the connected socket (with the address it is connected to) and
the running thread, named the module whose import left each one, and
said what to do about them. Then it fell back: each worker imported
the application itself, which the `worker 0 imported` and `worker 1
imported` lines show. That is always safe, and it costs what preloading
was for: slower worker starts and no shared memory.

```{verify}
:id: fallback-serves
:label: The catalogue answers on port {{ app_port }}
:substrate: shell
:trigger: after:start-auto
curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/
```

Send the catalogue some requests.

```{execute}
:id: requests-auto
:session: client
:wait: prompt
for i in 1 2 3 4 5 6; do curl -s http://127.0.0.1:{{ app_port }}/; done
```

Within five seconds, each worker's metrics sender prints the count it
sent, tagged with the worker. Each worker imported the catalogue
itself, so each has its own socket and its own sender thread.

```{hint}
:title: If the check fails
Look at the terminal on the left. "is in use by", followed by a
program and its process id, means another program has the port it
names, {{ app_port }} or the dashboard's {{ dashboard_port }}: change
`app_port` or `dashboard_port` from the gear button in the header of
this panel, then start the catalogue again.
```
