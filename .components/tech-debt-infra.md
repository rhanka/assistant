# Infrastructure Technical Debt

Note: Alpine preferred to Debian to reduce libc vulnerabilities

## Container & Orchestration
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| docker | 24.0.0 | 25.0.0 | no | unknown | 1m | Major version - check compatibility |
| docker-compose | 2.20.0 | 2.24.0 | no | no | 1w | Minor version updates |

## Database Services & OS
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| postgres | 17.6 | 17.6 | no | no | none | ✅ Updated to latest stable with Alpine 3.22 |
| postgres-os | alpine:3.22 | alpine:3.22 | no | no | none | ✅ Migrated to Alpine to reduce vuln scope |
| redis | 8.2 | 8.2 | no | no | none | ✅ Updated to latest stable with Alpine 3.22 |
| redis-os | alpine:3.22 | alpine:3.22 | no | no | none | ✅ Migrated to Alpine to reduce vuln scope |

## CI/CD & Tooling
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| github-actions | latest | latest | no | no | none | Auto-updated by GitHub |
| make | 4.3 | 4.4 | no | no | 1m | Minor version update |
| docker-compose | 2.20.0 | 2.24.0 | no | no | 1w | Minor version updates |

## To Be Implemented (Future Infrastructure)
| Component | Status | Priority | Notes |
|-----------|--------|----------|-------|
| kubernetes | planned | 1y | When migrating from Docker Compose to K8s |
| scaleway-k8s | planned | 1y | Production Kubernetes cluster |
| scaleway-db | planned | 1y | Managed PostgreSQL service |
| scaleway-redis | planned | 1y | Managed Redis service |
| scaleway-object | planned | 1y | Object storage for artifacts |
| monitoring | planned | 1y | Prometheus + Grafana stack |
| logging | planned | 1y | Centralized logging solution |

---

**Priority Levels**: 1d (critical), 1w (high), 1m (medium), 1y (low/deprecated)  
**EOL**: End of Life - version no longer supported

## ⚠️ Breaking Changes Identified
- **Docker**: 24.0.0 → 25.0.0 (Major version - check compatibility)
- **PostgreSQL**: 15 → 16 (Major version - test compatibility)

## 🔒 Security Considerations
- **Debian-based images**: PostgreSQL (debian:13) and Redis (debian:12) use Debian as base OS
- **Vulnerability monitoring**: These images require regular security updates due to Debian's larger attack surface
- **Alternative consideration**: Evaluate Alpine-based alternatives for PostgreSQL and Redis when possible
- **Current mitigation**: Regular security scans with `make test.security.container-infra`

## 🔍 Breaking Change Assessment Required
Before updating these components:
1. **Docker 25.x**: Check for breaking changes in build commands and API
2. **PostgreSQL 16**: Review migration guide for schema and query changes
3. **Test thoroughly**: Run all integration tests after major version updates
4. **Update incrementally**: Consider updating one major component at a time

**Last Security Audit**: `make test.security.iac-infra` + `make test.security.container-infra` (automatic)  
**Last Version Audit**: 2024-12-19 (manual) - Updated with Alpine 3.22 & DB upgrades  
**Next Version Audit**: 2024-12-26 (manual)

## Audit Commands
```bash
# Infrastructure-specific component audit
make audit.components.infra

# Infrastructure security audit
make test.security.iac-infra
make test.security.container-infra

# Base image audit
make audit.docker.base-images
make audit.docker.os
make audit.docker.runtimes
make audit.docker.db-os
```
