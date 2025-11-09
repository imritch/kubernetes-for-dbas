# Module 6: SQL Server on Kubernetes

## Overview
Deploy and manage SQL Server workloads on Kubernetes - bringing your DBA expertise to container orchestration!

**Duration:** 90 minutes

## Learning Objectives
- Deploy SQL Server 2022 on Kubernetes
- Configure persistent storage for SQL Server
- Manage SQL Server using StatefulSets
- Implement backup and restore
- Configure SQL Server settings via ConfigMaps
- Understand licensing and resource requirements
- Explore High Availability options

## Core Concepts

### SQL Server on Linux Containers
Microsoft provides official SQL Server container images:
- `mcr.microsoft.com/mssql/server:2022-latest`
- Runs on Linux (not Windows containers in Docker Desktop)
- Requires license acceptance via environment variable
- Minimum 2GB RAM

### SQL Server Requirements in Kubernetes
- **Memory**: Minimum 2Gi, recommended 4Gi+
- **CPU**: Minimum 2 cores for production
- **Storage**: Persistent volumes for data and logs
- **Licensing**: Set ACCEPT_EULA=Y and MSSQL_PID

## Hands-On Exercises

### Exercise 1: Deploy Single SQL Server Instance
```bash
# Create Secret for SA password
kubectl create secret generic mssql-secret \
  --from-literal=SA_PASSWORD='YourStrong!Passw0rd'

# Deploy SQL Server
kubectl apply -f manifests/01-sqlserver-deployment.yaml

# Wait for ready
kubectl get pods -w

# Connect using sqlcmd
kubectl exec -it deployment/mssql -- /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P 'YourStrong!Passw0rd' \
  -Q "SELECT @@VERSION"
```

### Exercise 2: SQL Server with Persistent Storage
```bash
# Deploy with PVC
kubectl apply -f manifests/02-sqlserver-statefulset.yaml

# Create database
kubectl exec -it mssql-0 -- /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P 'YourStrong!Passw0rd' \
  -Q "CREATE DATABASE SalesDB"

# Verify persistent storage
kubectl exec -it mssql-0 -- ls -lh /var/opt/mssql/data

# Delete pod and verify data persists
kubectl delete pod mssql-0
kubectl wait --for=condition=ready pod/mssql-0
kubectl exec -it mssql-0 -- /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -Q "SELECT name FROM sys.databases"
```

### Exercise 3: SQL Server Configuration with ConfigMaps
```bash
# Create ConfigMap for mssql.conf
kubectl create configmap mssql-config --from-file=mssql.conf

# Deploy SQL Server with custom config
kubectl apply -f manifests/03-sqlserver-with-config.yaml

# Verify settings
kubectl exec -it mssql-0 -- /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa \
  -Q "EXEC sp_configure 'max server memory'"
```

### Exercise 4: Expose SQL Server via Service
```bash
# Create NodePort service
kubectl apply -f manifests/04-sqlserver-service.yaml

# Get NodePort
kubectl get svc mssql-service

# Connect from local machine (SSMS, Azure Data Studio)
# Server: localhost,<NodePort>
# Username: sa
# Password: YourStrong!Passw0rd
```

### Exercise 5: Backup and Restore
```bash
# Create backup directory PVC
kubectl apply -f manifests/05-backup-pvc.yaml

# Backup database
kubectl exec -it mssql-0 -- /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa \
  -Q "BACKUP DATABASE SalesDB TO DISK='/var/opt/mssql/backup/SalesDB.bak'"

# Restore to new database
kubectl exec -it mssql-0 -- /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa \
  -Q "RESTORE DATABASE SalesDB_Copy FROM DISK='/var/opt/mssql/backup/SalesDB.bak' WITH MOVE 'SalesDB' TO '/var/opt/mssql/data/SalesDB_Copy.mdf', MOVE 'SalesDB_log' TO '/var/opt/mssql/data/SalesDB_Copy_log.ldf'"
```

### Exercise 6: Resource Limits for SQL Server
```bash
# Deploy with appropriate resources
kubectl apply -f manifests/06-sqlserver-resources.yaml

# Monitor resource usage
kubectl top pod mssql-0

# View resource allocation
kubectl describe pod mssql-0 | grep -A 10 "Requests:\|Limits:"
```

### Exercise 7: Health Checks for SQL Server
```bash
# Deploy with liveness and readiness probes
kubectl apply -f manifests/07-sqlserver-probes.yaml

# Probes check SQL Server availability
# Liveness: SELECT 1
# Readiness: SELECT 1 + recovery check
```

