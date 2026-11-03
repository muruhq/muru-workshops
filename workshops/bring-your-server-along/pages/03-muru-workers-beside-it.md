---
title: Muru workers beside it
requires: [verify:muru-previewed]
---

# Muru workers beside it

Deploy the same directory again, this time as Muru's own workers: the
entrypoint gunicorn was given, two processes, and `--hold`, so it
starts beside the gunicorn release with no traffic.

```{execute}
:id: deploy-native
:session: client
:wait: prompt
muructl deploy orders orders --entrypoint orders:application --processes 2 --hold
```

```{execute}
:id: list-both
:session: client
:wait: prompt
muructl release list orders
```

`r1` is gunicorn and serves; `r2` is two Muru workers of four threads,
held. Everyone still gets gunicorn. A preview of `r2` gets Muru, which
names itself `muru/0.1.0a16`.

```{execute}
:id: curl-both
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/; curl -s -H 'Muru-Preview: r2' http://127.0.0.1:{{ app_port }}/
```

```{verify}
:id: muru-previewed
:label: gunicorn serves, and a preview reaches Muru's workers
:substrate: shell
:trigger: after:curl-both
plain=$(curl -sS --max-time 2 http://127.0.0.1:{{ app_port }}/); preview=$(curl -sS --max-time 2 -H 'Muru-Preview: r2' http://127.0.0.1:{{ app_port }}/); case "$plain|$preview" in *'Served by gunicorn'*'|'*'Served by muru/'*) echo "gunicorn serves; the preview reaches Muru";; *) printf 'without a preview: %s\nwith one: %s\n' "$plain" "$preview"; exit 1;; esac
```
