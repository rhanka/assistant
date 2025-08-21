FROM node:24-alpine3.22 AS base
WORKDIR /app
# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs
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

# Security: Change ownership to non-root user
RUN chown -R nodejs:nodejs /app

# Build stage (production only)
FROM base AS build
# Exclude test files from build
RUN find src -name "*.test.ts" -delete && \
    find src -name "*.spec.ts" -delete
RUN npm run build

# Test stage
FROM base AS test
# Tests can run here with all dependencies available
USER nodejs
CMD ["npm", "run", "test:unit"]

# Production stage
FROM nginx:alpine AS production
# Security: Use existing nginx user (already non-root)
# Copy built application
COPY --from=build /app/build /usr/share/nginx/html
# Copy nginx configuration
COPY packages/ui/nginx.conf /etc/nginx/nginx.conf
# Security: Change ownership to nginx user and set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    chmod -R 755 /usr/share/nginx/html && \
    chmod -R 755 /var/cache/nginx && \
    chmod -R 755 /var/log/nginx && \
    chmod -R 644 /etc/nginx/nginx.conf && \
    chmod -R 644 /etc/nginx/conf.d/* && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid
# Security: Switch to nginx user (already non-root)
USER nginx
# Expose port
EXPOSE 80
# Start nginx
CMD ["nginx", "-g", "daemon off;"]

# Development stage
FROM base AS dev
# Development mode with hot reload
USER nodejs
CMD ["npm", "run", "dev"]
