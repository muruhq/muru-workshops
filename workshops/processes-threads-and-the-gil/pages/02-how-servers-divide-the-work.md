---
title: How servers divide the work
---

# How servers divide the work

Open the document on processes, threads and the GIL. Read the first
three sections, up to "Free-threaded Python", which the last page
comes back to.

```{file-open}
:title: Open the document on processes, threads and the GIL
:path: docs/processes-and-threads.md
:factory: Markdown Preview
:area: viewer
```

Two things from it matter for the rest of the workshop. On a regular
CPython, threads help a view that waits and not one that computes.
And under Muru, a request that finds every thread busy waits in the
edge's queue, so the access log can say how long it waited, `queue`,
apart from how long your code took, `app`.

Now open the application. `/wait` sleeps for a tenth of a second, as a
view does while a database answers. `/compute` runs Python for a tenth
of a second of CPU time, as a view does that renders or calculates.

```{file-open}
:title: Open work.py
:path: work.py
:area: viewer
```

`load.py` sends 40 requests to each path it is given, eight at a time,
and then reads the edge's records of those requests from a JSON access
log, `requests.jsonl`, which `muructl run` writes when started with
`--access-log-file requests.jsonl`. It prints the requests served per
second and the median total, `queue` and `app` times. Its first line
says how many CPUs it can use, which matters on the last page.
