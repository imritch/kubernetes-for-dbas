# Module 7: Helm - The Kubernetes Package Manager

## Overview
Learn Helm, the package manager for Kubernetes, to simplify deployment and management of complex applications.

**Duration:** 60 minutes

## Learning Objectives
- Understand Helm charts and repositories
- Install applications using Helm
- Create custom Helm charts
- Manage releases and rollbacks
- Use Helm for database deployments
- Understand chart templating with values

## Core Concepts

### What is Helm?
Helm is the package manager for Kubernetes (like apt, yum, or chocolatey).

**DBA Analogy:** Like SQL Server install scripts or SSDT projects - templated, reusable deployment packages.

**Benefits:**
- Package complex applications
- Version and release management
- Easy rollback
- Templating and customization
- Share and reuse configurations

### Helm Components
- **Chart**: Package of Kubernetes manifests
- **Repository**: Collection of charts
- **Release**: Installed instance of a chart
- **Values**: Configuration parameters

## Hands-On Exercises

### Exercise 1: Install Application with Helm
```bash
# Add repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repo index
helm repo update

# Search for charts
helm search repo postgres

# Install PostgreSQL
helm install my-postgres bitnami/postgresql

# Get release status
helm status my-postgres

# List releases
helm list
```

### Exercise 2: Customize with Values
```bash
# View default values
helm show values bitnami/postgresql > postgres-values.yaml

# Edit values (change password, resources, etc.)
# Install with custom values
helm install my-postgres bitnami/postgresql -f postgres-values.yaml

# Or override specific values
helm install my-postgres bitnami/postgresql \
  --set auth.postgresPassword=mypassword \
  --set primary.resources.requests.memory=512Mi
```

### Exercise 3: Upgrade and Rollback
```bash
# Upgrade release
helm upgrade my-postgres bitnami/postgresql -f new-values.yaml

# View revision history
helm history my-postgres

# Rollback to previous revision
helm rollback my-postgres

# Rollback to specific revision
helm rollback my-postgres 1
```

### Exercise 4: Create Your First Chart
```bash
# Create chart skeleton
helm create my-app

# Explore chart structure
cd my-app
tree .
# Chart.yaml - metadata
# values.yaml - default values
# templates/ - Kubernetes manifests

# Validate chart
helm lint .

# Dry-run (see generated manifests)
helm install my-app . --dry-run --debug

# Install
helm install my-app .
```

### Exercise 5: Template a Database Chart
```bash
# Create PostgreSQL chart
helm create postgres-chart

# Customize templates
# - StatefulSet
# - Service
# - PVC
# - Secret
# - ConfigMap

# Install with different values
helm install dev-db ./postgres-chart -f values-dev.yaml
helm install prod-db ./postgres-chart -f values-prod.yaml
```

### Exercise 6: Helm Templating Functions
```bash
# values.yaml
database:
  name: salesdb
  port: 5432

# In template:
{{ .Values.database.name }}
{{ .Values.database.port }}

# Conditionals
{{- if .Values.replication.enabled }}
replicas: {{ .Values.replication.replicas }}
{{- end }}

# Loops
{{- range .Values.databases }}
- name: {{ . }}
{{- end }}
```

### Exercise 7: Install Complex Applications
```bash
# Install Prometheus monitoring stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack

# Install Grafana
helm install grafana bitnami/grafana

# Install Redis
helm install redis bitnami/redis
```

### Exercise 8: Package and Share Charts
```bash
# Package chart
helm package my-app

# Creates: my-app-0.1.0.tgz

# Install from package
helm install my-app ./my-app-0.1.0.tgz

# Create chart repository (GitHub Pages, S3, etc.)
helm repo index .
```

## Practice Challenges

1. **Challenge 1:** Install PostgreSQL using Helm with 10Gi storage and custom password
2. **Challenge 2:** Create a Helm chart for SQL Server deployment
3. **Challenge 3:** Create a multi-tier app chart (frontend + backend + database)
4. **Challenge 4:** Install Prometheus and Grafana using Helm

**Solutions in `exercises/solutions.md`**

## Key Chart Examples (to be created)

- `postgres-chart/` - PostgreSQL Helm chart
- `sqlserver-chart/` - SQL Server Helm chart
- `webapp-chart/` - Full stack application chart
- `values-dev.yaml` - Development values
- `values-prod.yaml` - Production values

## Key Takeaways

✅ Helm simplifies complex deployments
✅ Charts are reusable and shareable
✅ Values files enable environment-specific configuration
✅ Easy upgrade and rollback
✅ Rich ecosystem of community charts
✅ Templating allows customization

## Common Helm Commands

```bash
# Repository management
helm repo add <name> <url>
helm repo update
helm search repo <keyword>

# Release management
helm install <name> <chart>
helm install <name> <chart> -f values.yaml
helm upgrade <name> <chart>
helm rollback <name> <revision>
helm uninstall <name>
helm list

# Chart development
helm create <name>
helm lint <chart>
helm template <name> <chart>
helm package <chart>
helm install <name> <chart> --dry-run --debug

# Inspection
helm show values <chart>
helm show chart <chart>
helm get values <release>
helm get manifest <release>
helm history <release>
```

## DBA Patterns

### Pattern: Multi-Environment Databases
```yaml
# values-dev.yaml
resources:
  requests:
    memory: 512Mi
  limits:
    memory: 1Gi
replicas: 1
storage: 10Gi

# values-prod.yaml
resources:
  requests:
    memory: 4Gi
  limits:
    memory: 4Gi
replicas: 3
storage: 100Gi
```

### Pattern: Database Migration Job
```yaml
# Include in chart:
# - StatefulSet (database)
# - Job (schema migration)
# - ConfigMap (migration scripts)
```

## Popular Helm Charts for DBAs

- **bitnami/postgresql** - Production-ready PostgreSQL
- **bitnami/mysql** - MySQL/MariaDB
- **bitnami/mongodb** - MongoDB
- **bitnami/redis** - Redis cache
- **prometheus-community/kube-prometheus-stack** - Monitoring
- **elastic/elasticsearch** - Elasticsearch

## Next Steps
**Continue to:** [Module 8: Monitoring and Observability](../module-08-monitoring/README.md)

---
*Note: This is a simplified outline. Full tutorial content will be expanded when you're ready to work on this module.*
