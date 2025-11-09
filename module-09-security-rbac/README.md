# Module 9: Security and RBAC

## Overview
Implement security best practices and Role-Based Access Control (RBAC) in Kubernetes.

**Duration:** 60 minutes

## Learning Objectives
- Understand Kubernetes RBAC model
- Create and manage Service Accounts
- Implement Roles and RoleBindings
- Apply Network Policies
- Secure Secrets management
- Implement Pod Security Standards
- Apply least privilege principles

## Core Concepts

### RBAC (Role-Based Access Control)
Control who can access which resources in Kubernetes.

**DBA Analogy:** Like SQL Server logins, roles, and permissions - controlling database access.

**Components:**
- **ServiceAccount**: Identity for pods (like SQL Server logins)
- **Role**: Set of permissions within namespace (like database roles)
- **ClusterRole**: Set of permissions cluster-wide (like server roles)
- **RoleBinding**: Grants Role to users/ServiceAccounts
- **ClusterRoleBinding**: Grants ClusterRole cluster-wide

### Security Layers

1. **Authentication**: Who are you? (ServiceAccounts, certificates)
2. **Authorization**: What can you do? (RBAC)
3. **Admission Control**: Additional validation (Pod Security)
4. **Network Security**: Network Policies

## Hands-On Exercises

### Exercise 1: Create ServiceAccount
```bash
# Create ServiceAccount
kubectl create serviceaccount db-admin

# View ServiceAccount
kubectl get serviceaccount db-admin -o yaml

# ServiceAccounts automatically get a token
kubectl get secrets | grep db-admin
```

### Exercise 2: Create Role with Database Permissions
```bash
# Create Role that can manage databases
kubectl apply -f manifests/01-db-admin-role.yaml

# Role allows:
# - Get, list, watch StatefulSets
# - Get, list, watch Pods
# - Get, list, watch Services
# - Get, list, watch PVCs

# View role
kubectl describe role db-admin
```

### Exercise 3: Create RoleBinding
```bash
# Bind Role to ServiceAccount
kubectl apply -f manifests/02-db-admin-rolebinding.yaml

# Now db-admin ServiceAccount has db-admin permissions
kubectl describe rolebinding db-admin-binding
```

### Exercise 4: Test RBAC Permissions
```bash
# Create pod using ServiceAccount
kubectl apply -f manifests/03-pod-with-sa.yaml

# Exec into pod and test
kubectl exec -it rbac-test -- sh

# Inside pod, try kubectl commands
kubectl get pods          # Should work
kubectl get statefulsets  # Should work
kubectl delete pod xyz    # Should fail (no delete permission)
```

### Exercise 5: ClusterRole for Read-Only Access
```bash
# Create ClusterRole for read-only access
kubectl apply -f manifests/04-readonly-clusterrole.yaml

# Grant to ServiceAccount
kubectl apply -f manifests/05-readonly-clusterrolebinding.yaml

# Use in pod
kubectl apply -f manifests/06-readonly-pod.yaml
```

### Exercise 6: Secure Secrets Management
```bash
# Encrypt Secrets at rest (cluster-level)
# Enable encryption provider in kube-apiserver

# Use external secrets (Azure Key Vault, AWS Secrets Manager)
kubectl apply -f manifests/07-external-secrets.yaml

# RBAC for Secrets
kubectl apply -f manifests/08-secrets-role.yaml
# Only specific ServiceAccounts can read Secrets
```

### Exercise 7: Network Policies
```bash
# Default: All pods can communicate

# Apply network policy to restrict access
kubectl apply -f manifests/09-network-policy.yaml

# Example: Only frontend can access backend
# Example: Only backend can access database
# Example: No internet egress for database pods
```

### Exercise 8: Pod Security Standards
```bash
# Apply Pod Security admission
kubectl label namespace default pod-security.kubernetes.io/enforce=baseline

# Enforce restricted policy
kubectl label namespace production pod-security.kubernetes.io/enforce=restricted

# Try to create privileged pod (should fail)
kubectl apply -f manifests/10-privileged-pod.yaml
```

### Exercise 9: Database Access Control
```bash
# Create dedicated ServiceAccount per app
kubectl create serviceaccount webapp-sa

# Grant minimal database permissions
kubectl apply -f manifests/11-webapp-db-role.yaml

# App can:
# - Connect to database Service
# - Read ConfigMaps (connection strings)
# - Read Secrets (credentials)
# But cannot:
# - Delete StatefulSets
# - Modify PVCs
# - Access other namespaces
```

