---
title: A pool per worker
requires: [verify:pool-per-worker, verify:pool-from-host, verify:factory-in-workers]
---

# A pool per worker

The shop's `/pool` answers with the process it ran in and the process
that made the database pool it used. Ask it six times; the edge shares
the requests between the two workers.

```{execute}
:id: ask-pool
:session: client
:wait: prompt
for i in 1 2 3 4 5 6; do curl -s http://127.0.0.1:{{ app_port }}/pool; done
```

Every answer has the same process twice: each worker called the
factory itself after it was forked, so the SQLite connection its pool
opened belongs to it, and the two workers never touch each other's.

```{verify}
:id: pool-per-worker
:label: Each worker uses a pool it made itself
:substrate: shell
:trigger: after:ask-pool
python -c "
import json, urllib.request
answers = [json.load(urllib.request.urlopen('http://127.0.0.1:{{ app_port }}/pool', timeout=2)) for _ in range(6)]
print('Each worker uses its own pool.' if all(a['worker process'] == a['pool made in'] for a in answers) else answers)
raise SystemExit(0 if all(a['worker process'] == a['pool made in'] for a in answers) else 1)
"
```

Building the application once in the host, before the fork, would save
each worker the work. That is what gunicorn's `--preload` does with a
factory, and what `factory_phase = "host"` asks of Muru. Stop the shop,
ask for it, and start the shop again.

```{interrupt}
:id: stop-for-host
:session: server
```

```{editor-insert}
:id: add-host-phase
:title: Call the factory in the host, in shop/pyproject.toml
:path: shop/pyproject.toml
:match: processes = 2
factory_phase = "host"
```

```{execute}
:id: start-host-phase
:session: server
:wait: 3s
muructl run shop --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

```{execute}
:id: ask-pool-host
:session: client
:wait: prompt
for i in 1 2 3 4 5 6; do curl -s http://127.0.0.1:{{ app_port }}/pool; done
```

```{verify}
:id: pool-from-host
:label: Both workers use the pool the host made
:substrate: shell
:trigger: after:ask-pool-host
python -c "
import json, urllib.request
answers = [json.load(urllib.request.urlopen('http://127.0.0.1:{{ app_port }}/pool', timeout=2)) for _ in range(6)]
shared = len({a['pool made in'] for a in answers}) == 1 and all(a['worker process'] != a['pool made in'] for a in answers)
print('Both workers use the pool the host made.' if shared else answers)
raise SystemExit(0 if shared else 1)
"
```

Now both workers answer with the same pool, made in the host's
process: they are using one SQLite connection, opened before the fork,
from two processes at once. SQLite's documentation says never to carry
a connection across a fork, and a database client that holds a socket
is no safer.

Muru's import check, which looks for a socket or a thread left behind
before the fork, did not object: an SQLite connection is an open file,
which it does not look for. The host phase is for a factory known to
open nothing a process cannot share, and the default, the factory in
each worker, is the one that is safe without having to know. Put it
back.

```{interrupt}
:id: stop-host-phase
:session: server
```

```{editor-replace}
:id: remove-host-phase
:title: Remove factory_phase from shop/pyproject.toml
:path: shop/pyproject.toml
:regex: true
:match: factory_phase = "host"\n
```

```{execute}
:id: start-worker-phase
:session: server
:wait: 3s
muructl run shop --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }}
```

```{verify}
:id: factory-in-workers
:label: The factory runs in each worker again
:substrate: shell
:trigger: after:start-worker-phase
! grep -q factory_phase shop/pyproject.toml || { echo "shop/pyproject.toml still has factory_phase. Remove it with the action above."; exit 1; }; python -c "
import json, urllib.request
answers = [json.load(urllib.request.urlopen('http://127.0.0.1:{{ app_port }}/pool', timeout=2)) for _ in range(4)]
own = all(a['worker process'] == a['pool made in'] for a in answers)
print('Each worker uses its own pool.' if own else answers)
raise SystemExit(0 if own else 1)
"
```
