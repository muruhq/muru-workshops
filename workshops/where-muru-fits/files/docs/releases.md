# From development to the daemon

`muructl run` serves one copy of your code, the one in the directory
it was started in. For an application that stays up, Muru runs a
daemon, and the unit it deploys is a **release**: your code, the
Python it runs on and its settings, fixed when the release is made.

```mermaid
flowchart LR
    C[Clients] -->|HTTP and TLS| E[Edge process]
    E -->|all traffic| W1[r1 workers]
    E -. traffic moves here<br/>once r2 is ready .-> W2[r2 workers]
    H1[r1 host] -. fork .-> W1
    H2[r2 host] -. fork .-> W2
    D[Daemon<br/>muructl daemon] -->|routing| E
    D -->|start, stop| H1
    D -->|start, stop| H2
```

Under the daemon the edge is a process of its own, and the daemon is
another, so neither a deploy nor a restart of the daemon interrupts
the edge. Each release has its own host and workers. Deploying `r2`
starts it beside `r1`, which keeps serving. When every worker of `r2`
is ready, the edge sends new requests to it, and `r1` finishes the
requests it has before it is drained. `r1` stays warm for a while
afterwards, so moving back to it is a change of routing, not a
restart.

Because the edge can route to more than one release at once, the same
mechanism gives the rest:

- **Blue/green**: move all traffic to the new release once it is
  ready.

- **Canary**: give the new release a growing share of the requests,
  with gates on its error rate and latency, rolling back if a gate
  fails.

- **Preview**: send only the requests that ask for it, by a header or
  a cookie, to a release that has no share of the traffic.

- **Rollback**: send traffic back to the release that served before.

None of this needs a second deployment or a load balancer outside the
server, and a release can even run a different version of Python from
the one before it.

`muructl render` takes the settings a development run takes and writes
the release they describe as the configuration the daemon reads, which
is the path from one to the other. The workshops after this one cover the daemon, releases and
traffic in turn.
