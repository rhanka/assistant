# Assistant is a toolset to enable to maximise use of AI in daily work

## Development directives (for AI)
See `.cursor/rules/MASTER.mdc` for consolidated rules, then relevant sub `.mdc` files

## Project Goals
Build a principal assistant that can plan, delegate, and safely execute work across your devices and tools. The system must support multimodal, multi‑device interaction and cleanly separate **planning** from **execution**.

**Plans‑first** We treat **Plan** as a first‑class artifact (product/roadmap level) and **Task** as an executable unit. A Plan groups Tasks toward an objective and can follow Agile/Kanban/Waterfall practices. Execution is modeled as a **DAG** (Directed Acyclic Graph) derived from the Plan. We maintain a clear boundary between **Plan building** (done today via API+UI capabilities) and **Task scheduling/execution** (the **Scheduler** compiles Plan → DAG and enqueues jobs for **Workers**). Re‑planning must be safe, auditable, and non‑destructive.

## Guiding principles
- **Human‑in‑the‑loop**: preview/dry‑run by default; explicit approvals for risky actions.
- **Least privilege & auditability**: granular scopes, immutable logs, reproducible runs.
- **Small, explainable changes**: one capability per PR; idempotent jobs; deterministic scripts.
- **Modularity**: bounded contexts (**UI**, **API**, **Scheduler**, **Workers**, **AI service**), replaceable integrations.
- **Minimal tooling first**: no heavy monorepo framework; simple **Make** + npm workspaces; add optimization later only if needed.
- **Language policy**: code/comments/API/docs/rules in **English**; UI localized **EN/FR** with `/en` and `/fr` routes.

## Scoping & Use Cases
**Deliver exactly the value you outlined, now expressed in English.**
1) **Multi‑channel calendar management** (create, triage, conflict resolution, confirmations).  
2) **Email & messaging pilot** (drafts, summaries, priority triage).  
3) **Web research + synthesis** (sources cited, action plan).  
4) **Workstation automation** (rename, classify, extract, launch apps; browser‑first).  
5) **Personal recurring tasks** (reminders, follow‑ups, checklists).  
6) **Hands‑free voice commands** (PC and smartphone; staged after MVP).  
7) **Delegation to specialized executors** (now expressed as *Scheduler + Workers* instead of “agents”).

---

## Requirements & Constraints
- **Functional**: multimodal (voice/text/screen), multi‑device (web/desktop/mobile), **Plans vs Tasks** separation, live progress state, preview/dry‑run.  
- **Non‑functional**: low latency for UI and voice, graceful degradation offline, bounded cost.  
- **Regulatory**: GDPR (General Data Protection Regulation) / PIPEDA (Personal Information Protection and Electronic Documents Act).  
- **Security**: IAM (Identity and Access Management), MFA (Multi‑Factor Authentication), SSO (Single Sign‑On), secret management, granular scopes.

---

## Reference Architecture (High Level)
> Adapted to our latest decisions (no Nx; SvelteKit; NestJS; Python AI; Make; npm workspaces; GitHub; Playwright).

**Core components**
- **UI (SvelteKit)** — bilingual EN/FR with `/en` and `/fr` routes, i18n checks in CI.  
- **API (NestJS)** — GraphQL (code‑first) **and** REST/OpenAPI; Prisma ↔ PostgreSQL.  
- **Scheduler (TypeScript)** — turns **Plan → DAG** (Directed Acyclic Graph), applies priorities/budgets/scopes, enqueues to BullMQ.  
- **Workers (TypeScript)** — BullMQ job executors (GitHub Issues/PR, GitHub Projects v2 later, Cursor via Playwright, sync tasks).  
- **AI service (Python FastAPI)** — model‑driven endpoints (summarize, later RAG), called over HTTP by API/Workers.  
- **Data stores** — PostgreSQL (plans/tasks/runs), Redis (queues).  
- **Integrations** — GitHub (REST + GraphQL), Cursor Web Agents (Playwright).  
- **Ops & tooling** — Make + npm workspaces, Docker Compose for local, GitHub Actions CI, `.cursor/rules/*.mdc` (workflow/architecture/sveltekit/playwright/conventions/security/language).  

