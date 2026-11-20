---
title: A certificate of your own
requires: [verify:own-certificate, verify:project-stopped-https]
---

# A certificate of your own

An organisation with its own CA, or a test suite that makes one,
gives you a certificate to serve rather than letting Muru make one.
`trustme`, in the workshop's environment, makes a local CA and a
certificate signed by it. Make one for `menu.test` in a `certs`
directory inside the project, since `--tls-cert` and `--tls-key` read
a relative path from the project's directory, as `--chdir` names it.

```{directory-create}
:id: make-certs-dir
:title: Create the menu/certs directory
:path: menu/certs
```

```{execute}
:id: make-certificate
:session: client
:wait: prompt
python -m trustme -d menu/certs -i menu.test localhost 127.0.0.1
```

`server.pem` and `server.key` are the certificate and its key for the
server, and `client.pem` is the CA's certificate, for clients to
trust. Stop the project and serve the new certificate.

```{interrupt}
:id: stop-https-only
:session: server
```

```{execute}
:id: start-own
:session: server
:wait: 4s
muructl run app:application --chdir menu --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --https-port {{ https_port }} --https-only --tls-cert certs/server.pem --tls-key certs/server.key
```

`TLS certificate from certs/server.pem` replaces the self-signed
certificate line. curl now trusts the trustme CA, not Muru's
certificate. The two flags have keys of the same names, `tls_cert` and
`tls_key`, in the project table the next page writes, read from the
project's directory the same way.

```{execute}
:id: ask-own
:session: client
:wait: prompt
curl -s --cacert menu/certs/client.pem --resolve menu.test:{{ https_port }}:127.0.0.1 https://menu.test:{{ https_port }}/
```

```{verify}
:id: own-certificate
:label: The certificate from the local CA is served
:substrate: shell
:trigger: after:ask-own
out=$(curl -sS --max-time 2 --cacert menu/certs/client.pem --resolve menu.test:{{ https_port }}:127.0.0.1 https://menu.test:{{ https_port }}/ 2>&1); printf '%s\n' "$out" | grep -o 'over https with HTTP/2.0' || { printf '%s\n' "$out"; exit 1; }
```

You have finished with the project. Stop it in the terminal on the
left.

```{interrupt}
:id: stop-own
:session: server
```

```{verify}
:id: project-stopped-https
:label: Nothing answers on port {{ app_port }}
:substrate: shell
:trigger: after:stop-own
for i in 1 2 3 4 5; do curl -s -o /dev/null --max-time 1 http://127.0.0.1:{{ app_port }}/ || { echo "The project has stopped."; exit 0; }; sleep 1; done; echo "The project still answers on port {{ app_port }}. Stop it with the action above."; exit 1
```
