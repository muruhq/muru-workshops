---
title: Refusing to start
requires: [quiz:preload-true, verify:refused]
---

# Refusing to start

A fallback that only prints a message is easy to miss in production,
where an import that used to be clean starts a thread after a library
upgrade and nobody reads the log. `--preload true` asks for the
preload and nothing less.

```{quiz}
:id: preload-true
question: What will `muructl run` do with the catalogue under `--preload true`?
options:
  - { text: "Preload it anyway and fork, as gunicorn --preload would", explanation: "Muru never forks from an import that failed the check." }
  - { text: "Fall back to imports in each worker, as before", explanation: "That is `--preload auto`, the default. `true` takes away the fallback." }
  - { text: "Say what the import left behind and refuse to start", correct: true }
explanation: "Under `--preload true` a failed import check stops the release from starting, so a change that makes the import unsafe is caught when it is made rather than in production."
```

Stop the catalogue, then start it again with `--preload true`.

```{interrupt}
:id: stop-auto
:session: server
```

```{execute}
:id: start-preload-true
:session: server
:wait: 3s
muructl run catalog:application --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --processes 2 --preload true
```

The same two `preload:` lines, then `preload is true, so the import
check failing stops the release`, and `muructl` exits.

```{verify}
:id: refused
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:start-preload-true
if curl -s -o /dev/null --max-time 2 http://127.0.0.1:{{ app_port }}/; then echo "Something still answers on port {{ app_port }}."; exit 1; fi; echo "The catalogue refused to start."
```