**Flows (simplified)**
1) **Plan authoring** in UI/API → stored in PostgreSQL.  
2) **Compile Plan → DAG** (Scheduler) → enqueue **run‑task** jobs in BullMQ.  
3) **Workers** execute idempotent steps (e.g., sync to GitHub; open Cursor Agents in dry‑run first), log evidence, update status.  
4) **AI service** is invoked when language tasks are needed (e.g., summaries).  
5) **UI** shows Plans, Runs, approvals, and logs; multilingual content.

---

## Governance, Permissions & Compliance
- **Access model**: RBAC (Role‑Based Access Control) + ABAC (Attribute‑Based Access Control).  
- **Scopes**: explicit per integration (e.g., `github:issues:write`, `cursor:web_agent:open`, `db:migrate`).  
- **Just‑in‑time consent**: clear approval cards; immediate revocation.  
- **Policies**: delegation limits, cost ceilings, deny‑lists (e.g., destructive DB ops), mandatory preview.  
- **Legal**: data minimization, data subject rights, data residency, processing register, appointed DPO (Data Protection Officer).

---

## Execution Components (Scheduler & Workers) — Patterns & Contracts
> We avoid the term “agent” in code; we use **Scheduler** and **Workers**.

**Lifecycle**
1) Receive an **objective/plan** with constraints.  
2) Scheduler proposes a **DAG execution plan** (with rough estimates).  
3) Workers **execute** steps; every action emits evidence/logs.  
4) **Report back** (artifacts, metrics, next steps); write to audit log.  
5) **Learn** (optional rules/tuning), without breaking auditability.

**Contracts (extract)**
- **Inputs**: plan/task identifiers, scope tokens, budgets (time/cost/risk).  
- **Outputs**: artifacts, logs, metrics, status transitions.  
- **Security**: applicable policy, redaction of sensitive data, approval gates.

**Delegation**
- Use **delegation tokens** with scope, expiration, and depth; revocable at any time by policy.

---

## User Experience (Multimodal & Multi‑device)
- **Web/Desktop**: timeline views (**To do / In progress / Blocked / Done**), **Preview → Simulate → Execute** cards, **Run** dashboards.  
- **Mobile**: notifications with **Approve/Reject/Simulate** actions; share files into the assistant.  
- **Voice**: hotword optional, short confirmations, repair strategies; staged after MVP.  
- **Bilingual UI**: `/en` and `/fr`, language switch preserved across routes; i18n coverage enforced by CI.

---

## Workstation Automation (Acting on the Computer)
- **Browser‑first** automation via **Playwright** (stable and cross‑platform).  
- **Desktop RPA (Robotic Process Automation)** later: OS‑specific, sandboxed, guarded by click limits and allow‑lists.  
- **Security**: native keychain usage, scoped accessibility permissions, signed logs.

---

## Data, Memory & Retrieval‑Augmented Generation (RAG)
- **Memory schema**
  - **Profile** (preferences, style).  
  - **Knowledge** (docs/emails/procedures).  
  - **Episodes** (end‑to‑end task traces).  
- **Pipelines**: ingestion → classification → indexing (vector index later) → retention policies.  
- **RAG** (later increment): domain grounding for summaries/plans with explicit citations.

---

## Observability, Quality & Operations
- **Dashboards**: task/run success rate, cycle time, human‑intervention rate, cost per run, queue health.  
- **Alerts**: budget breaches, loops, repeated failures.  
- **Reproducibility**: replay a run from logs with fixed seeds/config.  
- **Explainability**: short justification per step; link to evidence.

---

## Advanced Security & Resilience
- **Zero‑trust** between services; encryption in transit/at rest.  
- **Egress filtering** for Workers; strict allow‑lists of external hosts.  
- **Failover** cloud ↔ local; durable queues; disaster recovery tested.  
- **Hardening**: regular penetration tests, dependency scanning, secret rotation.

