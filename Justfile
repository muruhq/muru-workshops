# Muru workshops. Run `just` to list targets.

repo := "https://github.com/muruhq/muru-workshops"

# The catalog names every collection in this course, so one URL offers
# them all; each collection has an index of its own under
# collections/<name>/, with an id that never changes.
catalog_title := "Muru workshops"
catalog_description := "Guided JupyterLab workshops on Muru, the routing edge, control plane and Python runtime for WSGI and ASGI applications."

introduction_id := "grahamdumpleton.me/muru/introduction"
introduction_title := "Meet Muru"
introduction_description := "Guided JupyterLab workshops introducing Muru: where it fits among Python web servers, what it does while you develop, and how its daemon deploys releases without downtime, compared throughout with Apache and mod_wsgi, gunicorn, uvicorn and Granian."

# The Meet Muru collection, in the order to take it. OUTLINE.md is the
# design this list follows; `just index` writes the index in this order,
# skipping any not written yet, so the order lives here and nowhere else.
introduction := "where-muru-fits what-muructl-run-tells-you reload-and-https-in-development import-once-fork-safely processes-threads-and-the-gil wsgi-and-asgi-together deploying-without-downtime canary-a-release what-nginx-was-for bring-your-server-along"

developing_id := "grahamdumpleton.me/muru/developing"
developing_title := "Developing with muructl run"
developing_description := "Guided JupyterLab workshops on developing a Flask, Django or FastAPI project under muructl run: where its settings live, what each framework needs, the hooks around the fork, reload and HTTPS fitted to a real project, what happens when a request hangs, and a request stopped at a breakpoint."

# The Developing with muructl run collection, in the order to take it.
developing := "settings-in-the-project serving-a-flask-project serving-a-django-project fastapi-on-the-event-loop every-hook-in-order reload-and-https-your-way when-a-request-hangs stopping-at-a-breakpoint"

# List available targets.
default:
    @just --list

# Set up the environment: sync uv, fetch the reference checkouts, download the self-test browser, link the authoring skill.
install:
    uv sync
    git submodule update --init
    uv run playwright install chromium
    just skill

# The skill ships inside the jupyterlab-workshop package. Linking it into
# .claude/skills lets Claude Code load it without a copy in this
# repository, and it tracks the pinned release; `just bump` relinks it.
# Link the authoring skill from the installed package into .claude/skills.
skill:
    uv run jupyter workshop skill --link

# JupyterLab must run from this directory: the extension lists workshops/
# as installed, and the MCP live tools open workshops by paths relative
# to this root, such as workshops/<name>.
# Start JupyterLab from the checkout, listing the workshops in each collection's order.
[positional-arguments]
lab *ARGS:
    uv run jupyter lab --config=jupyter_lab_config.py "$@"

# Scaffold a new workshop under workshops/; extra args go to `jupyter workshop init`.
[positional-arguments]
new NAME *ARGS:
    shift; uv run jupyter workshop init workshops/{{NAME}} "$@"

