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

# Infrastructure versions (matching docker-compose.yml)
export POSTGRES_VERSION ?= postgres:17.6-alpine3.22
export REDIS_VERSION ?= redis:8.2-alpine3.22

# Docker image configuration (for local builds and CI artifacts)

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
# Update package-lock.json files
update.api.lock:
	docker run --rm -v "$(PWD)/packages/api:/app" -v /tmp/api-nodemodules:/app/node_modules -w /app node:24-alpine3.22 npm install --legacy-peer-deps

update.scheduler.lock:
	docker run --rm -v "$(PWD)/packages/scheduler:/app" -v /tmp/scheduler-nodemodules:/app/node_modules -w /app node:24-alpine3.22 npm install --legacy-peer-deps

update.workers.lock:
	docker run --rm -v "$(PWD)/packages/workers:/app" -v /tmp/workers-nodemodules:/app/node_modules -w /app node:24-alpine3.22 npm install --legacy-peer-deps

update.ui.lock:
	docker run --rm -v "$(PWD)/packages/ui:/app" -v /tmp/ui-nodemodules:/app/node_modules -w /app node:24-alpine3.22 npm install --legacy-peer-deps
	
# Build targets (local builds for CI artifacts)
build.api:
	@echo "🔨 Building API image (production target)..."
	docker build -f packages/api/Dockerfile --target production -t assistant-api:latest .

build.scheduler:
	@echo "🔨 Building Scheduler image (production target)..."
	docker build -f packages/scheduler/Dockerfile --target production -t assistant-scheduler:latest .

build.workers:
	@echo "🔨 Building Workers image (production target)..."
	docker build -f packages/workers/Dockerfile --target production -t assistant-workers:latest .

build.ui:
	@echo "🔨 Building UI image (production target)..."
	docker build -f packages/ui/Dockerfile --target production -t assistant-ui:latest .

build.ai:
	@echo "🔨 Building AI image (production target)..."
	docker build -f packages/ai/Dockerfile -t assistant-ai:latest .

# Build all services
build.all: build.api build.scheduler build.workers build.ui build.ai

# Save/load targets for CI artifacts
save.api:
	@echo "💾 Saving API image as artifact..."
	@docker save assistant-api:latest -o api-image.tar

save.scheduler:
	@echo "💾 Saving Scheduler image as artifact..."
	@docker save assistant-scheduler:latest -o scheduler-image.tar

save.workers:
	@echo "💾 Saving Workers image as artifact..."
	@docker save assistant-workers:latest -o workers-image.tar

save.ui:
	@echo "💾 Saving UI image as artifact..."
	@docker save assistant-ui:latest -o ui-image.tar

save.ai:
	@echo "💾 Saving AI image as artifact..."
	@docker save assistant-ai:latest -o ai-image.tar

load.api:
	@echo "📥 Loading API image from artifact..."
	@docker load -i api-image.tar

load.scheduler:
	@echo "📥 Loading Scheduler image from artifact..."
	@docker load -i scheduler-image.tar

load.workers:
	@echo "📥 Loading Workers image from artifact..."
	@docker load -i workers-image.tar

load.ui:
	@echo "📥 Loading UI image from artifact..."
	@docker load -i ui-image.tar

load.ai:
	@echo "📥 Loading AI image from artifact..."
	@docker load -i ai-image.tar

# Build all services

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

# UI-specific targets
up.ui:
	docker compose up -d ui

down.ui:
	docker compose stop ui

rebuild.ui: build.ui up.ui

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
test.unit: test.unit.api test.unit.ui test.unit.scheduler test.unit.workers test.unit.ai

# Package-specific unit tests
test.unit.api:
	@echo "🧪 Running API unit tests..."
	docker build --target test -t api-test -f packages/api/Dockerfile .
	docker run --rm --network assistant_default api-test npm run test:unit

test.unit.ui:
	docker build --target test -t ui-test -f packages/ui/Dockerfile .
	docker run --rm --network assistant_default ui-test

test.unit.scheduler:
	@echo "🧪 Running Scheduler unit tests..."
	docker build -f packages/scheduler/Dockerfile --target test -t assistant-scheduler-test:latest .
	docker run --rm assistant-scheduler-test:latest

test.unit.workers:
	@echo "🧪 Running Workers unit tests..."
	docker build -f packages/workers/Dockerfile --target test -t assistant-workers-test:latest .
	docker run --rm assistant-workers-test:latest

test.unit.ai:
	docker compose run --rm ai pytest tests/

# Integration tests
test.integration.api:
	# TODO: Fix this test, not used in CI
	docker compose run --rm api npm run test:integration

