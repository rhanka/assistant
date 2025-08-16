.PHONY: dev up down ui api workers ai db.init db.migrate db.reset scripts.i18n check

# Docker compose (db/cache + optional services)
up:
	docker compose up -d postgres redis

down:
	docker compose down

dev:
	docker compose up -d
	npm install

# Services
ui:
	cd packages/ui && npm run dev

api:
	cd packages/api && npm run dev

workers:
	cd packages/workers && npm run dev

ai:
	cd packages/ai && poetry run uvicorn app.main:app --reload --port $${AI_PORT:-8000}

# DB (Prisma via API package)
db.init:
	cd packages/api && npx prisma generate

db.migrate:
	cd packages/api && npx prisma migrate dev --name init

db.reset:
	cd packages/api && npx prisma migrate reset -f

# Scripts
scripts.i18n:
	cd packages/scripts && npm run i18n:check

check: scripts.i18n