# Lint the catalog, every collection index and every workshop, or only the workshops named.
lint *NAMES:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    names=({{NAMES}})
    if [ ${#names[@]} -eq 0 ]; then
        uv run jupyter workshop lint catalog.json
        for index in collections/*/collection.json; do
            uv run jupyter workshop lint "$index"
        done
        dirs=(workshops/*/)
    else
        dirs=("${names[@]/#/workshops/}")
    fi
    if [ ${#dirs[@]} -eq 0 ]; then
        echo "No workshops under workshops/ yet"
        exit 0
    fi
    for dir in "${dirs[@]}"; do
        echo "== $dir"
        uv run jupyter workshop lint "$dir"
    done

# Render one workshop as HTML to check what a page looks like; extra args go to `jupyter workshop render`.
[positional-arguments]
render NAME *ARGS:
    shift; uv run jupyter workshop render workshops/{{NAME}} "$@"

# The self-test runs the workshop's actions and checks for real, as you,
# on this machine; only the workshop directory is protected, by a
# temporary copy. Read the workshop first.
# Self-test one workshop in a JupyterLab of its own; extra args go to `jupyter workshop test`.
[positional-arguments]
test NAME *ARGS:
    shift; uv run jupyter workshop test workshops/{{NAME}} "$@"

# Self-test every workshop, writing a JUnit report for each.
test-all:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    for dir in workshops/*/; do
        name=$(basename "$dir")
        echo "== $dir"
        uv run jupyter workshop test "$dir" --junit "results-$name.xml"
    done

# Write or refresh every collection index and the catalog.
index: index-introduction index-developing catalog

# The workshop directories are named one by one, in the collection's
# order, which is how `jupyter workshop index` is told the order to
# write; naming only the directories that exist lets the index be
# refreshed while the collection is still being written. The repository
# URL is given explicitly so the index does not depend on a git remote
# being configured in the checkout.
# Write or refresh collections/introduction/collection.json in the collection's order.
index-introduction:
    #!/usr/bin/env bash
    set -euo pipefail
    dirs=()
    for name in {{introduction}}; do
        if [ -d "workshops/$name" ]; then
            dirs+=("workshops/$name")
        fi
    done
    if [ ${#dirs[@]} -eq 0 ]; then
        echo "No introduction workshops under workshops/ yet; collections/introduction/collection.json is left as it is"
        exit 0
    fi
    uv run jupyter workshop index "${dirs[@]}" --root . --out collections/introduction/collection.json --repo "{{repo}}" --id "{{introduction_id}}" --title "{{introduction_title}}" --description "{{introduction_description}}" --homepage "{{repo}}" --ordered

# Write or refresh collections/developing/collection.json in the collection's order.
index-developing:
    #!/usr/bin/env bash
    set -euo pipefail
    dirs=()
    for name in {{developing}}; do
        if [ -d "workshops/$name" ]; then
            dirs+=("workshops/$name")
        fi
    done
    if [ ${#dirs[@]} -eq 0 ]; then
        echo "No developing workshops under workshops/ yet; collections/developing/collection.json is left as it is"
        exit 0
    fi
    mkdir -p collections/developing
    uv run jupyter workshop index "${dirs[@]}" --root . --out collections/developing/collection.json --repo "{{repo}}" --id "{{developing_id}}" --title "{{developing_title}}" --description "{{developing_description}}" --homepage "{{repo}}" --ordered

# Write or refresh catalog.json from the collection indexes, recorded by relative path.
catalog:
    uv run jupyter workshop catalog catalog.json collections/*/collection.json --relative --title "{{catalog_title}}" --description "{{catalog_description}}" --homepage "{{repo}}"

# Binder installs from binder/requirements.txt, so it is the locked
# runtime set (no dev group) exported from uv.lock, and is regenerated
# whenever the lock changes.
# Relock and export the runtime dependencies to binder/requirements.txt.
requirements:
    uv lock
    uv export --no-dev --no-hashes --no-annotate -o binder/requirements.txt

# `course update` moves the pin in pyproject.toml and the requirements,
# writes again every generated file that is still as generated, and
# reports the ones edited here, which are left alone. The extension's
# reference checkout is what agents read for the workshop format beyond
# the skill, so it moves with the pin.
# Pin a new jupyterlab-workshop release, refresh the generated files, relock, relink the skill and move the reference checkout.
bump VERSION:
    uv run jupyter workshop course update . --version {{VERSION}}
    just requirements
    just skill
    git -C reference/jupyterlab-workshop fetch --tags
    git -C reference/jupyterlab-workshop checkout "{{VERSION}}"
    git add reference/jupyterlab-workshop

# reference/muru is the documentation and source of the release the
# workshops teach. Its tags are v0.1.0-alpha.10 where PyPI says
# 0.1.0a10, so the tag is given as it is in the repository. Every
# workshop pins muructl in its own requirements.txt, which this does
# not touch.
# Move the Muru reference checkout to a release tag, such as v0.1.0-alpha.16.
bump-muru TAG:
    git -C reference/muru fetch --tags
    git -C reference/muru checkout "{{TAG}}"
    git add reference/muru
    @echo "Now update muructl in every workshops/*/requirements.txt, then just test-all"

# A workshop's kernelspec is registered for the user, outside the
# checkout, so removing the environment directory leaves a kernel in
# the launcher that points at a Python that no longer exists. The prune
# unregisters only the workshop kernelspecs whose environment is gone.
# Remove what opening, running and publishing the workshops leaves behind, and the kernelspecs left pointing at removed environments.
clean:
    rm -rf workshops/*/_workshop workshops/*/work workshops/*/dist workshops/*/scratch
    rm -f results-*.xml
    find . -type d -name .ipynb_checkpoints -not -path "./.venv/*" -exec rm -rf {} +
    find . -type d -name __pycache__ -not -path "./.venv/*" -not -path "./scratch/*" -exec rm -rf {} +
    uv run jupyter workshop kernels --prune

# Also remove the environment and the skill link; run `just install` afterwards.
distclean: clean
    rm -rf .venv .claude/skills/jupyterlab-workshop-authoring
    git submodule deinit -f reference/jupyterlab-workshop reference/muru