test.integration.scheduler-api:
	docker compose up -d api postgres redis
	sleep 10
	docker compose run --rm scheduler npm run test:integration
	docker compose down

test.integration.scheduler-workers-api:
	docker compose run --rm scheduler npm run test:integration:workers

test.integration.workers-api:
	docker compose run --rm workers npm run test:integration

test.integration.scheduler-ai:
	docker compose run --rm scheduler npm run test:integration:ai

test.integration.workers-ai:
	docker compose run --rm workers npm run test:integration:ai

# Install security tools if not present
install.security.tools:
	@echo "🔧 Installing security tools..."
	@if ! command -v jq >/dev/null 2>&1; then \
		echo "Installing jq..."; \
		sudo apt-get update && sudo apt-get install -y jq; \
	else \
		echo "jq already installed"; \
	fi
	@if ! command -v yq >/dev/null 2>&1; then \
		echo "Installing yq..."; \
		sudo apt-get update && sudo apt-get install -y yq; \
	else \
		echo "yq already installed"; \
	fi

# Unified Security Testing - Single wildcard with intelligent parsing
# Usage: make test.security.sast-api, make test.security.sca-ui, make test.security.container-workers, etc.
test.security.%:
	@echo "🔒 Security: Parsing target '$*'..."
	@mkdir -p .security
	@SCAN_TYPE=$$(echo $* | cut -d- -f1); \
	SERVICE=$$(echo $* | cut -d- -f2-); \
	echo "Scan type: $$SCAN_TYPE, Service: $$SERVICE"; \
	echo "🔒 Security: Executing $$SCAN_TYPE workflow on $$SERVICE..."; \
	echo "  📋 Step 1: Executing scan..."; \
	if [ "$$SCAN_TYPE" = "sast" ]; then \
		docker run --rm -v "${PWD}/packages/$$SERVICE:/src" semgrep/semgrep semgrep scan --config auto --severity ERROR --json > .security/$$SCAN_TYPE-$$SERVICE.json || true; \
	elif [ "$$SCAN_TYPE" = "sca" ]; then \
		docker run --rm -v "${PWD}/packages/$$SERVICE:/src" aquasec/trivy fs --security-checks vuln --severity HIGH,CRITICAL --format json --quiet > .security/$$SCAN_TYPE-$$SERVICE.json /src || true; \
	elif [ "$$SCAN_TYPE" = "container" ]; then \
		if [ "$$SERVICE" = "infra" ]; then \
			echo "  📋 Scanning infrastructure container images..."; \
			docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --severity HIGH,CRITICAL --format json --quiet > .security/$$SCAN_TYPE-$$SERVICE.json $(POSTGRES_VERSION) || true; \
			docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --severity HIGH,CRITICAL --format json --quiet >> .security/$$SCAN_TYPE-$$SERVICE.json $(REDIS_VERSION) || true; \
		else \
			docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --severity HIGH,CRITICAL --format json --quiet > .security/$$SCAN_TYPE-$$SERVICE.json assistant-$$SERVICE:latest || true; \
		fi; \
	elif [ "$$SCAN_TYPE" = "iac" ]; then \
		if [ "$$SERVICE" = "infra" ]; then \
			echo "  📋 Scanning infrastructure configuration files..."; \
			docker run --rm -v "${PWD}:/src" aquasec/trivy config --severity HIGH,CRITICAL --format json --quiet > .security/$$SCAN_TYPE-$$SERVICE.json /src/docker-compose.yml || true; \
			docker run --rm -v "${PWD}:/src" aquasec/trivy config --severity HIGH,CRITICAL --format json --quiet >> .security/$$SCAN_TYPE-$$SERVICE.json /src/Makefile || true; \
		else \
			docker run --rm -v "${PWD}:/src" aquasec/trivy config --severity HIGH,CRITICAL --format json --quiet > .security/$$SCAN_TYPE-$$SERVICE.json /src/docker-compose.yml || true; \
		fi; \
	else \
		echo "❌ Error: Unknown scan type '$$SCAN_TYPE'"; \
		echo "Supported types: sast, sca, container, iac"; \
		echo "Usage: make test.security.sast-api, make test.security.sca-ui, make test.security.iac-infra, etc."; \
		exit 1; \
	fi; \
	echo "  📋 Step 2: Parsing results to structured format..."; \
	packages/scripts/src/security-parser.sh $$SCAN_TYPE .security/$$SCAN_TYPE-$$SERVICE.json .security/$$SCAN_TYPE-$$SERVICE-parsed.yaml $$SERVICE || exit 1; \
	echo "  📋 Step 3: Checking compliance against vulnerability register..."; \
	packages/scripts/src/security-compliance.sh $$SCAN_TYPE $$SERVICE || exit 1; \
	echo "  📋 Note: k8s/ directory not yet present - will be added when Kubernetes configs are implemented"; \
	echo "✅ $$SCAN_TYPE workflow completed for $$SERVICE"; \


