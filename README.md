# Netiks Store

Netiks Store is a multi-vendor e-commerce platform with a storefront, seller dashboard, checkout flow, and supporting backend services.

## Workspace Layout

```text
apps/
  web/
  gateway/
services/
  identity-service/
  vendor-service/
  catalog-service/
  media-service/
  admin-service/
packages/
  shared-python/
  shared-types/
infra/
  docker/
  terraform/
scripts/
docs/
```

## Quick Start

1. Copy `.env.example` to `.env`.
2. Install frontend dependencies with `npm install`.
3. Sync Python workspaces with `uv sync`.
4. Start Docker Desktop and wait until it shows that Docker is running.
5. Start the stack with `docker compose up --build -d`.
6. Open `http://localhost:3001`.

## First Task For Interns

The first task is to run the project locally with Docker and show proof that it is working.

Suggested proof:

- a screenshot of Docker Desktop or `docker compose ps`
- a screenshot of the home page or market page in the browser
- a short note showing the URL used: `http://localhost:3001`

## Demo Data Reset

Run `npm run seed:demo` while the Docker stack is up to load the default marketplace data:

- 3 vendor accounts with storefronts
- 3 stores and categories
- 6 published products with real product photos
- starter order history that updates stock and sold counts

## Current Working Backend Surface

The following flows are implemented and have been smoke-tested locally:

- Auth: register, login, `me`, refresh-token rotation
- Vendor: create store, get my store, public store lookup, store update
- Catalog: create/list categories, create/update products, public published-product lookup, owner product listing
- Media: authenticated upload through the gateway, direct media retrieval

Services that still need further expansion:

- richer admin moderation flows
- full product search/filtering
- cross-service ownership verification between catalog and vendor domains

## Local Service Endpoints

The frontend and gateway are exposed on the host. Backend services are internal to the Docker
network and are only reachable through the gateway - they do not bind to host ports.

| Service | Host address | Note |
|---|---|---|
| Frontend | `http://localhost:3001` | Next.js, exposed on host |
| Gateway | `http://localhost:8000` | All API calls go here |
| Identity service | internal :8001 | gateway only |
| Vendor service | internal :8002 | gateway only |
| Catalog service | internal :8003 | gateway only |
| Media service | internal :8004 | gateway only |
| Admin service | internal :8005 | gateway only |

## Docker Notes

- Each backend service runs Alembic migrations on container startup.
- The repo includes a root `.dockerignore` to keep build contexts smaller for GitHub and CI.
- If port `5432` is already in use on a machine, set `POSTGRES_EXPOSE_PORT` in `.env` before running Compose.
- If the stack has already been run before and you want clean marketplace data again, use `npm run seed:demo`.
- If you change code and want to rebuild everything, run `docker compose up --build -d` again.

## Environments

| Environment | URL | Deployment |
|---|---|---|
| Production | served via Nginx on port 80 | manual `docker compose -f docker-compose.yml -f docker-compose.prod.yml up` |
| Staging | served via Nginx on port 8080 | automatic on every push to `main` via GitHub Actions |

## Documentation

- [Intern Quickstart Guide](docs/INTERN_QUICKSTART_GUIDE.md)
- [PRD](docs/PRD.md)
- [Project Documentation](docs/PROJECT_DOCUMENTATION.md)
- [Technical Plan](docs/TECHNICAL_PLAN.md)
- [Deployment Challenge Lab](docs/DEPLOYMENT_CHALLENGE_LAB.md)
- [Terraform Infrastructure](infra/terraform/README.md)
