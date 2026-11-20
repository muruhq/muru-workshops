---
title: Files the project writes
requires: [quiz:why-reloading, verify:visits-ignored, verify:data-reloads]
---

# Files the project writes

After the request, the terminal on the left says `reloading,
.../data/last-visit.json changed`, then `switched to release r2`. Ask
again.

```{execute}
:id: ask-again
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/; sleep 2
```

Another reload, and the worker process in the answer changes each
time.

```{quiz}
:id: why-reloading
question: Why does every request now start a new release?
options:
  - { text: "The application writes data/last-visit.json on every request, and **/*.json now counts as source", correct: true }
  - { text: "--reload-include makes muructl reload on every request", explanation: "It changes which files count as source. A reload still needs a file to change." }
  - { text: "The template is read on every request", explanation: "It is read once, at import. The file that changes on every request is one the application writes." }
explanation: "An include pattern wide enough to catch a file the application writes turns each write into a reload. --reload-exclude names files that never count, and an exclude wins over an include."
```

Stop the project and start it again with `data/last-visit.json`
excluded.

```{interrupt}
:id: stop-included
:session: server
```

```{execute}
:id: start-excluded
:session: server
:wait: 3s
muructl run app:application --chdir menu --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --reload-include '**/*.html' --reload-include '**/*.json' --reload-exclude 'data/last-visit.json'
```

```{execute}
:id: ask-excluded
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/; sleep 2; curl -s http://127.0.0.1:{{ app_port }}/
```

```{verify}
:id: visits-ignored
:label: Requests no longer start a release
:substrate: shell
:trigger: after:ask-excluded
a=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/ | grep -o 'worker process [0-9]*'); sleep 2; b=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/ | grep -o 'worker process [0-9]*'); [ -n "$a" ] && [ "$a" = "$b" ] && echo "Both requests were served by $a." || { echo "The requests were served by '$a' and '$b'. Check that the project was started with --reload-exclude."; exit 1; }
```

The same worker process twice, and no reload. A change to the menu
still counts. Add a dish.

```{editor-replace}
:id: add-dish
:title: Add salad to menu/data/menu.json
:path: menu/data/menu.json
:match: "bread"]
"bread", "salad"]
```

```{verify}
:id: data-reloads
:label: The new dish is served
:substrate: shell
:trigger: after:add-dish
for i in 1 2 3 4 5 6 7 8 9 10; do out=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/); case "$out" in *salad*) printf '%s\n' "$out" | head -n 1; exit 0;; esac; sleep 1; done; printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}"; exit 1
```

`reloading, .../data/menu.json changed` in the terminal on the left,
and salad on the menu.
