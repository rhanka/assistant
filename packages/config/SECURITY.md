# Docker Security Hardening

## Overview
This document describes the security improvements implemented across all Dockerfiles in the project to follow security best practices and reduce attack surface.

## Security Improvements Applied

### 1. Non-Root User Execution
- **All services now run as non-root users** instead of root
- **User IDs**: Consistent UID/GID 1001 across Node.js services
- **Service-specific users**: 
  - `nodejs` for Node.js applications (API, Workers, Scheduler, UI dev)
  - `nginx` for UI production (nginx-based)
  - `python` for AI service

### 2. User Creation Strategy
```dockerfile
# Node.js services
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

# Python service
RUN groupadd -r python && useradd -r -g python python

# Nginx service
RUN addgroup -g 1001 -S nginx && \
    adduser -S nginx -u 1001 -G nginx
```

### 3. File Permissions
- **Ownership**: All application files owned by non-root users
- **Permissions**: 
  - Directories: `755` (rwxr-xr-x)
  - Files: `644` (rw-r--r--)
  - Executables: `755` (rwxr-xr-x)

### 4. Security Layers Applied

#### API Service
- Non-root user in all stages (base, test, production)
- Proper permissions for Prisma client and schema
- Secure file ownership for source code and builds

#### Workers Service
- Non-root execution in all environments
- Secure permissions for job processing
- Consistent security across dev/test/prod

#### Scheduler Service
- Non-root user for plan compilation and job management
- Secure file access for DAG processing
- Protected execution environment

#### UI Service
- **Development**: Node.js non-root user
- **Production**: Nginx non-root user with proper nginx permissions
- Secure static file serving

#### AI Service
- Python non-root user execution
- Secure dependency management
- Protected API endpoint access

### 5. Security Benefits

#### Reduced Attack Surface
- **Container escape protection**: Non-root users cannot access host system
- **Privilege escalation prevention**: Limited capabilities within containers
- **File system isolation**: Proper ownership prevents unauthorized access

#### Compliance & Best Practices
- **OWASP Docker Security**: Follows container security guidelines
- **CIS Docker Benchmark**: Aligns with security hardening standards
- **Production readiness**: Enterprise-grade security posture

#### Runtime Security
- **Process isolation**: Services run with minimal required privileges
- **Resource access control**: Limited access to container resources
- **Audit trail**: Clear user attribution for all operations

## Implementation Details

### User ID Consistency
- **Node.js services**: UID 1001, GID 1001
- **Cross-service compatibility**: Consistent user mapping
- **Volume mounting**: Compatible with host user mapping

### Permission Strategy
```bash
# Directory permissions
chmod -R 755 /app          # Application directories
chmod -R 755 /app/dist     # Build outputs
chmod -R 755 /app/src      # Source code

# File permissions
chmod -R 644 /app/*.json   # Configuration files
chmod -R 644 /app/prisma   # Database schema
```

### Stage-Specific Security
- **Base stage**: User creation and basic setup
- **Build stage**: Secure compilation environment
- **Test stage**: Non-root test execution
- **Production stage**: Hardened runtime environment

## Verification

### Security Testing
```bash
# Run security tests for all services
make test.security.container-api
make test.security.container-workers
make test.security.container-scheduler
make test.security.container-ui
make test.security.container-ai
```

### Manual Verification
```bash
# Check user execution
docker exec <container> whoami
docker exec <container> id

# Verify file permissions
docker exec <container> ls -la /app
docker exec <container> ls -la /app/dist
```

### Compliance Check
```bash
# Validate security configuration
make check
```

## Maintenance

### Adding New Services
When adding new Docker services:
1. **Create non-root user** with consistent UID/GID
2. **Set proper file ownership** before switching user
3. **Apply appropriate permissions** for service requirements
4. **Test security posture** with security scanning tools

### Updating Existing Services
- **Preserve security hardening** during updates
- **Verify user permissions** after dependency changes
- **Maintain consistent security** across all stages

## References

- [OWASP Docker Security](https://owasp.org/www-project-docker-security/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker/)
- [Docker Security Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Container Security Fundamentals](https://kubernetes.io/docs/concepts/security/)
