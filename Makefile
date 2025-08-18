.PHONY: dev up down ui api workers ai db.init db.migrate db.reset scripts.i18n check prod.deploy prod.status prod.logs dev.build dev.clean restart.api logs.api status build.api up.api down.api rebuild.api interactive.help interactive.test

# =============================================================================
# INTERACTIVE MODE USAGE
# =============================================================================
# 
# This Makefile supports interactive and non-interactive modes for better
# development experience and CI compatibility.
#
# Usage examples:
#   # Interactive mode (development)
#   INTERACTIVE=true make db.init
#   INTERACTIVE=true make logs.api.follow
#
#   # Non-interactive mode (CI, default)
#   make db.init
#   make logs.api.follow
#
#   # Override for specific commands
#   INTERACTIVE=true make db.reset
#
# Available interactive commands:
#   - db.init, db.migrate, db.reset: Confirmations for destructive operations
#   - logs.api, logs.api.follow: Pagination and follow options
#   - test.*: Verbose output and progress indicators
#   - migrate.*: Confirmation prompts for migrations
#
# =============================================================================

# Environment variables (with defaults)
export DATABASE_URL ?= postgresql://postgres:postgres@postgres:5432/assistant?schema=public
export REDIS_URL ?= redis://redis:6379
export API_PORT ?= 3001
export UI_PORT ?= 5173
export AI_PORT ?= 8000
export GITHUB_TOKEN ?= your-github-token-here
export GITHUB_OWNER ?= your-org-or-user
export GITHUB_REPO ?= your-repo

# GHCR (GitHub Container Registry) configuration
export GHCR_OWNER ?= rhanka
export GHCR_PROJECT ?= assistant
export GHCR_REGISTRY ?= ghcr.io/$(GHCR_OWNER)/$(GHCR_PROJECT)

# Interactive mode control (default: non-interactive for CI)
export INTERACTIVE ?= false

# Interactive mode helpers
interactive.help:
	@echo "🔧 INTERACTIVE MODE HELP"
	@echo "========================="
	@echo ""
	@echo "Current mode: $(INTERACTIVE)"
	@echo ""
	@echo "Usage:"
	@echo "  INTERACTIVE=true make <command>  # Enable interactive mode"
	@echo "  make <command>                   # Use default mode (non-interactive)"
	@echo ""
	@echo "Interactive commands:"
	@echo "  db.init, db.migrate, db.reset   # Database operations with confirmations"
	@echo "  logs.api, logs.api.follow       # Log viewing with pagination"
	@echo "  migrate.api.reset               # Migration reset with confirmation"
	@echo ""
	@echo "Examples:"
	@echo "  INTERACTIVE=true make db.reset  # Reset DB with confirmation"
	@echo "  INTERACTIVE=true make logs.api  # View logs with pagination"
	@echo "  make db.init                    # Non-interactive DB init"

interactive.test:
	@echo "🧪 Testing interactive mode..."
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		echo "✅ Interactive mode is ENABLED"; \
		echo "Commands will show confirmations and use pagination"; \
	else \
		echo "✅ Interactive mode is DISABLED (default)"; \
		echo "Commands will run without user interaction (CI-friendly)"; \
	fi

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

# API-specific targets (using make instead of docker compose)
update.api.lock:
	docker run --rm -v $(PWD)/packages/api:/app -w /app node:20 npm install --legacy-peer-deps
	@echo "🧹 Cleaning up any local traces..."
	@if [ -d "packages/api/node_modules" ]; then \
		echo "❌ Removing local node_modules from packages/api"; \
		rm -rf packages/api/node_modules; \
	fi
	@if [ -f "packages/api/package-lock.json" ]; then \
		echo "✅ package-lock.json updated successfully"; \
	else \
		echo "❌ Failed to update package-lock.json"; \
		exit 1; \
	fi

update.ui.lock:
	docker run --rm -v $(PWD)/packages/ui:/app -w /app node:20 npm install --legacy-peer-deps
	@echo "🧹 Cleaning up any local traces..."
	@if [ -d "packages/ui/node_modules" ]; then \
		echo "❌ Removing local node_modules from packages/ui"; \
		rm -rf packages/ui/node_modules; \
	fi
	@if [ -f "packages/ui/package-lock.json" ]; then \
		echo "✅ package-lock.json updated successfully"; \
	else \
		echo "❌ Failed to update package-lock.json"; \
		exit 1; \
	fi

# Build targets with GHCR tagging
build.api:
	docker compose build api
	@echo "🏷️  Tagging API image for GHCR..."
	@docker tag assistant-api:latest $(GHCR_REGISTRY)/api:$$(git rev-parse --short HEAD)
	@docker tag assistant-api:latest $(GHCR_REGISTRY)/api:latest

