# FastAPI and Starlette on the event loop

Serves a small FastAPI price service under `muructl run`. Shows the
lifespan running once in each worker and what a failing one does,
where `async def`, plain `def` and `asyncio.to_thread` path operations
run, how many of each a worker takes at once and what `--sync-threads`
changes, and what a blocking call does to the event loop: every
request in the worker waits, until the loop stall timeout replaces the
worker. Compares with uvicorn and gunicorn.

About 30 minutes, in two terminals with a document and the code in an
area above them. It installs `muructl` 0.1.0a20 and FastAPI into an
environment of its own, and serves on port 8080 unless you change it.
