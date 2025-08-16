# Assistant is a toolset to enable to maximise use of AI in daily work

## Developement directives (for AI)
See `.cursor/rules/architecture.mdc`, `.cursor/rules/workflow.mdc`, `.cursor/rules/conventions.mdc`, `.cursor/rules/*.mdc`

## Project Goals & Guiding Principles
**Purpose.** Build a principal assistant that can plan, delegate, and safely execute work across your devices and tools. The system must support multimodal, multi‑device interaction and cleanly separate **planning** from **execution**.

**Plans‑first (your initial remark).** We treat **Plan** as a first‑class artifact (product/roadmap level) and **Task** as an executable unit. A Plan groups Tasks toward an objective and can follow Agile/Kanban/Waterfall practices. Execution is modeled as a **DAG** (Directed Acyclic Graph) derived from the Plan. We maintain a clear boundary between **Plan building** (done today via API+UI capabilities) and **Task scheduling/execution** (the **Scheduler** compiles Plan → DAG and enqueues jobs for **Workers**). Re‑planning must be safe, auditable, and non‑destructive.

**Guiding principles.**
- **Human‑in‑the‑loop**: preview/dry‑run by default; explicit approvals for risky actions.
- **Least privilege & auditability**: granular scopes, immutable logs, reproducible runs.
- **Small, explainable changes**: one capability per PR; idempotent jobs; deterministic scripts.
- **Modularity**: bounded contexts (**UI**, **API**, **Scheduler**, **Workers**, **AI service**), replaceable integrations.
- **Minimal tooling first**: no heavy monorepo framework; simple **Make** + npm workspaces; add optimization later only if needed.
- **Language policy**: code/comments/API/docs/rules in **English**; UI localized **EN/FR** with `/en` and `/fr` routes.


## Decisions locked
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
.
├─ .cursor/...            # AI coding cursor rules
│  └─ rules/
│     ├─ architecture.mdc
│     ├─ conventions.mdc
│     ├─ language.mdc
│     ├─ playwright.mdc
│     ├─ security.mdc
│     └─ workflow.mdc
├─ packages/
│  ├─ ui/                 # SvelteKit app (EN/FR)
│  ├─ api/                # NestJS (GraphQL + REST/OpenAPI, Prisma/PostgreSQL)
│  ├─ scheduler/          # Plan → DAG compiler + BullMQ enqueue
│  ├─ workers/            # BullMQ job executors (GitHub, Cursor/Playwright, sync)
│  ├─ ai/                 # Python FastAPI (model-driven endpoints)
│  ├─ integrations/
│  │  ├─ github/          # GitHub REST/GraphQL helpers
│  │  └─ cursor/          # Playwright helpers for Cursor Web Agents
│  ├─ schemas/            # JSON Schemas (Plan, Task, Step)
│  ├─ plan-kernel/        # Shared types & DAG validation (TS)
│  └─ scripts/            # DB init/migrate/reset, i18n check, release prep
├─ .github/
│  └─ workflows/
│     └─ ci.yml           # CI (build + i18n check)
├─ docker-compose.yml     # Postgres, Redis, services
├─ Makefile               # dev, db, services, checks
├─ package.json           # npm workspaces (no Nx)
├─ tsconfig.base.json
├─ README.md
├─ RELEASE.md
├─ TODO.md
├─ .env.example
├─ .gitignore
└─ LICENSE