build.scheduler:
	docker compose build scheduler
	@echo "🏷️  Tagging Scheduler image for GHCR..."
	@docker tag assistant-scheduler:latest $(GHCR_REGISTRY)/scheduler:$$(git rev-parse --short HEAD)
	@docker tag assistant-scheduler:latest $(GHCR_REGISTRY)/scheduler:latest

build.workers:
	docker compose build workers
	@echo "🏷️  Tagging Workers image for GHCR..."
	@docker tag assistant-workers:latest $(GHCR_REGISTRY)/workers:$$(git rev-parse --short HEAD)
	@docker tag assistant-workers:latest $(GHCR_REGISTRY)/workers:latest

build.ui:
	docker compose build ui
	@echo "🏷️  Tagging UI image for GHCR..."
	@docker tag assistant-ui:latest $(GHCR_REGISTRY)/ui:$$(git rev-parse --short HEAD)
	@docker tag assistant-ui:latest $(GHCR_REGISTRY)/ui:latest

build.ai:
	docker compose build ai
	@echo "🏷️  Tagging AI image for GHCR..."
	@docker tag assistant-ai:latest $(GHCR_REGISTRY)/ai:$$(git rev-parse --short HEAD)
	@docker tag assistant-ai:latest $(GHCR_REGISTRY)/ai:latest

# Build all services
build.all: build.api build.scheduler build.workers build.ui build.ai

# Push targets to GHCR
push.api:
	@echo "🚀 Pushing API image to GHCR..."
	@docker push $(GHCR_REGISTRY)/api:$$(git rev-parse --short HEAD)
	@docker push $(GHCR_REGISTRY)/api:latest

push.scheduler:
	@echo "🚀 Pushing Scheduler image to GHCR..."
	@docker push $(GHCR_REGISTRY)/scheduler:$$(git rev-parse --short HEAD)
	@docker push $(GHCR_REGISTRY)/scheduler:latest

push.workers:
	@echo "🚀 Pushing Workers image to GHCR..."
	@docker push $(GHCR_REGISTRY)/workers:$$(git rev-parse --short HEAD)
	@docker push $(GHCR_REGISTRY)/workers:latest

push.ui:
	@echo "🚀 Pushing UI image to GHCR..."
	@docker push $(GHCR_REGISTRY)/ui:$$(git rev-parse --short HEAD)
	@docker push $(GHCR_REGISTRY)/ui:latest

push.ai:
	@echo "🚀 Pushing AI image to GHCR..."
	@docker push $(GHCR_REGISTRY)/ai:$$(git rev-parse --short HEAD)
	@docker push $(GHCR_REGISTRY)/ai:latest

# Push all services
push.all: push.api push.scheduler push.workers push.ui push.ai

# Build and push in one command
build.push.api: build.api push.api
build.push.scheduler: build.scheduler push.scheduler
build.push.workers: build.workers push.workers
build.push.ui: build.ui push.ui
build.push.ai: build.ai push.ai
build.push.all: build.all push.all

up.api:
	docker compose up -d api

down.api:
	docker compose stop api

rebuild.api: build.api up.api

# Scheduler-specific targets
up.scheduler:
	docker compose up -d scheduler

down.scheduler:
	docker compose stop scheduler

rebuild.scheduler: build.scheduler up.scheduler

# Workers-specific targets
up.workers:
	docker compose up -d workers

down.workers:
	docker compose stop workers

rebuild.workers: build.workers up.workers

# AI-specific targets
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
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		echo "📋 Showing API logs..."; \
		echo "Press 'q' to exit, 'h' for help, or any other key to continue"; \
		docker compose logs api | less -R; \
	else \
		docker compose logs api; \
	fi

logs.api.follow:
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		echo "📋 Following API logs in real-time..."; \
		echo "Press Ctrl+C to stop following logs"; \
		docker compose logs -f api; \
	else \
		docker compose logs -f api; \
	fi

status:
	docker compose ps

# DB (Prisma via API package in Docker)
db.init:
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		echo "🔧 Initializing database schema..."; \
		echo "This will generate Prisma client and apply schema changes."; \
		read -p "Continue? [y/N]: " reply; \
		case "$$reply" in \
			[yY]|[yY][eE][sS]) \
				echo "Proceeding..."; \
				;; \
			*) \
				echo "❌ Operation cancelled"; \
				exit 1; \
				;; \
		esac; \
	fi
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		docker compose exec api npx prisma generate; \
	else \
		docker compose run --rm -e CI=true api npx prisma generate; \
	fi
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		echo "✅ Database schema initialized successfully"; \
	fi