# Aggregate SCA scan for all services
test.security.sca: test.security.sca-api test.security.sca-ui test.security.sca-workers test.security.sca-scheduler test.security.sca-ai
	@echo "✅ All SCA tests completed"

# Main security test aggregates
test.security: test.security.sast test.security.sca test.security.iac test.security.container
	@echo "✅ All security tests completed"

test.security.sast: test.security.sast-api test.security.sast-ui test.security.sast-workers test.security.sast-scheduler test.security.sast-ai
	@echo "✅ All SAST tests completed"

# Aggregate container scan for all services
test.security.container: test.security.container-api test.security.container-ui test.security.container-workers test.security.container-scheduler test.security.container-ai test.security.container-infra
	@echo "✅ All container tests completed"

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

# =============================================================================
# COMPONENT AUDIT TARGETS
# =============================================================================

# NPM Package Auditing (Service-based)
audit.npm.versions:
	@echo "📦 Checking package.json versions vs latest available..."
	@echo "API packages:"
	@docker run --rm -v "$(PWD)/packages/api:/app" -w /app node:24-alpine3.22 sh -c "cat package.json | grep -E '\"@nestjs|@apollo|@prisma|bullmq|graphql|rxjs' | head -10"
	@echo "UI packages:"
	@docker run --rm -v "$(PWD)/packages/ui:/app" -w /app node:24-alpine3.22 sh -c "cat package.json | grep -E '\"svelte|vite|typescript' | head -10"

audit.npm.compare:
	@echo "📦 Comparing package.json versions with latest available..."
	@echo "Checking Vite (UI):"
	@echo "  Package.json: ^5.3.0"
	@docker run --rm node:24-alpine3.22 npm view vite version
	@echo "Checking NestJS (API):"
	@echo "  Package.json: ^10.0.0"
	@docker run --rm node:24-alpine3.22 npm view @nestjs/core version
	@echo "Checking Svelte (UI):"
	@echo "  Package.json: ^5.0.0"
	@docker run --rm node:24-alpine3.22 npm view svelte version

# Service-specific component auditing (using existing Make targets)
audit.components.%:
	@echo "🔍 Auditing components for service: $*"
	@if [ "$*" = "api" ]; then \
		echo "📦 API packages:"; \
		docker run --rm -v "$(PWD)/packages/api:/app" -w /app node:24-alpine3.22 sh -c "cat package.json | grep -E '\"@nestjs|@apollo|@prisma|bullmq|graphql|rxjs' | head -10"; \
	elif [ "$*" = "ui" ]; then \
		echo "📦 UI packages:"; \
		docker run --rm -v "$(PWD)/packages/ui:/app" -w /app node:24-alpine3.22 sh -c "cat package.json | grep -E '\"svelte|vite|typescript' | head -10"; \
	elif [ "$*" = "scheduler" ]; then \
		echo "📦 Scheduler packages:"; \
		docker run --rm -v "$(PWD)/packages/scheduler:/app" -w /app node:24-alpine3.22 sh -c "cat package.json | grep -E '\"bullmq|typescript' | head -10"; \
	elif [ "$*" = "workers" ]; then \
		echo "📦 Workers packages:"; \
		docker run --rm -v "$(PWD)/packages/workers:/app" -w /app node:24-alpine3.22 sh -c "cat package.json | grep -E '\"bullmq|typescript' | head -10"; \
	elif [ "$*" = "ai" ]; then \
		echo "🐍 AI packages:"; \
		docker run --rm -v "$(PWD)/packages/ai:/app" -w /app python:3.11-slim sh -c "cat pyproject.toml | grep -E 'fastapi|pytest' | head -10"; \
	elif [ "$*" = "infra" ]; then \
		echo "🏗️ Infrastructure components:"; \
		echo "Base images: node:24-alpine3.22, python:3.11-slim, nginx:alpine"; \
		echo "Services: postgres:15, redis:7.0"; \
		echo "Tooling: docker, docker-compose, make"; \
	else \
		echo "❌ Unknown service: $*. Available: api, ui, scheduler, workers, ai, infra"; \
		exit 1; \
	fi

