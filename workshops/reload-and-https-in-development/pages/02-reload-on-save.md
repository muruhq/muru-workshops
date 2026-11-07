---
title: Reload on save
requires: [verify:server-up]
---

# Reload on save

gunicorn, uvicorn and Granian reload when you save if you ask with
`--reload`; a `muructl run` development run does it without being
asked. Each
replaces something different when a file changes. Open the document
that compares them, and read it through to the table at the end.

```{file-open}
:title: Open the document on what a reload replaces
:path: docs/reloading.md
:factory: Markdown Preview
:area: viewer
```

The thing to notice is that `muructl run` does not restart anything in
place. A change starts a new release beside the one serving, and the
edge switches to it once it is ready.

Open the application. `GREETING` is what the next page changes.

```{file-open}
:title: Open greeting.py
:path: greeting.py
:area: viewer
```

Start it in the terminal on the left, with no flag for reloading.

```{execute}
:id: start-reload
:session: server
:wait: 3s
muructl run greeting:application --port {{ app_port }}
```

The `development mode` line says the run reloads on change, and the
last line, `muru: watching ... for changes to **/*.py`, names the
directory it watches: a change to any `.py` file under it starts a new
release. `--no-reload` turns that off for one run; a project can turn
it off for good, or widen what counts as a change, in a table of its
own, which the Developing with muructl run collection covers.

```{verify}
:id: server-up
:label: The application answers on port {{ app_port }}
:substrate: shell
:trigger: after:start-reload
curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/ | head -n 1
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "Address already in use" means
another program has port {{ app_port }}: change `app_port` from the
gear button in the header of this panel, then start the application
again. If nothing is printed yet, give it a few seconds and click
Check.
```
