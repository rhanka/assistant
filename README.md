# Assistant Monorepo (scheduler + workers + AI) — Skeleton

**Decisions locked:**
- **Package manager**: npm workspaces (no Nx).
- **UI**: SvelteKit (English + French).
- **API**: NestJS (GraphQL code‑first + REST/OpenAPI) with **Prisma** (PostgreSQL).
- **Jobs**: BullMQ + Redis; **workers** in Node.
- **Scheduler**: TS library/service (Plan → DAG → enqueue).
- **AI service**: Python FastAPI (inside `packages/ai`).
- **GitHub**: REST (Issues/PR) + GraphQL (Projects v2).
- **Cursor**: Web Agents piloted via **Playwright** (rules in `.cursor/rules/*.mdc`).

## Quick start (dev)
1. `cp .env.example .env` and edit values.
2. `docker compose up -d postgres redis`  (optional: `docker compose up -d` to run all services)
3. `npm install`
4. DB setup (Prisma): `make db.init && make db.migrate`
5. Start services: in separate terminals
   - API: `make api`
   - UI: `make ui`
   - Workers: `make workers`
   - AI: `make ai`

## Project layout
See `.cursor/rules/architecture.mdc` and `packages/*`.
