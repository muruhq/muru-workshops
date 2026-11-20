---
title: Another name
requires: [verify:name-on-certificate, verify:http-redirected]
---

# Another name

Read the document's section on HTTPS in development. A project reached
as `menu.test`, through a hosts file entry or a tunnel, needs that
name on its certificate. Start the project with HTTPS and the extra
name.

```{execute}
:id: start-host
:session: server
:wait: 4s
muructl run app:application --chdir menu --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --https --https-port {{ https_port }} --host menu.test
```

The certificate line says `self-signed certificate for localhost,
127.0.0.1, ::1, menu.test (created, .../dev.pem)`, kept in the
workspace's `muru-cache` directory. The
workshop sets `CAROOT` to a directory with no mkcert CA in it, so the
certificate is self-signed on every machine.

There is no hosts file entry for `menu.test` here, so curl is told
where it is with `--resolve`, and to trust the certificate with
`--cacert`.

```{execute}
:id: ask-menu-test
:session: client
:wait: prompt
curl -s --cacert muru-cache/certs/dev.pem --resolve menu.test:{{ https_port }}:127.0.0.1 https://menu.test:{{ https_port }}/
```

```{verify}
:id: name-on-certificate
:label: The certificate is good for menu.test
:substrate: shell
:trigger: after:ask-menu-test
out=$(curl -sS --max-time 2 --cacert muru-cache/certs/dev.pem --resolve menu.test:{{ https_port }}:127.0.0.1 https://menu.test:{{ https_port }}/ 2>&1); printf '%s\n' "$out" | grep -o 'over https with HTTP/2.0' || { printf '%s\n' "$out"; exit 1; }
```

```{hint}
:title: If the check fails
"is in use by" in the terminal on the left, followed by a program and
its process id, means another program has the port it names,
{{ app_port }}, {{ https_port }} or the dashboard's {{ dashboard_port }}:
change `app_port`, `https_port` or `dashboard_port` from the gear
button in the header of this panel, then start the project again.
```

`over https with HTTP/2.0`, under the name `menu.test`. A name the
certificate does not have, such as `other.test`, would fail curl's
check of the certificate.

Some code behaves differently when it is reached over HTTP and
redirected, such as a login page that sets a cookie only over HTTPS.
`--https-only` answers plain HTTP with that redirect. Stop the project
and start it that way.

```{interrupt}
:id: stop-host
:session: server
```

```{execute}
:id: start-https-only
:session: server
:wait: 4s
muructl run app:application --chdir menu --port {{ app_port }} --dashboard 127.0.0.1:{{ dashboard_port }} --https-port {{ https_port }} --https-only --host menu.test
```

The serving line now says `https://127.0.0.1:{{ https_port }}
(http://127.0.0.1:{{ app_port }} redirects to it)`, and the certificate
is `reused`, since its names are the same.

```{execute}
:id: ask-plain
:session: client
:wait: prompt
curl -s -i 'http://127.0.0.1:{{ app_port }}/?table=4' | head -n 2
```

```{verify}
:id: http-redirected
:label: Plain HTTP is redirected to HTTPS
:substrate: shell
:trigger: after:ask-plain
out=$(curl -s -i --max-time 2 'http://127.0.0.1:{{ app_port }}/?table=4'); printf '%s\n' "$out" | grep -i '^location: https://127.0.0.1:{{ https_port }}/?table=4' || { printf '%s\n' "${out:-Nothing answers on port {{ app_port }}.}" | head -n 5; exit 1; }
```

`307 Temporary Redirect`, to the same path and query over HTTPS. A 307
keeps the method and body, so a form posted to the plain address
arrives at the HTTPS one intact.
