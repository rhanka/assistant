FROM node:20 AS base
WORKDIR /app
COPY packages/ui/package.json packages/ui/package-lock.json ./
COPY packages/config/tsconfig.base.json ./

# Install all dependencies (including devDependencies for testing)
RUN npm ci --legacy-peer-deps
# Security: Audit dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high

# Copy source code
COPY packages/ui/src ./src
COPY packages/ui/svelte.config.js packages/ui/vite.config.ts packages/ui/tsconfig.json ./

# Test stage
FROM base AS test
# Tests can run here with all dependencies available
CMD ["npm", "run", "test:unit"]

# Production stage
FROM base AS production
# Security: Audit production dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high
EXPOSE 5173
CMD ["npm", "run", "dev"]
