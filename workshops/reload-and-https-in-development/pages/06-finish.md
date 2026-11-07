---
title: Finish
---

# Finish

You have reloaded an application and served it over HTTPS under
`muructl run`.

- gunicorn's reloader replaces each worker in place, uvicorn's the
  server process and Granian's every worker, each when asked with
  `--reload`. A `muructl run` development run reloads without a flag,
  and starts a new release beside the one serving and switches to it
  once its workers are ready, so no request was refused. `--no-reload`
  turns it off for a run.

- A change that did not import left the previous release serving,
  where gunicorn would serve the traceback, uvicorn nothing at all and
  Granian would stop.

- `--https` added a TLS listener with a development certificate kept
  in the cache directory, self-signed unless mkcert's authority is
  there to issue it.

- Over TLS the edge and the client agreed on HTTP/2, and your code
  saw `https` as its scheme and the TLS details in `muru.tls`, with no
  change to the code.

Click Finish below for where to go next.