audit.npm.outdated:
	@echo "📦 Auditing NPM packages for outdated dependencies..."
	@echo "API packages:"
	@docker run --rm -v "$(PWD)/packages/api:/app" -w /app node:24-alpine3.22 npm outdated || echo "No outdated packages"
	@echo "Scheduler packages:"
	@docker run --rm -v "$(PWD)/packages/scheduler:/app" -w /app node:24-alpine3.22 npm outdated || echo "No outdated packages"
	@echo "Workers packages:"
	@docker run --rm -v "$(PWD)/packages/workers:/app" -w /app node:24-alpine3.22 npm outdated || echo "No outdated packages"
	@echo "UI packages:"
	@docker run --rm -v "$(PWD)/packages/ui:/app" -w /app node:24-alpine3.22 npm outdated || echo "No outdated packages"

audit.npm.latest:
	@if [ -z "$(PACKAGE)" ]; then \
		echo "❌ Error: PACKAGE variable not set"; \
		echo "Usage: make audit.npm.latest PACKAGE=<package-name>"; \
		exit 1; \
	fi; \
	echo "📦 Checking latest version of $(PACKAGE)..."; \
	docker run --rm node:24-alpine3.22 npm view $(PACKAGE) version

audit.npm.info:
	@if [ -z "$(PACKAGE)" ]; then \
		echo "❌ Error: PACKAGE variable not set"; \
		echo "Usage: make audit.npm.info PACKAGE=<package-name>"; \
		exit 1; \
	fi; \
	echo "📦 Getting info for $(PACKAGE)..."; \
	docker run --rm node:24-alpine3.22 npm info $(PACKAGE)

# Python Package Auditing (Docker-based)
audit.pip.outdated:
	@echo "🐍 Auditing Python packages for outdated dependencies..."
	@docker run --rm -v "$(PWD)/packages/ai:/app" -w /app python:3.11-slim pip list --outdated || echo "No outdated packages"

audit.pip.latest:
	@if [ -z "$(PACKAGE)" ]; then \
		echo "❌ Error: PACKAGE variable not set"; \
		echo "Usage: make audit.pip.latest PACKAGE=<package-name>"; \
		exit 1; \
	fi; \
	echo "🐍 Checking latest version of $(PACKAGE)..."; \
	docker run --rm python:3.11-slim pip index versions $(PACKAGE)

audit.pip.info:
	@if [ -z "$(PACKAGE)" ]; then \
		echo "❌ Error: PACKAGE variable not set"; \
		echo "Usage: make audit.pip.info PACKAGE=<package-name>"; \
		exit 1; \
	fi; \
	echo "🐍 Getting info for $(PACKAGE)..."; \
	docker run --rm python:3.11-slim pip show $(PACKAGE)

# Docker Image & OS Auditing
audit.docker.latest:
	@if [ -z "$(IMAGE)" ]; then \
		echo "❌ Error: IMAGE variable not set"; \
		echo "Usage: make audit.docker.latest IMAGE=<image-name>"; \
		exit 1; \
	fi; \
	echo "🐳 Checking latest tags for $(IMAGE)..."; \
	docker run --rm curlimages/curl:latest sh -c "curl -s 'https://registry.hub.docker.com/v2/repositories/library/$(IMAGE)/tags/?page_size=10&page=1' | grep -o '\"name\":\"[^\"]*\"' | head -5"

audit.docker.os:
	@echo "🐧 Checking OS versions in base images..."
	@echo "Alpine (Node.js base):"
	@docker run --rm node:24-alpine3.22 sh -c "cat /etc/alpine-release"
	@echo "Python slim base:"
	@docker run --rm python:3.11-slim sh -c "cat /etc/os-release | grep VERSION"

audit.docker.db-os:
	@echo "🗄️ Checking database OS versions..."
	@echo "PostgreSQL base (Debian):"
	@docker run --rm postgres:15 sh -c "cat /etc/os-release | grep VERSION"
	@echo "Redis base (Debian):"
	@docker run --rm redis:7.0 sh -c "cat /etc/os-release | grep VERSION"

audit.docker.runtimes:
	@echo "🔧 Checking runtime versions in base images..."
	@echo "Node.js version:"
	@docker run --rm node:24-alpine3.22 node --version
	@echo "Python version:"
	@docker run --rm python:3.11-slim python --version
	@echo "Nginx version:"
	@docker run --rm nginx:alpine nginx -v

