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
build.api:
	docker compose build api

up.api:
	docker compose up -d api

down.api:
	docker compose stop api

rebuild.api: build.api up.api

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
	docker compose exec api npm run -w packages/scripts i18n:check

check: scripts.i18n

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
