#!/bin/bash
# Run once when the codespace is created. Does what the Binder postBuild
# does, in the codespace: installs JupyterLab and the extension from the
# same pinned requirements the Binder image uses, fills a wheelhouse for
# the workshops' environments, and writes the JupyterLab overrides, with
# two differences, both because a codespace belongs to the person who
# created it, tied to their GitHub account, and persists, where a Binder
# session is an anonymous, temporary container. The welcome message is
# the Codespaces one. And workshops are not forced to trusted, so the
# learner is shown what a workshop asks to do and decides before it runs
# anything in their codespace.
#
# The analytics setting is Binder's: it reports every session's
# progress events to the sink each collection index's analytics block
# names, without asking, and the events say they came from Codespaces.
# The welcome message tells the learner that progress is reported.
set -euo pipefail

cd "$(dirname "$0")/.."

python -m pip install --no-cache-dir -r binder/requirements.txt

shopt -s nullglob

wheels="${HOME}/.wheels"

mkdir -p "$wheels"

for requirements in workshops/*/requirements.txt; do
  python -m pip download --disable-pip-version-check -d "$wheels" -r "$requirements"
done

python -m pip download --disable-pip-version-check -d "$wheels" ipykernel

mkdir -p "${HOME}/.config/pip"

cat > "${HOME}/.config/pip/pip.conf" <<CONF
[global]
find-links = ${wheels}
CONF

# muructl supplies the runtime library, muru, itself: the first run on
# an interpreter unpacks the copy matching muructl's version into its
# user cache, fetching the wheel from PyPI. Fill the cache now for this
# Python, which the workshops' environments are made from, so the first
# run in a session fetches nothing. muructl, installed from the
# wheelhouse into a throwaway directory, checks a one-line application,
# which provides the library as a run would.
prefill="$(mktemp -d)"

grep -h '^muructl==' workshops/*/requirements.txt | sort -u > "$prefill/requirements.txt"
python -m pip install --disable-pip-version-check --no-index --find-links "$wheels" \
  --target "$prefill/muructl" -r "$prefill/requirements.txt"
printf 'def application(environ, start_response):\n    start_response("200 OK", [])\n    return [b""]\n' > "$prefill/app.py"
(cd "$prefill" && "$prefill/muructl/bin/muructl" check app:application --python "$(command -v python)")
rm -rf "$prefill"

# The overrides live in JupyterLab's application settings directory. Ask
# JupyterLab for it rather than assuming the Python prefix, and use sudo
# for a directory this user cannot write.
settings="$(python -c 'import os; from jupyterlab.commands import get_app_dir; print(os.path.join(get_app_dir(), "settings"))')"

overrides="$(mktemp)"

cat > "$overrides" <<'JSON'
{
  "@jupyterlab-workshop/labextension:panel": {
    "defaultWorkshop": "",
    "browseOnStart": true,
    "workshopsDirectory": "workshops",
    "collections": [
      "collections/introduction/collection.json",
      "collections/developing/collection.json"
    ],
    "welcome": ".devcontainer/welcome.md",
    "disabledFeatures": [
      "open-directory",
      "open-url",
      "collections",
      "catalogs",
      "remove",
      "author",
      "library",
      "personal",
      "ai-authoring",
      "journal",
      "mentor"
    ],
    "analytics": {
      "report": "always"
    }
  },
  "@jupyterlab/apputils-extension:notification": {
    "fetchNews": "false"
  }
}
JSON

if mkdir -p "$settings" 2>/dev/null && [ -w "$settings" ]; then
  install -m 644 "$overrides" "$settings/overrides.json"
else
  sudo mkdir -p "$settings"
  sudo install -m 644 "$overrides" "$settings/overrides.json"
fi

rm -f "$overrides"

echo "Wrote the JupyterLab overrides to $settings/overrides.json"