### Exercise 10: Audit and Compliance
```bash
# Enable audit logging
# View who accessed what resources

# Check RBAC permissions
kubectl auth can-i get pods --as=system:serviceaccount:default:db-admin
kubectl auth can-i delete pods --as=system:serviceaccount:default:db-admin

# List all permissions for ServiceAccount
kubectl describe clusterrolebinding | grep db-admin
```

## Practice Challenges

1. **Challenge 1:** Create ServiceAccount for backup job with minimal permissions
2. **Challenge 2:** Create read-only access for monitoring tools
3. **Challenge 3:** Implement Network Policy: only app can access database
4. **Challenge 4:** Create Role for developer (can view, but not delete)
5. **Challenge 5:** Set up external Secrets management with Azure Key Vault

**Solutions in `exercises/solutions.md`**

## Key Manifest Files (to be created)

- `01-db-admin-role.yaml` - Database administrator role
- `02-db-admin-rolebinding.yaml` - Role binding
- `03-pod-with-sa.yaml` - Pod using ServiceAccount
- `04-readonly-clusterrole.yaml` - Read-only access
- `05-readonly-clusterrolebinding.yaml` - Binding
- `06-network-policy.yaml` - Database network isolation
- `07-pod-security-policy.yaml` - Security standards
- `08-secrets-role.yaml` - Secrets access control

## Key Takeaways

✅ Use RBAC for fine-grained access control
✅ Apply least privilege principle
✅ Use ServiceAccounts for pod identities
✅ Network Policies isolate workloads
✅ Never store secrets in code or ConfigMaps
✅ Enable Pod Security Standards
✅ Audit access regularly

## RBAC Best Practices

### DO:
- Create dedicated ServiceAccounts per application
- Use Roles (namespace-scoped) over ClusterRoles when possible
- Apply least privilege (minimal permissions needed)
- Regularly audit RBAC permissions
- Use external secrets management
- Enable audit logging

### DON'T:
- Use default ServiceAccount
- Grant cluster-admin unless absolutely necessary
- Store secrets in environment variables (visible in kubectl describe)
- Allow privileged containers
- Expose unnecessary services externally

## Common RBAC Patterns for DBAs

### Pattern: Database Administrator
```yaml
# Can manage databases but not cluster infrastructure
permissions:
  - StatefulSets: get, list, watch, update, patch
  - Pods: get, list, watch, delete (for restarts)
  - Services: get, list, watch
  - PVCs: get, list, watch
  - Secrets: get, list (for credentials)
  - ConfigMaps: get, list, update
```

### Pattern: Application (Database Client)
```yaml
# Can only connect to database
permissions:
  - Services: get (database service only)
  - Secrets: get (database credentials only)
  - ConfigMaps: get (connection strings only)
```

### Pattern: Backup Job
```yaml
# Can read database and write backups
permissions:
  - Pods: get, list
  - Pods/exec: create (for pg_dump, sqlcmd)
  - PVCs: get, list (for backup storage)
  - Jobs: get, list, watch
```

### Pattern: Read-Only Monitor
```yaml
# Can only read metrics, no modifications
permissions:
  - Pods: get, list, watch
  - Services: get, list, watch
  - Endpoints: get, list, watch
  - Pods/log: get
```

## Network Policy Patterns

### Pattern: Database Isolation
```yaml
# Only backend pods can access database
# No internet egress from database
ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
```

### Pattern: Three-Tier Application
```yaml
# Frontend → Backend → Database
# Each tier isolated from others
```

## Security Checklist for Production

- [ ] RBAC enabled and configured
- [ ] ServiceAccounts per application
- [ ] Secrets encrypted at rest
- [ ] Network Policies applied
- [ ] Pod Security Standards enforced
- [ ] No privileged containers
- [ ] Resource limits set
- [ ] Audit logging enabled
- [ ] Regular security scans
- [ ] External secrets management
- [ ] TLS for database connections
- [ ] Regular credential rotation

## Next Steps
**Continue to:** [Module 10: Operators and Custom Resources](../module-10-operators/README.md)

---
*Note: This is a simplified outline. Full tutorial content will be expanded when you're ready to work on this module.*
