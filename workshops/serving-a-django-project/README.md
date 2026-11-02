# A Django project under muructl run

Serves a small Django project, `mysite` with a `catalog` app, from its
`wsgi.py` under `muructl run`, reloading on each change as a
development run does. Shows that the project needs
nothing added for Muru, why the admin has no styles under any server
but `runserver` and how `staticfiles_urlpatterns()` serves them in
development, Django's debug page beside Muru's error page with
`DEBUG_PROPAGATE_EXCEPTIONS`, and the same project from `asgi.py`, with
async views on the worker's event loop and sync views on Django's
threads. Compares with `runserver`, gunicorn, uvicorn and mod_wsgi.

About 30 minutes, in two terminals with a document, the project's
files and the site in a pane above them. It installs `muru` and
`muructl` 0.1.0a15 and Django 6.1.2 into an environment of its own,
and serves on port 8080 unless you change it.
