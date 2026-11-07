# A Flask project under muructl run

Serves a small Flask shop, built by an application factory with a
SQLite database pool, under `muructl run`. Shows what happens when the
factory is served without being named as one, gives each worker a pool
of its own and then shares one from the host to see why that is risky,
turns on `INFO` logging for `app.logger` from the project's table,
lets Muru answer for a failing view through `FLASK_PROPAGATE_EXCEPTIONS`
in the table's environment, and watches Flask serve its static files.
Compares with what `flask run`, gunicorn and mod_wsgi do with a
factory.

About 25 minutes, in two terminals with a document, the project's files
and the shop in a pane above them. It installs `muructl` 0.1.0a20 and
Flask into an environment of its own, and serves on port 8080 unless you
change it.
