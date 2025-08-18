FROM node:20 AS base
WORKDIR /app
COPY packages/ui/package.json packages/ui/package-lock.json ./
COPY packages/config/tsconfig.base.json ./

# Install all dependencies (including devDependencies for testing)
RUN npm install --legacy-peer-deps
# Security: Audit dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high

# Copy source code and configs
COPY packages/ui/src ./src
COPY packages/ui/svelte.config.js packages/ui/vite.config.ts packages/ui/tsconfig.json ./

# Build stage - generate static assets
FROM base AS build
# Exclude test files from build
RUN find src -name "*.test.ts" -delete && \
    find src -name "*.spec.ts" -delete
# Build the SvelteKit application
RUN npm run build

# Test stage - run unit tests
FROM base AS test
# Tests can run here with all dependencies available
CMD ["npm", "run", "test:unit"]

# Production stage - nginx serving static assets
FROM nginx:alpine AS production
# Security: Update nginx to latest patch
RUN apk update && apk upgrade

# Copy built static assets from build stage (SvelteKit 2 uses build/ directory)
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom nginx config
COPY packages/ui/nginx.conf /etc/nginx/nginx.conf

# Expose port 80 for HTTP
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

# Default target (for docker-compose compatibility)
FROM base AS default
EXPOSE 5173
CMD ["npm", "run", "dev"]
