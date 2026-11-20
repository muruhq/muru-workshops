---
title: What counts as a change
requires: [verify:template-reloads]
---

# What counts as a change

Open the document on reload and HTTPS for a real project. Read the
first section, on what counts as a change, with its diagram; the rest
comes up on later pages.

```{file-open}
:title: Open the document on reload and HTTPS
:path: docs/reload-and-https.md
:factory: Markdown Preview
:area: viewer
```

The application reads its page from `templates/page.html` and its
dishes from `data/menu.json` when it is imported, and records each
visit in `data/last-visit.json`.

```{file-open}
:title: Open menu/app.py
:path: menu/app.py
:area: viewer
```

Start it as it stands. A development run reloads on change without a
flag, and its last start-up line, `muru: watching .../menu for changes
to **/*.py`, says what counts.

```{execute}
:id: start-default
:session: server
:wait: 3s
muructl run app:application --chdir menu --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

```{execute}
:id: ask-default
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/
```

Now change the template's heading.

```{editor-replace}
:id: change-heading
:title: Change "Today" to "On the menu" in menu/templates/page.html
:path: menu/templates/page.html
:match: Today
On the menu
```

```{execute}
:id: ask-after-heading
:session: client
:wait: prompt
sleep 2; curl -s http://127.0.0.1:{{ app_port }}/
```

Still `Today`, and the terminal on the left says nothing: only
`**/*.py` counts by default, and the template was read once, at
import. Stop the project and start it with the template and data files
counted as source. `--reload-include` adds its patterns to the default
`**/*.py`.

```{interrupt}
:id: stop-default
:session: server
```

```{execute}
:id: start-included
:session: server
:wait: 3s
muructl run app:application --chdir menu --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --reload-include '**/*.html' --reload-include '**/*.json'
```

The last startup line says what is watched: `muru: watching .../menu
for changes to **/*.py, **/*.html, **/*.json`.

```{execute}
:id: ask-included
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/
```

```{verify}
:id: template-reloads
:label: The new heading is served
:substrate: shell
:trigger: after:ask-included
out=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/); printf '%s\n' "$out" | grep 'On the menu' || { printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}"; exit 1; }
```

```{hint}
:title: If the check fails
Look at the terminal on the left. "is in use by", followed by a
program and its process id, means another program has the port it
names, {{ app_port }} or the dashboard's {{ dashboard_port }}: change
`app_port` or `dashboard_port` from the gear button in the header of
this panel, then start the project again.
```

`On the menu`: a new start reads the template. But look at the
terminal on the left.
