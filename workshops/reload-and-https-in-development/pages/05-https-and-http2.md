---
title: HTTPS and HTTP/2
requires: [quiz:protocol-over-tls, verify:http2-over-tls, verify:server-stopped]
---

# HTTPS and HTTP/2

Browsers speak HTTP/2 only over TLS, and Secure cookies,
`wsgi.url_scheme` and HTTPS redirects all behave differently behind
it. Under gunicorn or uvicorn you test those with a certificate you
make yourself, given to gunicorn's `--certfile` and `--keyfile` or
uvicorn's `--ssl-certfile` and `--ssl-keyfile`, or with a proxy in
front.
`muructl run --https` makes a development certificate for you.

Stop the application, then start it again with HTTPS on port
{{ https_port }} beside HTTP.

```{interrupt}
:id: stop-for-https
:session: server
```

```{execute}
:id: start-https
:session: server
:wait: 3s
muructl run greeting:application --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --https --https-port {{ https_port }}
```

The `serving` line now names both addresses, and a new line says
`muructl` made a self-signed certificate for `localhost`, `127.0.0.1`
and `::1`, kept in `muru-cache/certs/`. It is reused on later runs. On
your own machine, with [mkcert](https://github.com/FiloSottile/mkcert)
installed, the certificate is issued by mkcert's local authority
instead and browsers trust it; this workshop points `CAROOT` at an
empty directory so the certificate is self-signed everywhere, and the
next line tells you about mkcert.

Ask over plain HTTP first.

```{execute}
:id: curl-http
:session: client
:wait: prompt
curl -s http://127.0.0.1:{{ app_port }}/
```

The second line says the scheme was `http` and the protocol HTTP/1.1.

```{quiz}
:id: protocol-over-tls
question: curl offers HTTP/2 and HTTP/1.1 in the TLS handshake. Which protocol will the application report over HTTPS?
options:
  - { text: "HTTP/1.1, as over plain HTTP", explanation: "Over TLS the client and the edge agree on the protocol in the handshake, and the edge accepts HTTP/2." }
  - { text: "HTTP/2.0", correct: true }
  - { text: "HTTP/3", explanation: "HTTP/3 runs over QUIC, not TLS over TCP. Neither curl's request here nor the edge's listener uses it." }
explanation: "The edge accepts `h2` in the TLS handshake (ALPN), so the request arrives as HTTP/2, and the WSGI environ says `HTTP/2.0`. Your code does not change: the edge speaks HTTP/2 to the client and passes the request on as usual."
```

`--cacert` tells curl to trust the development certificate.

```{execute}
:id: curl-https
:session: client
:wait: prompt
curl -s --cacert muru-cache/certs/dev.pem https://localhost:{{ https_port }}/
```

The scheme is `https`, the protocol HTTP/2.0, and the TLS version and
the protocol agreed in the handshake (ALPN) come from `muru.tls` in
the environ. The handshake itself is in curl's verbose output.

```{execute}
:id: curl-verbose
:session: client
:wait: prompt
curl -s -v -o /dev/null --cacert muru-cache/certs/dev.pem https://localhost:{{ https_port }}/ 2>&1 | grep -E 'ALPN|^< HTTP'
```

```{verify}
:id: http2-over-tls
:label: The application is reached over HTTP/2 with TLS
:substrate: shell
:trigger: after:curl-https
out=$(curl -sS --max-time 2 --cacert muru-cache/certs/dev.pem https://localhost:{{ https_port }}/ 2>&1); printf '%s\n' "$out" | grep 'Scheme https, protocol HTTP/2.0' || { printf '%s\n' "$out"; exit 1; }
```

A browser pane cannot show this: through JupyterLab's proxy the
browser talks to JupyterLab, and JupyterLab talks plain HTTP to the
application's HTTP port.

You have finished with the application. Stop it in the terminal on
the left.

```{interrupt}
:id: stop-server
:session: server
```

```{verify}
:id: server-stopped
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-server
if curl -s -o /dev/null --max-time 2 http://127.0.0.1:{{ app_port }}/; then echo "The application still answers on port {{ app_port }}. Stop it with the action above."; exit 1; fi; echo "The application has stopped."
```