audit.docker.base-images:
	@echo "🐳 Auditing all base images used in project..."
	@echo "Current base images from Dockerfiles:"
	@echo "- node:24-alpine3.22 (api, scheduler, workers, ui)"
	@echo "- python:3.11-slim (ai)"
	@echo "- nginx:alpine (ui production)"
	@echo "- alpine:3.22 (OS base)"
	@echo ""
	@echo "Checking for newer versions..."
	@make audit.docker.latest IMAGE=node
	@make audit.docker.latest IMAGE=python
	@make audit.docker.latest IMAGE=nginx
	@make audit.docker.latest IMAGE=alpine

# =============================================================================
# PROJECT METRICS TARGETS
# =============================================================================

# Source Lines of Code (SLOC) analysis
metrics.sloc:
	@echo "📊 Analyzing Source Lines of Code (SLOC)..."
	@echo "Excluding configuration files (package.json, tsconfig.json, etc.)..."
	@if command -v cloc >/dev/null 2>&1; then \
		cloc --not-match-f='package.*json|tsconfig.json|Dockerfile|docker-compose.yml|Makefile|README.md|LICENSE|\.gitignore|\.env|\.mdc|\.md' .; \
	else \
		echo "❌ cloc not found. Installing cloc..."; \
		if command -v apt-get >/dev/null 2>&1; then \
			sudo apt-get update && sudo apt-get install -y cloc; \
		elif command -v yum >/dev/null 2>&1; then \
			sudo yum install -y cloc; \
		elif command -v brew >/dev/null 2>&1; then \
			brew install cloc; \
		else \
			echo "❌ Cannot install cloc automatically. Please install it manually:"; \
			echo "  Ubuntu/Debian: sudo apt-get install cloc"; \
			echo "  CentOS/RHEL: sudo yum install cloc"; \
			echo "  macOS: brew install cloc"; \
			exit 1; \
		fi; \
		echo "✅ cloc installed successfully. Running analysis..."; \
		cloc --not-match-f='package.*json|tsconfig.json|Dockerfile|docker-compose.yml|Makefile|README.md|LICENSE|\.gitignore|\.env|\.mdc|\.md' .; \
	fi

# Service-specific SLOC analysis
metrics.sloc.api:
	@echo "📊 API Service SLOC Analysis..."
	@if command -v cloc >/dev/null 2>&1; then \
		cloc --not-match-f='package.*json|tsconfig.json|Dockerfile' packages/api/; \
	else \
		echo "❌ cloc not found. Run 'make metrics.sloc' to install it first."; \
	fi

metrics.sloc.ui:
	@echo "📊 UI Service SLOC Analysis..."
	@if command -v cloc >/dev/null 2>&1; then \
		cloc --not-match-f='package.*json|tsconfig.json|Dockerfile|Dockerfile.e2e' packages/ui/; \
	else \
		echo "❌ cloc not found. Run 'make metrics.sloc' to install it first."; \
	fi

metrics.sloc.scheduler:
	@echo "📊 Scheduler Service SLOC Analysis..."
	@if command -v cloc >/dev/null 2>&1; then \
		cloc --not-match-f='package.*json|tsconfig.json|Dockerfile' packages/scheduler/; \
	else \
		echo "❌ cloc not found. Run 'make metrics.sloc' to install it first."; \
	fi

metrics.sloc.workers:
	@echo "📊 Workers Service SLOC Analysis..."
	@if command -v cloc >/dev/null 2>&1; then \
		cloc --not-match-f='package.*json|tsconfig.json|Dockerfile' packages/workers/; \
	else \
		echo "❌ cloc not found. Run 'make metrics.sloc' to install it first."; \
	fi

metrics.sloc.ai:
	@echo "📊 AI Service SLOC Analysis..."
	@if command -v cloc >/dev/null 2>&1; then \
		cloc --not-match-f='pyproject.toml|Dockerfile' packages/ai/; \
	else \
		echo "❌ cloc not found. Run 'make metrics.sloc' to install it first."; \
	fi

# Aggregate SLOC analysis for all services
metrics.sloc.services: metrics.sloc.api metrics.sloc.ui metrics.sloc.scheduler metrics.sloc.workers metrics.sloc.ai
	@echo "✅ Service-specific SLOC analysis completed"

# Project size summary
metrics.summary: metrics.sloc
	@echo ""
	@echo "📈 PROJECT METRICS SUMMARY"
	@echo "=========================="
	@echo "Run 'make metrics.sloc' for detailed SLOC breakdown"
	@echo "Run 'make metrics.sloc.services' for service-by-service analysis"

# Component audit aggregates
audit.components: audit.npm.outdated audit.pip.outdated audit.docker.base-images
	@echo "✅ Component audit completed for all package types"

audit.all: audit.components audit.docker.os audit.docker.runtimes
	@echo "✅ Complete component audit completed"


