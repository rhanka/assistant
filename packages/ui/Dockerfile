FROM node:24-alpine3.22 AS base
WORKDIR /app
COPY packages/ui/package.json packages/ui/package-lock.json packages/ui/tsconfig.json ./
COPY packages/config/tsconfig.base.json ./

# Install all dependencies (including devDependencies for testing)
RUN npm ci --legacy-peer-deps
# Security: Audit dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high

# Copy source code (SvelteKit needs the full src directory)
COPY packages/ui/src ./src
COPY packages/ui/tests ./tests
COPY packages/ui/svelte.config.js packages/ui/vite.config.ts ./

# Build stage (production only)
FROM base AS build
# Exclude test files from build
RUN find src -name "*.test.ts" -delete && \
    find src -name "*.spec.ts" -delete
RUN npm run build

# Test stage
FROM base AS test
# Tests can run here with all dependencies available
CMD ["npm", "run", "test:unit"]

# Production stage
FROM nginx:alpine AS production
# Copy built application
COPY --from=build /app/build /usr/share/nginx/html
# Copy nginx configuration
COPY packages/ui/nginx.conf /etc/nginx/nginx.conf
# Expose port
EXPOSE 80
# Start nginx
CMD ["nginx", "-g", "daemon off;"]

# Development stage
FROM base AS dev
# Development mode with hot reload
CMD ["npm", "run", "dev"]