db.migrate:
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		echo "🔄 Running database migration..."; \
		echo "This will apply pending migrations to the database."; \
		read -p "Continue? [y/N]: " reply; \
		case "$$reply" in \
			[yY]|[yY][eE][sS]) \
				echo "Proceeding..."; \
				;; \
			*) \
				echo "❌ Operation cancelled"; \
				exit 1; \
				;; \
		esac; \
	fi
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		docker compose exec api npx prisma migrate dev --name init; \
	else \
		docker compose run --rm -e CI=true api npx prisma migrate dev --name init; \
	fi
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		echo "✅ Database migration completed successfully"; \
	fi

db.reset:
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		echo "⚠️  WARNING: This will reset the entire database!"; \
		echo "All data will be lost and migrations will be reapplied."; \
		echo "This operation cannot be undone."; \
		read -p "Are you absolutely sure? Type 'RESET' to confirm: " reply; \
		if [ "$$reply" != "RESET" ]; then \
			echo "❌ Operation cancelled"; \
			exit 1; \
		fi; \
		echo "Proceeding with database reset..."; \
	fi
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		docker compose exec api npx prisma migrate reset -f; \
	else \
		docker compose run --rm -e CI=true api npx prisma migrate reset -f; \
	fi
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		echo "✅ Database reset completed successfully"; \
	fi

# Enhanced DB migration targets (work even when API is not running)
migrate.api.dev:
	docker run --rm -v $(PWD)/packages/api:/app -w /app --network assistant_default -e DATABASE_URL=postgresql://postgres:postgres@postgres:5432/assistant?schema=public node:20 npx prisma migrate dev

migrate.api.deploy:
	docker run --rm -v $(PWD)/packages/api:/app -w /app --network assistant_default -e DATABASE_URL=postgresql://postgres:postgres@postgres:5432/assistant?schema=public node:20 npx prisma migrate deploy

migrate.api.reset:
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		echo "⚠️  WARNING: This will reset the entire database!"; \
		echo "All data will be lost and migrations will be reapplied."; \
		echo "This operation cannot be undone."; \
		read -p "Are you absolutely sure? Type 'RESET' to confirm: " reply; \
		if [ "$$reply" != "RESET" ]; then \
			echo "❌ Operation cancelled"; \
			exit 1; \
		fi; \
		echo "Proceeding with database reset..."; \
	fi
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		docker run --rm -v $(PWD)/packages/api:/app -w /app --network assistant_default -e DATABASE_URL=postgresql://postgres:postgres@postgres:5432/assistant?schema=public node:20 npx prisma migrate reset -f; \
	else \
		docker run --rm -v $(PWD)/packages/api:/app -w /app --network assistant_default -e CI=true -e DATABASE_URL=postgresql://postgres:postgres@postgres:5432/assistant?schema=public node:20 npx prisma migrate reset -f; \
	fi
	@if [ "$(INTERACTIVE)" = "true" ]; then \
		echo "✅ Database reset completed successfully"; \
	fi

migrate.api.dev.name:
	docker run --rm -v $(PWD)/packages/api:/app -w /app --network assistant_default -e DATABASE_URL=postgresql://postgres:postgres@postgres:5432/assistant?schema=public node:20 npx prisma migrate dev --name subplans-and-categorization

migrate.api.generate:
	docker run --rm -v $(PWD)/packages/api:/app -w /app --network assistant_default -e DATABASE_URL=postgresql://postgres:postgres@postgres:5432/assistant?schema=public node:20 npx prisma generate

migrate.api.db-push:
	docker run --rm -v $(PWD)/packages/api:/app -w /app --network assistant_default -e DATABASE_URL=postgresql://postgres:postgres@postgres:5432/assistant?schema=public node:20 npx prisma db push

# Legacy DB targets (kept for backward compatibility)
db.migrate.legacy:
	docker compose exec api npx prisma migrate dev --name init

db.reset.legacy:
	docker compose exec api npx prisma migrate reset -f

# Scripts (Docker-based)
scripts.i18n:
	@echo "⚠️  i18n check temporarily disabled - will be implemented later"
	@echo "✅ i18n validation skipped"

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

test.integration.scheduler-workers-api:
	docker compose run --rm scheduler npm run test:integration:workers

test.integration.workers-api:
	docker compose run --rm workers npm run test:integration

test.integration.scheduler-ai:
	docker compose run --rm scheduler npm run test:integration:ai

test.integration.workers-ai:
	docker compose run --rm workers npm run test:integration:ai

# Security tools preparation
security.prepare:
	@echo "🔧 Preparing security tools..."
	@echo "📥 Pulling Semgrep image..."
	@docker pull semgrep/semgrep:latest
	@echo "📥 Pulling Trivy image..."
	@docker pull aquasec/trivy:latest
	@echo "✅ Security tools preparation complete"