### Exercise 8: SQL Server Agent Jobs
```bash
# Enable SQL Agent
kubectl exec -it mssql-0 -- /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa \
  -Q "EXEC sp_configure 'Agent XPs', 1; RECONFIGURE"

# Create maintenance job
kubectl apply -f manifests/08-maintenance-job.yaml
```

## Practice Challenges

1. **Challenge 1:** Deploy SQL Server with 20Gi storage and 4Gi memory
2. **Challenge 2:** Create AdventureWorks database and backup to persistent volume
3. **Challenge 3:** Configure SQL Server with custom memory settings (max 3GB)
4. **Challenge 4:** Expose SQL Server externally and connect with Azure Data Studio
5. **Challenge 5:** Create CronJob for automated nightly backups

**Solutions in `exercises/solutions.md`**

## Key Manifest Files (to be created)

- `01-sqlserver-deployment.yaml` - Basic deployment
- `02-sqlserver-statefulset.yaml` - With persistent storage
- `03-sqlserver-with-config.yaml` - Custom configuration
- `04-sqlserver-service.yaml` - Network exposure
- `05-backup-pvc.yaml` - Backup storage
- `06-sqlserver-resources.yaml` - Production resources
- `07-sqlserver-probes.yaml` - Health checks
- `08-backup-cronjob.yaml` - Automated backups

## Key Takeaways

✅ SQL Server runs on Linux containers in Kubernetes
✅ Requires ACCEPT_EULA and SA password
✅ Use StatefulSets for persistent storage
✅ Minimum 2Gi RAM, recommended 4Gi+
✅ Configure via ConfigMaps and environment variables
✅ Backup to persistent volumes
✅ Use health probes for automatic recovery

## Production Considerations

### High Availability Options

1. **SQL Server Always On Availability Groups**
   - Requires Enterprise Edition
   - Complex setup in Kubernetes
   - Better suited for traditional VMs

2. **SQL Server Kubernetes Operator**
   - Automates deployment and management
   - Microsoft provides Azure Arc-enabled SQL Managed Instance
   - Simplified HA and DR

3. **Application-Level HA**
   - Primary-replica pattern
   - Read-only replicas for scale-out
   - Connection retry logic in apps

### Licensing
- **Developer Edition**: Free, non-production
- **Express Edition**: Free, limited (10GB database size)
- **Standard/Enterprise**: Requires license
- Set via `MSSQL_PID` environment variable

### Performance Tuning
```sql
-- Configure max server memory
EXEC sp_configure 'max server memory (MB)', 3072;
RECONFIGURE;

-- Configure max degree of parallelism
EXEC sp_configure 'max degree of parallelism', 4;
RECONFIGURE;

-- Enable Query Store
ALTER DATABASE SalesDB SET QUERY_STORE = ON;
```

### Security
- Never use SA account in production
- Create dedicated logins
- Use Azure Active Directory authentication (AKS)
- Encrypt connections (TLS)
- Enable Transparent Data Encryption (TDE)

## DBA Patterns

### Pattern: Production SQL Server
```yaml
# StatefulSet with:
# - 4Gi+ memory (guaranteed QoS)
# - SSD storage for data/logs
# - Separate PVC for backups
# - Health probes
# - Resource limits
```

### Pattern: Development SQL Server
```yaml
# Deployment with:
# - Developer Edition
# - 2Gi memory
# - Ephemeral storage (optional)
# - Quick startup
```

### Pattern: Backup Strategy
```yaml
# CronJob:
# - Full backup: Daily at 2 AM
# - Differential: Every 6 hours
# - Transaction log: Every 15 minutes
# - Retention: 7 days
# - Copy to external storage (S3, Azure Blob)
```

## Comparison: SQL Server vs PostgreSQL on Kubernetes

| Aspect | SQL Server | PostgreSQL |
|--------|-----------|------------|
| Image size | ~1.5GB | ~300MB |
| Min memory | 2Gi | 256Mi |
| License | Required (except Dev/Express) | Free (open source) |
| HA in K8s | Complex | Easier (Patroni, Stolon) |
| Ecosystem | Fewer operators | Rich ecosystem |
| Performance | Excellent | Excellent |
| Best for | Microsoft stack, .NET apps | Cloud-native, microservices |

## Next Steps
**Continue to:** [Module 7: Helm Charts](../module-07-helm/README.md)

---
*Note: This is a simplified outline. Full tutorial content will be expanded when you're ready to work on this module.*
