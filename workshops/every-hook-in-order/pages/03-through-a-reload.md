---
title: Through a reload
requires: [quiz:new-before-old, verify:reloaded]
---

# Through a reload

A reload replaces the whole release: a new host, new workers, and the
old ones stopped. The run you started reloads when a source file
changes, as its `development mode` line said and its last line,
`watching ... for changes to **/*.py`, confirms, so nothing has to be
restarted to see one.

```{quiz}
:id: new-before-old
question: "You change `GREETING` and save. Which runs first: the new workers' `on_ready`, or the old workers' `on_drain`?"
options:
  - { text: "The new workers' on_ready: the old workers are told to stop only once the new ones serve", correct: true }
  - { text: "The old workers' on_drain: they stop before the new ones start", explanation: "Then nothing would serve in between. Muru switches to the new release once it is ready, and only then drains the old one." }
  - { text: "Neither: a reload restarts the same workers, so on_ready runs again in them", explanation: "A reload starts a new host and new workers from the new code; the old ones are stopped." }
explanation: "The new host imports the new code and its workers start; once they are ready, muructl switches to them and drains the old release."
```

Change the greeting.

```{editor-replace}
:id: change-greeting
:title: Change the greeting to "Good morning"
:path: greeting.py
:match: GREETING = "Hello"
GREETING = "Good morning"
```

```{verify}
:id: reloaded
:label: The new release serves
:substrate: shell
:trigger: after:change-greeting
for i in 1 2 3 4 5 6 7 8 9 10; do out=$(curl -s --max-time 2 http://127.0.0.1:{{ app_port }}/); case "$out" in "Good morning"*) echo "$out"; exit 0;; esac; sleep 1; done; echo "${out:-Nothing answers on port {{ app_port }}.} Check the terminal on the left for a reload."; exit 1
```

Each release's output reaches the terminal through a log relay of its
own, so the lines of the new release and the old can arrive a few
milliseconds out of step, interleaved. Read them by release. In the
terminal on the left, after `reloading, ... greeting.py changed`:

- the new host's `on_load` and `pre_fork`, with a new process id, then
  the new workers' `post_fork` and `on_ready`;

- `switched to release r2`, which `muructl` prints once the new
  workers are ready, though their lines may arrive just after it;

- the old host's `received SIGTERM, stopping`, and the old workers'
  `on_drain` and `on_exit`, with the old process ids, all after the
  switch.

The new release served before the old one began to stop, so no request
went without a worker.
