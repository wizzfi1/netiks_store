# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Netiks Store: a multi-vendor e-commerce platform with a Next.js storefront, a FastAPI gateway, and four independent FastAPI backend services, all backed by a single Postgres instance. No test suite exists yet in this repo (no `test_*.py`, no `.test.ts` files, no `conftest.py`) — do not assume one when asked to "run tests."

## Common commands

Frontend (run from repo root; npm workspaces):
- `npm install` — install root + `apps/web` + `packages/shared-types` deps
- `npm run dev:web` — run the Next.js dev server for `apps/web`
- `npm run build:web` — production build
- `npm run lint:web` — ESLint for `apps/web`
- `npm run seed:demo` — runs `scripts/seed-demo-marketplace.mjs` against a running Docker stack to (re)load demo vendors/stores/products/orders

Python services (uv workspace defined in root `pyproject.toml`):
- `uv sync` — install all Python workspace members (`apps/gateway`, all `services/*`, `packages/shared-python`)
- Run a single service locally: `cd services/<name>-service && uv run uvicorn app.main:app --reload --port <port>`
- Alembic migrations (catalog, identity, vendor services only — media and admin have none): `cd services/<name>-service && uv run alembic upgrade head` / `uv run alembic revision --autogenerate -m "..."`
- Lint: `uv run ruff check .` (line-length 100, target py311, configured in root `pyproject.toml`)

Full stack (Docker Compose):
- `docker compose up --build -d` — builds and starts web, gateway, all 5 services, postgres, redis
- Each backend service Dockerfile runs `alembic upgrade head` before `uvicorn` on container start (except media-service and admin-service, which have no migrations)
- Rebuild after code changes: `docker compose up --build -d` again
- If port 5432 is taken, set `POSTGRES_EXPOSE_PORT` in `.env`

## Local service ports

| Service | Port |
|---|---|
| web (frontend) | 3001 (host) → 3000 (container) |
| gateway | 8000 |
| identity-service | 8001 |
| vendor-service | 8002 |
| catalog-service | 8003 |
| media-service | 8004 |
| admin-service | 8005 |

The frontend never talks to backend services directly — it always goes through the gateway at `/api/v1/*`.

## Architecture

**Request flow**: Next.js (`apps/web`) → Gateway (`apps/gateway`) → individual FastAPI services → Postgres. The gateway is a pure proxy/aggregator: its route handlers (`apps/gateway/app/routes/*.py`) do not contain business logic, they just validate/forward auth and re-shape requests with `httpx.AsyncClient`, targeting service URLs from `app/config.py` (`Settings`, env-driven, e.g. `CATALOG_SERVICE_URL`).

**Auth model**: The gateway has no independent session/JWT verification of its own. `apps/gateway/app/deps.py::extract_user_context_from_request` calls `identity-service`'s `GET /auth/me` with the caller's `Authorization` header on every authenticated request, then forwards the resolved user id downstream as an `x-user-id` header. Backend services trust `x-user-id` unconditionally — they never validate it themselves — so `x-user-id` must never be settable directly by external clients; it should only ever be set by the gateway.

**Cross-service ownership checks**: Services call each other directly (bypassing the gateway) for internal verification, e.g. `services/catalog-service/app/vendor_client.py::verify_store_ownership` calls `vendor-service`'s `/internal/stores/{id}` to confirm the product's target store belongs to the requesting user and is active before allowing product creation. When adding new cross-domain writes, follow this pattern (an `internal/*` endpoint on the owning service, called service-to-service) rather than trusting client-supplied ownership data.

**Per-service internal layering**: Each Python service (`identity`, `vendor`, `catalog`) follows the same internal structure: `routes.py` (FastAPI endpoints, request/response only) → `service.py` (business logic) → `repository.py` (SQLAlchemy queries) → `models.py` (ORM models) → `database.py` (session/engine setup). `schemas.py` holds Pydantic request/response models. `media-service` and `admin-service` are simpler and don't yet follow the full layering (no repository/models — media-service is single-file business logic in `service.py`).

**Shared code**:
- `packages/shared-python` (`netiks_shared`) — installed into every Python service's image. `config.py::CommonSettings` is the base Pydantic settings class every service's own `Settings` extends (each service adds its own fields, e.g. gateway adds `*_SERVICE_URL` fields). It reads a shared root `.env` file by resolving `parents[4]` from its own file location — if you move `shared-python` to a different depth, this path breaks. `health.py` provides the standard `/health/live` and `/health/ready` routes mounted by every service.
- `packages/shared-types` — TypeScript types shared into `apps/web` via the npm workspace.

**Frontend structure** (`apps/web/src`): Next.js App Router. Route handlers under `src/app/**/actions/**/route.ts` and `src/app/api/[...path]/route.ts` act as server-side proxies to the gateway (mirroring the same "no client-side direct backend calls" rule). `src/lib/api.ts` centralizes all gateway fetch calls used by server components; it resolves the gateway base URL from `INTERNAL_API_BASE_URL` (used inside Docker, points at `http://gateway:8000`) falling back to `NEXT_PUBLIC_API_BASE_URL`. `src/lib/session.ts` handles auth/session persistence, `src/lib/types.ts` holds frontend-side response shapes mirroring backend schemas.

**Media**: `media-service` stores uploads on a Docker volume (`media_uploads` → `UPLOAD_DIR=/app/uploads`) and serves them directly; the frontend resolves relative media paths against the media-service host directly (`resolveMediaUrl` in `src/lib/api.ts`), not through the gateway.

## Known gaps (per README)

- No richer admin moderation flows yet in `admin-service`
- No full product search/filtering in `catalog-service`
- Cross-service ownership verification only exists for store↔product (catalog→vendor); other domains don't have it yet