---

## Validation & Evaluation
- **Golden tasks** with acceptance criteria (repeatable).  
- **Metrics**: success rate, time‑to‑complete, satisfaction, cost per task.  
- **User tests**: guided and free scenarios.  
- **Change management**: tutorials, ready‑made voice intents (later), playbooks.

---

## Roadmap by Increments
**Increment A — MVP (now)**
- Monorepo skeleton delivered (`ui` SvelteKit EN/FR; `api` NestJS GraphQL+REST/OpenAPI + Prisma/PostgreSQL; `scheduler`; `workers` BullMQ; `ai` FastAPI stub).  
- **.cursor/rules** (workflow/architecture/sveltekit/playwright/conventions/security/language) in English.  
- GitHub integration (create Issue via REST); Cursor Web Agents open via Playwright (dry‑run).  
- Scripts (`db:init`, `db:migrate`, `db:reset`, `i18n_check`, `release_prepare`).  
- CI (unified workflow with conditional testing + i18n check).  
- **Plans‑first** data model and DAG validation.

**Increment B — Planning & Sync**
- UI: Plans board/backlog; Runs view (status, logs).  
- API: **/compile** (Plan→DAG) + **/execute** (dry‑run + preview); Webhooks.  
- GitHub Projects v2 sync (GraphQL): roadmap columns/fields; PR scaffolding from tasks.  
- Secrets hardening; move from PAT to **GitHub App**; idempotent sync.

**Increment C — Control & Scale**
- Scheduler: budgets, scopes, **human approvals** gates; dynamic re‑planning; compensation steps.  
- Workers: retry policies, rate limiting, backoff; evidence store.  
- AI service: summaries + initial **RAG**; citations surfacing in UI.  
- Observability dashboards; SSO integration; desktop RPA pilot if still needed.

*(Each increment keeps changes small, auditable, and bilingual in the UI.)*

## Decisions locked
- **Package manager**: npm workspaces (no Nx).
- **UI**: SvelteKit (English + French).
- **API**: NestJS (GraphQL code‑first + REST/OpenAPI) with **Prisma** (PostgreSQL).
- **Jobs**: BullMQ + Redis; **workers** in Node.
- **Scheduler**: TS library/service (Plan → DAG → enqueue).
- **AI service**: Python FastAPI (inside `packages/ai`).
- **GitHub**: REST (Issues/PR) + GraphQL (Projects v2).
- **Cursor**: Web Agents piloted via **Playwright** (rules in `.cursor/rules/*.mdc`).

## Testing Strategy
Our CI/CD pipeline uses a unified workflow with conditional job execution based on file changes:

### **Test Types**
- **Unit Tests**: Individual component testing (`make test.unit.<component>`)
- **Integration Tests**: Component-to-component testing (`make test.integration.<component1>-<component2>`)
- **E2E Tests**: Full user workflow testing (`make test.e2e.<scenario>`)

### **CI Workflow**
- **Path-based triggers**: Jobs execute only when relevant files change
- **Dependency-aware**: Tests run in correct order (unit → integration → E2E)
- **Docker-first**: All tests run in containers via `make` commands
- **Parallel execution**: Independent jobs run simultaneously

### **Make Commands**
```bash
# Unit tests
make test.unit.api      # Test API component
make test.unit.ui       # Test UI component
make test.unit.scheduler # Test Scheduler component
make test.unit.workers  # Test Workers component
make test.unit.ai       # Test AI component

# Integration tests
make test.integration.scheduler-api    # Test Scheduler-API integration
make test.integration.workers-api      # Test Workers-API integration
make test.integration.scheduler-workers # Test Scheduler-Workers integration

# E2E tests
make test.e2e.ui-api    # Test UI-API end-to-end workflow
```

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

```
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
│     └─ ci.yml           # Unified CI with conditional testing
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
```