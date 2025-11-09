# Module 4: ConfigMaps and Secrets

## Overview
Learn how to externalize configuration and manage sensitive data securely in Kubernetes.

**Duration:** 45 minutes

## Learning Objectives
- Externalize application configuration with ConfigMaps
- Manage sensitive data with Secrets
- Inject configuration as environment variables
- Mount configuration as files
- Update configuration without rebuilding images

## Core Concepts

### ConfigMaps
Store non-sensitive configuration data as key-value pairs.

**DBA Analogy:** Like SQL Server configuration files (sql.ini, DSN) or database properties - separate configuration from code.

**Use Cases:**
- Application settings
- Database connection strings (non-sensitive parts)
- Feature flags
- Configuration files

### Secrets
Store sensitive information (passwords, tokens, keys).

**DBA Analogy:** Like SQL Server credentials, encryption keys, or certificates stored securely.

**Types:**
- **Opaque**: Generic key-value pairs (default)
- **kubernetes.io/tls**: TLS certificates
- **kubernetes.io/basic-auth**: Basic authentication
- **kubernetes.io/ssh-auth**: SSH credentials

## Hands-On Exercises

### Exercise 1: Create and Use ConfigMap
```bash
# Create ConfigMap from literal values
kubectl create configmap app-config \
  --from-literal=database.host=postgres-service \
  --from-literal=database.port=5432

# Create from file
kubectl create configmap nginx-config --from-file=nginx.conf

# Use in pod as env vars
kubectl apply -f manifests/01-configmap-env.yaml
```

### Exercise 2: ConfigMap as Volume Mount
```bash
# Mount entire ConfigMap as files
kubectl apply -f manifests/02-configmap-volume.yaml

# Exec into pod and verify
kubectl exec -it <pod> -- cat /config/database.host
```

### Exercise 3: Create and Use Secrets
```bash
# Create Secret
kubectl create secret generic db-credentials \
  --from-literal=username=postgres \
  --from-literal=password=mysecretpassword

# View Secret (base64 encoded)
kubectl get secret db-credentials -o yaml

# Use in pod
kubectl apply -f manifests/03-secret-env.yaml
```

### Exercise 4: PostgreSQL with Secrets
```bash
# Deploy PostgreSQL using Secrets for credentials
kubectl apply -f manifests/04-postgres-with-secrets.yaml

# Verify connection
kubectl exec -it deployment/postgres -- psql -U postgres -c "SELECT 1"
```

### Exercise 5: TLS Secrets
```bash
# Create TLS secret
kubectl create secret tls my-tls-secret \
  --cert=path/to/cert.crt \
  --key=path/to/key.key

# Use in Ingress
kubectl apply -f manifests/05-ingress-tls.yaml
```

### Exercise 6: Update ConfigMap (Hot Reload)
```bash
# Update ConfigMap
kubectl edit configmap app-config

# Watch pods pick up changes (if app supports hot reload)
# Or restart deployment to pick up changes
kubectl rollout restart deployment/my-app
```

## Practice Challenges

1. **Challenge 1:** Create a ConfigMap for PostgreSQL configuration (max_connections, shared_buffers)
2. **Challenge 2:** Create a Secret for database credentials and use it in a PostgreSQL deployment
3. **Challenge 3:** Create a multi-tier app where backend gets database credentials from Secrets
4. **Challenge 4:** Mount application.properties as a file using ConfigMap

**Solutions in `exercises/solutions.md`**

## Key Manifest Files (to be created)

- `01-configmap-env.yaml` - ConfigMap as environment variables
- `02-configmap-volume.yaml` - ConfigMap as volume mount
- `03-secret-env.yaml` - Secret as environment variables
- `04-postgres-with-secrets.yaml` - Production pattern
- `05-ingress-tls.yaml` - TLS certificates

## Key Takeaways

✅ Never hardcode configuration in containers
✅ Use ConfigMaps for non-sensitive data
✅ Use Secrets for sensitive data (passwords, tokens)
✅ Secrets are base64 encoded, not encrypted by default
✅ ConfigMaps and Secrets can be mounted as files or env vars
✅ Update ConfigMaps/Secrets without rebuilding images

## Security Best Practices

### DO:
- Use Secrets for passwords, tokens, keys
- Enable encryption at rest for Secrets
- Use RBAC to restrict Secret access
- Rotate credentials regularly
- Use external secret managers (Azure Key Vault, AWS Secrets Manager)

### DON'T:
- Store passwords in ConfigMaps
- Commit Secrets to Git
- Print Secret values in logs
- Use default service account tokens unnecessarily

## DBA Patterns

### Pattern: Database Connection String
```yaml
# ConfigMap: Non-sensitive parts
database.host: postgres-service
database.port: 5432
database.name: mydb

# Secret: Sensitive parts
username: postgres
password: <base64-encoded>
```

### Pattern: PostgreSQL Custom Configuration
```yaml
# ConfigMap: postgresql.conf overrides
max_connections: "200"
shared_buffers: "256MB"
effective_cache_size: "1GB"
```

## Next Steps
**Continue to:** [Module 5: Persistent Volumes and StatefulSets](../module-05-statefulsets-postgresql/README.md)

---
*Note: This is a simplified outline. Full tutorial content will be expanded when you're ready to work on this module.*
