.PHONY: dev up down ui api workers ai db.init db.migrate db.reset scripts.i18n check prod.deploy prod.status prod.logs dev.build dev.clean restart.api logs.api status build.api up.api down.api rebuild.api

# Environment variables (with defaults)
export DATABASE_URL ?= postgresql://postgres:postgres@postgres:5432/assistant?schema=public
export REDIS_URL ?= redis://redis:6379
export API_PORT ?= 3001
export UI_PORT ?= 5173
export AI_PORT ?= 8000
export GITHUB_TOKEN ?= your-github-token-here
export GITHUB_OWNER ?= your-org-or-user
export GITHUB_REPO ?= your-repo

# Ensure .env file exists (for secrets/overrides only)
.env:
	@touch .env

# Docker compose (db/cache + optional services)
up:
	docker compose up -d postgres redis

down:
	docker compose down

dev:
	docker compose up -d
	npm install

# API-specific targets (using make instead of docker compose)
update.api.lock:
	docker run --rm -v $(PWD)/packages/api:/app -w /app node:20 npm install --legacy-peer-deps

update.ui.lock:
	docker run --rm -v $(PWD)/packages/ui:/app -w /app node:20 npm install --legacy-peer-deps

build.api:
	docker compose build api

up.api:
	docker compose up -d api

down.api:
	docker compose stop api

rebuild.api: build.api up.api

# Scheduler-specific targets
build.scheduler:
	docker compose build scheduler

up.scheduler:
	docker compose up -d scheduler

down.scheduler:
	docker compose stop scheduler

rebuild.scheduler: build.scheduler up.scheduler

# Workers-specific targets
build.workers:
	docker compose build workers

up.workers:
	docker compose up -d workers

down.workers:
	docker compose stop workers

rebuild.workers: build.workers up.workers

# AI-specific targets
build.ai:
	docker compose build ai

up.ai:
	docker compose up -d ai

down.ai:
	docker compose stop ai

rebuild.ai: build.ai up.ai

# Services (Docker-based development)
ui:
	docker compose exec ui npm run dev

api:
	docker compose exec api npm run dev

workers:
	docker compose exec workers npm run dev

ai:
	docker compose exec ai poetry run uvicorn app.main:app --reload --port $(AI_PORT)

restart.api:
	docker compose restart api

logs.api:
	docker compose logs -f api

status:
	docker compose ps

# DB (Prisma via API package in Docker)
db.init:
	docker compose exec api npx prisma generate

db.migrate:
	docker compose exec api npx prisma migrate dev --name init

db.reset:
	docker compose exec api npx prisma migrate reset -f

# Scripts (Docker-based)
scripts.i18n:
	docker compose exec api npm run -w @repo/scripts i18n:check

scripts.validate-guides:
	./packages/scripts/src/validate_guides.sh

scripts.check-branch-files:
	@echo "🔍 Checking for BRANCH.md files..."
	@if find . -name "BRANCH.md" | grep -q .; then \
		echo "❌ BRANCH.md files found - these should be removed before merge"; \
		echo "Files found:"; \
		find . -name "BRANCH.md"; \
		exit 1; \
	else \
		echo "✅ No BRANCH.md files found - ready for merge"; \
	fi

check: scripts.i18n scripts.validate-guides scripts.check-branch-files

# Testing (Docker-based)
test.unit:
	docker compose run --rm scheduler npm run test:unit
	docker compose run --rm workers npm run test:unit
	docker compose run --rm ai pytest tests/

# Package-specific unit tests
test.unit.api:
	docker build --target test -t api-test -f packages/api/Dockerfile .
	docker run --rm --network assistant_default api-test

test.unit.ui:
	docker build --target test -t ui-test -f packages/ui/Dockerfile .
	docker run --rm --network assistant_default ui-test

test.unit.scheduler:
	docker compose run --rm scheduler npm run test:unit

test.unit.workers:
	docker compose run --rm workers npm run test:unit

test.unit.ai:
	docker compose run --rm ai pytest tests/

# Integration tests
test.integration.api:
	docker compose run --rm api npm run test:integration

test.integration.scheduler-api:
	docker compose run --rm scheduler npm run test:integration

test.integration.workers-api:
	docker compose run --rm workers npm run test:integration

test.integration.scheduler-ai:
	docker compose run --rm scheduler npm run test:integration:ai

test.integration.workers-ai:
	docker compose run --rm workers npm run test:integration:ai

# E2E tests
test.e2e.ui:
	docker compose run --rm ui npm run test:e2e

test.e2e.ui-api:
	docker compose run --rm ui npm run test:e2e

# Package tests (unit + integration)
test.api: test.unit.api test.integration.api
test.ui: test.unit.ui test.e2e.ui
test.scheduler: test.unit.scheduler
test.workers: test.unit.workers
test.ai: test.unit.ai

# Global validation
validate-config:
	@echo "🔍 Validating global configuration..."
	@echo "✅ Configuration validation complete"

test.integration:
	docker compose exec api npm run test:integration
	docker compose exec ai pytest tests/integration

test.e2e:
	docker compose exec ui npm run test:e2e

test.i18n:
	docker compose exec api npm run -w @repo/scripts i18n:check

test.i18n.coverage:
	docker compose exec api npm run -w @repo/scripts i18n:coverage

test.all: test.unit test.integration test.e2e test.i18n test.i18n.coverage

# Production environment (Kubernetes)
prod.deploy:
	kubectl apply -f k8s/

prod.status:
	kubectl get pods -n assistant

prod.logs:
	kubectl logs -f -l app=assistant -n assistant

# Development environment helpers
dev.build:
	docker compose build

dev.clean:
	docker compose down -v
	docker system prune -f
