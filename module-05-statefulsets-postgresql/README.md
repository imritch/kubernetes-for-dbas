# Module 5: Persistent Volumes and StatefulSets with PostgreSQL

## Overview
Learn how to run stateful workloads with persistent storage - the most critical module for DBAs!

**Duration:** 90 minutes

## Learning Objectives
- Understand persistent storage in Kubernetes
- Work with PersistentVolumes (PV) and PersistentVolumeClaims (PVC)
- Deploy StatefulSets vs Deployments
- Run PostgreSQL with persistent data
- Implement backup and restore strategies
- Configure PostgreSQL replication

## Core Concepts

### Persistent Volumes
**DBA Analogy:** Like mounting disk drives for SQL Server data and log files.

**Components:**
- **PersistentVolume (PV)**: Cluster storage resource (like a disk)
- **PersistentVolumeClaim (PVC)**: Request for storage (like allocating space)
- **StorageClass**: Dynamic provisioner (automatic disk creation)

### StatefulSets
Manages stateful applications with:
- Stable network identities
- Ordered deployment and scaling
- Persistent storage per pod

**DBA Analogy:** Like SQL Server Always On AG replicas - each instance has identity, order, and dedicated storage.

**StatefulSet vs Deployment:**
| Feature | StatefulSet | Deployment |
|---------|-------------|------------|
| Pod naming | Predictable (pod-0, pod-1) | Random hash |
| Storage | Persistent per pod | Shared or ephemeral |
| Scaling order | Sequential | Random |
| Network ID | Stable | Changes |
| Use case | Databases, stateful apps | Stateless apps |

## Hands-On Exercises

### Exercise 1: Create PersistentVolumeClaim
```bash
# Create PVC
kubectl apply -f manifests/01-pvc.yaml

# View PVC (should be Bound)
kubectl get pvc

# View PV (auto-created by StorageClass)
kubectl get pv
```

### Exercise 2: PostgreSQL with Persistent Storage
```bash
# Deploy PostgreSQL with PVC
kubectl apply -f manifests/02-postgres-with-pvc.yaml

# Create test data
kubectl exec -it postgres-0 -- psql -U postgres -c "CREATE DATABASE testdb;"
kubectl exec -it postgres-0 -- psql -U postgres -d testdb -c "CREATE TABLE users (id SERIAL, name TEXT);"
kubectl exec -it postgres-0 -- psql -U postgres -d testdb -c "INSERT INTO users (name) VALUES ('Alice'), ('Bob');"

# Verify data
kubectl exec -it postgres-0 -- psql -U postgres -d testdb -c "SELECT * FROM users;"

# Delete the pod
kubectl delete pod postgres-0

# Wait for new pod (data persists!)
kubectl get pods -w

# Verify data still exists
kubectl exec -it postgres-0 -- psql -U postgres -d testdb -c "SELECT * FROM users;"
```

### Exercise 3: StatefulSet Basics
```bash
# Deploy StatefulSet
kubectl apply -f manifests/03-statefulset-postgres.yaml

# Notice sequential pod creation
kubectl get pods -w

# Each pod has stable name: postgres-0, postgres-1, postgres-2
kubectl get pods

# Each pod has its own PVC
kubectl get pvc
```

### Exercise 4: Headless Service with StatefulSet
```bash
# StatefulSet includes headless service
# Each pod gets DNS: postgres-0.postgres-headless.default.svc.cluster.local

# Test DNS resolution
kubectl run dns-test --rm -it --image=busybox -- nslookup postgres-0.postgres-headless
```

### Exercise 5: Scaling StatefulSets
```bash
# Scale up (sequential)
kubectl scale statefulset postgres --replicas=3

# Watch sequential creation: postgres-2 only after postgres-1 is ready
kubectl get pods -w

# Scale down (reverse order)
kubectl scale statefulset postgres --replicas=1

# postgres-2 deleted first, then postgres-1
```

### Exercise 6: PostgreSQL Replication (Streaming)
```bash
# Deploy primary and replica
kubectl apply -f manifests/04-postgres-replication.yaml

# Verify replication
kubectl exec -it postgres-primary-0 -- psql -U postgres -c "SELECT * FROM pg_stat_replication;"

# Test replication
kubectl exec -it postgres-primary-0 -- psql -U postgres -c "CREATE TABLE repl_test (id INT);"
kubectl exec -it postgres-replica-0 -- psql -U postgres -c "SELECT * FROM repl_test;"
```

### Exercise 7: Backup and Restore
```bash
# Backup database
kubectl exec postgres-0 -- pg_dump -U postgres mydb > backup.sql

# Restore to new database
cat backup.sql | kubectl exec -i postgres-0 -- psql -U postgres -d newdb
```

### Exercise 8: Storage Classes
```bash
# View available StorageClasses
kubectl get storageclass

# Create custom StorageClass
kubectl apply -f manifests/05-storageclass.yaml

# Use in PVC
kubectl apply -f manifests/06-pvc-custom-sc.yaml
```

## Practice Challenges

1. **Challenge 1:** Deploy PostgreSQL StatefulSet with 1 replica and 10Gi storage
2. **Challenge 2:** Create a database, insert data, delete the pod, verify data persists
3. **Challenge 3:** Configure PostgreSQL with custom settings using ConfigMap
4. **Challenge 4:** Set up PostgreSQL primary-replica replication
5. **Challenge 5:** Implement backup script using CronJob

**Solutions in `exercises/solutions.md`**

## Key Manifest Files (to be created)

- `01-pvc.yaml` - Basic PersistentVolumeClaim
- `02-postgres-with-pvc.yaml` - Single instance with storage
- `03-statefulset-postgres.yaml` - StatefulSet example
- `04-postgres-replication.yaml` - Primary-replica setup
- `05-storageclass.yaml` - Custom storage class
- `06-backup-cronjob.yaml` - Automated backups

## Key Takeaways

✅ StatefulSets are for databases and stateful apps
✅ Each pod gets dedicated persistent storage
✅ PVCs automatically created for each replica
✅ Data persists across pod restarts
✅ Sequential naming and scaling
✅ Stable network identities for replication

## Production Considerations

### High Availability
- Primary-replica replication
- Connection pooling (PgBouncer)
- Automated failover (Patroni, Stolon)
- Backup and restore procedures

### Performance
- Use SSD-backed storage (fast StorageClass)
- Set appropriate resource limits
- Configure PostgreSQL memory settings
- Monitor disk I/O

### Disaster Recovery
- Regular automated backups
- Point-in-time recovery (WAL archiving)
- Cross-region replication
- Backup retention policies

## DBA Patterns

### Pattern: PostgreSQL with Persistent Storage
```yaml
# StatefulSet ensures:
# - Stable hostname: postgres-0
# - Persistent data: /var/lib/postgresql/data
# - Ordered startup: 0 → 1 → 2
```

### Pattern: Primary-Replica Architecture
```yaml
# Write Service → postgres-primary-0 (read-write)
# Read Service → postgres-replica-{0,1,2} (read-only, load balanced)
```

## Next Steps
**Continue to:** [Module 6: SQL Server on Kubernetes](../module-06-sql-server/README.md)

---
*Note: This is a simplified outline. Full tutorial content will be expanded when you're ready to work on this module.*