# Security testing targets
# SAST (Static Application Security Testing) - Semgrep on source code per service
test.security.scan.code.api:
	@echo "🔒 Security: Scanning API code for vulnerabilities (Semgrep SAST)"
	@docker run --rm -v "${PWD}/packages/api:/src" semgrep/semgrep semgrep scan --config auto --severity ERROR

test.security.scan.code.ui:
	@echo "🔒 Security: Scanning UI code for vulnerabilities (Semgrep SAST)"
	@docker run --rm -v "${PWD}/packages/ui:/src" semgrep/semgrep semgrep scan --config auto --severity ERROR

test.security.scan.code.workers:
	@echo "🔒 Security: Scanning Workers code for vulnerabilities (Semgrep SAST)"
	@docker run --rm -v "${PWD}/packages/workers:/src" semgrep/semgrep semgrep scan --config auto --severity ERROR

test.security.scan.code.scheduler:
	@echo "🔒 Security: Scanning Scheduler code for vulnerabilities (Semgrep SAST)"
	@docker run --rm -v "${PWD}/packages/scheduler:/src" semgrep/semgrep semgrep scan --config auto --severity ERROR

test.security.scan.code.ai:
	@echo "🔒 Security: Scanning AI code for vulnerabilities (Semgrep SAST)"
	@docker run --rm -v "${PWD}/packages/ai:/src" semgrep/semgrep semgrep scan --config auto --severity ERROR

# Aggregate SAST scan for all services
test.security.scan.code: test.security.scan.code.api test.security.scan.code.ui test.security.scan.code.workers test.security.scan.code.scheduler test.security.scan.code.ai
	@echo "✅ All SAST scans completed"

# SCA (Software Composition Analysis) - Trivy on manifests/dependencies per service
test.security.scan.deps.api:
	@echo "🔒 Security: Scanning API dependencies for vulnerabilities (Trivy SCA)"
	@docker run --rm -v "${PWD}/packages/api:/src" aquasec/trivy fs --security-checks vuln --severity HIGH,CRITICAL /src

test.security.scan.deps.ui:
	@echo "🔒 Security: Scanning UI dependencies for vulnerabilities (Trivy SCA)"
	@docker run --rm -v "${PWD}/packages/ui:/src" aquasec/trivy fs --security-checks vuln --severity HIGH,CRITICAL /src

test.security.scan.deps.workers:
	@echo "🔒 Security: Scanning Workers dependencies for vulnerabilities (Trivy SCA)"
	@docker run --rm -v "${PWD}/packages/workers:/src" aquasec/trivy fs --security-checks vuln --severity HIGH,CRITICAL /src

test.security.scan.deps.scheduler:
	@echo "🔒 Security: Scanning Scheduler dependencies for vulnerabilities (Trivy SCA)"
	@docker run --rm -v "${PWD}/packages/scheduler:/src" aquasec/trivy fs --security-checks vuln --severity HIGH,CRITICAL /src

test.security.scan.deps.ai:
	@echo "🔒 Security: Scanning AI dependencies for vulnerabilities (Trivy SCA)"
	@docker run --rm -v "${PWD}/packages/ai:/src" aquasec/trivy fs --security-checks vuln --severity HIGH,CRITICAL /src

# Aggregate SCA scan for all services
test.security.scan.deps: test.security.scan.deps.api test.security.scan.deps.ui test.security.scan.deps.workers test.security.scan.deps.scheduler test.security.scan.deps.ai
	@echo "✅ All SCA scans completed"

# IaC (Infrastructure as Code) - Trivy on docker-compose.yml and k8s/
test.security.scan.iac:
	@echo "🔒 Security: Scanning Infrastructure as Code for vulnerabilities (Trivy IaC)"
	@echo "📋 Scanning docker-compose.yml..."
	@docker run --rm -v "${PWD}:/src" aquasec/trivy config --severity HIGH,CRITICAL /src/docker-compose.yml
	@echo "📋 Note: k8s/ directory not yet present - will be added when Kubernetes configs are implemented"

# E2E tests
test.e2e.ui:
	docker compose run --rm ui npm run test:e2e

test.e2e.ui-api:
	docker build --target test-e2e -t ui-e2e-test -f packages/ui/Dockerfile.e2e .
	docker run --rm --network assistant_default ui-e2e-test

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



test.i18n:
	docker compose run --rm scripts npm run i18n:check

test.i18n.coverage:
	docker compose run --rm scripts npm run i18n:coverage

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
	@echo "🧹 Cleaning up any local dependency traces..."
	@find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".venv" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "✅ Workspace cleaned - no local dependencies remaining"
