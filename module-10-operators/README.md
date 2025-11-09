# Module 10: Operators and Custom Resources

## Overview
Learn about Kubernetes Operators - automated operational knowledge for managing complex applications like databases.

**Duration:** 90 minutes

## Learning Objectives
- Understand Operators and Custom Resource Definitions (CRDs)
- Deploy database Operators
- Manage PostgreSQL with CloudNativePG Operator
- Explore SQL Server operators
- Understand operator patterns
- Build awareness of operator ecosystem

## Core Concepts

### What are Operators?
Operators extend Kubernetes to automate complex application management.

**DBA Analogy:** Like having an expert DBA encoded in software - automated backup, failover, scaling, upgrades.

**Operator Capabilities:**
- Automated deployment
- Backup and restore
- High availability and failover
- Scaling and replication
- Monitoring and alerting
- Upgrades and migrations

### Custom Resource Definitions (CRDs)
CRDs extend Kubernetes API with custom resource types.

**Example:**
```yaml
# Instead of manually creating StatefulSet, Service, PVC...
# You create one custom resource:
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: my-database
spec:
  instances: 3
  storage:
    size: 20Gi
```

### Operator Pattern
1. **Observe**: Watch custom resources
2. **Analyze**: Compare desired vs actual state
3. **Act**: Reconcile to desired state

**DBA Analogy:** Like automated Always On AG management - monitors health, performs failover, adds replicas.

## Hands-On Exercises

### Exercise 1: Install CloudNativePG Operator
```bash
# Add Helm repo
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update

# Install operator
helm install cnpg cnpg/cloudnative-pg

# Verify operator is running
kubectl get pods -l app.kubernetes.io/name=cloudnative-pg

# View CRDs installed
kubectl get crds | grep postgresql
```

### Exercise 2: Deploy PostgreSQL Cluster with Operator
```bash
# Create PostgreSQL cluster (3 instances with replication)
kubectl apply -f manifests/01-postgres-cluster.yaml

# Watch cluster creation
kubectl get pods -w

# Operator creates:
# - 3 PostgreSQL pods (1 primary, 2 replicas)
# - Services (read-write, read-only)
# - PVCs for each instance
# - Replication configuration
# - Monitoring

# View cluster status
kubectl get cluster my-postgres-cluster
```

### Exercise 3: Explore Operator-Managed Resources
```bash
# View the cluster
kubectl describe cluster my-postgres-cluster

# See all pods (primary + replicas)
kubectl get pods -l cnpg.io/cluster=my-postgres-cluster

# Check which pod is primary
kubectl get pods -l role=primary

# View services (read-write to primary, read to replicas)
kubectl get svc
```

### Exercise 4: Automatic Failover
```bash
# Identify primary pod
PRIMARY=$(kubectl get pods -l role=primary -o name)

# Delete primary pod (simulate failure)
kubectl delete $PRIMARY

# Watch operator perform automatic failover
kubectl get pods -w

# New primary elected automatically
# Old primary becomes replica when it comes back
# No manual intervention needed!
```

### Exercise 5: Backup with Operator
```bash
# Configure backup
kubectl apply -f manifests/02-postgres-backup.yaml

# Trigger on-demand backup
kubectl apply -f manifests/03-postgres-backup-job.yaml

# List backups
kubectl get backups

# View backup status
kubectl describe backup my-backup-1
```

### Exercise 6: Point-in-Time Recovery
```bash
# Restore to specific point in time
kubectl apply -f manifests/04-postgres-restore.yaml

# Operator creates new cluster from backup
# Replays WAL to specified timestamp
```

### Exercise 7: Scaling with Operator
```bash
# Scale replicas
kubectl patch cluster my-postgres-cluster \
  --type merge \
  -p '{"spec":{"instances":5}}'

# Operator automatically:
# - Creates 2 new replica pods
# - Configures replication
# - Updates read service
# - Balances load
```

### Exercise 8: Monitor with Operator
```bash
# Operator exposes Prometheus metrics
kubectl get servicemonitor

# View metrics in Grafana
# - Replication lag
# - Connection count
# - Transaction rate
# - Cluster health
```

### Exercise 9: Explore Other Database Operators
```bash
# Postgres Operator by Zalando
helm install postgres-operator postgres-operator-charts/postgres-operator

# Percona Operator for PostgreSQL
kubectl apply -f percona-postgres-operator.yaml

# Percona Operator for MySQL
kubectl apply -f percona-mysql-operator.yaml

# MongoDB Community Operator
kubectl apply -f mongodb-operator.yaml
```

### Exercise 10: SQL Server with Operator
```bash
# Azure Arc-enabled SQL Managed Instance
# (Requires Azure Arc setup)

# Install Arc data controller
# Deploy SQL Managed Instance
kubectl apply -f manifests/05-sql-mi.yaml

# Operator provides:
# - Automated backups
# - High availability
# - Monitoring
# - Patching
```

## Practice Challenges

1. **Challenge 1:** Deploy 3-node PostgreSQL cluster with automatic backups
2. **Challenge 2:** Test automatic failover by deleting primary pod
3. **Challenge 3:** Perform point-in-time recovery to 1 hour ago
4. **Challenge 4:** Scale cluster from 3 to 5 replicas
5. **Challenge 5:** Configure monitoring and alerts with operator

**Solutions in `exercises/solutions.md`**

## Key Manifest Files (to be created)

- `01-postgres-cluster.yaml` - PostgreSQL cluster definition
- `02-postgres-backup.yaml` - Backup configuration
- `03-postgres-backup-job.yaml` - On-demand backup
- `04-postgres-restore.yaml` - PITR configuration
- `05-sql-mi.yaml` - SQL Managed Instance

## Popular Database Operators

### PostgreSQL Operators
1. **CloudNativePG** (Recommended)
   - HA with automatic failover
   - Automated backups (WAL archiving)
   - PITR (Point-in-Time Recovery)
   - Rolling updates
   - Monitoring integration

2. **Zalando Postgres Operator**
   - Team-based management
   - Connection pooling (PgBouncer)
   - Logical backups

3. **Crunchy Data Postgres Operator**
   - Enterprise features
   - Disaster recovery
   - Monitoring with pgMonitor

### Other Database Operators
- **Percona Operators**: PostgreSQL, MySQL, MongoDB
- **MongoDB Community Operator**: MongoDB clusters
- **Redis Operator**: Redis HA clusters
- **Elasticsearch Operator**: Elasticsearch clusters

### SQL Server Operators
- **Azure Arc SQL Managed Instance**: Enterprise-grade HA
- **MSSQL Operator** (Community): Basic management

## Key Takeaways

✅ Operators automate complex operational tasks
✅ CRDs provide declarative database management
✅ Automatic failover and self-healing
✅ Built-in backup and restore
✅ Production-grade HA out of the box
✅ Monitoring and alerting included

## Operator vs Manual Management

| Task | Manual | With Operator |
|------|--------|---------------|
| Deploy HA cluster | Hours, complex | Minutes, simple YAML |
| Failover | Manual intervention | Automatic |
| Backup | Cron jobs, scripts | Built-in, automated |
| Restore | Complex procedures | Simple YAML |
| Scaling | Manual StatefulSet edits | Change replica count |
| Monitoring | Setup exporters | Included |
| Upgrades | Risky, manual | Rolling, automated |

## Sample Operator Resource: PostgreSQL Cluster

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: production-db
spec:
  instances: 3

  postgresql:
    parameters:
      max_connections: "200"
      shared_buffers: "256MB"

  bootstrap:
    initdb:
      database: myapp
      owner: myapp

  storage:
    size: 100Gi
    storageClass: fast-ssd

  backup:
    barmanObjectStore:
      destinationPath: s3://my-backups/postgres
      s3Credentials:
        accessKeyId:
          name: aws-creds
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: aws-creds
          key: SECRET_ACCESS_KEY
    retentionPolicy: "30d"

  monitoring:
    enablePodMonitor: true

  resources:
    requests:
      memory: "2Gi"
      cpu: "1"
    limits:
      memory: "4Gi"
      cpu: "2"
```

**That's it!** Operator handles:
- Creating 3 pods (1 primary, 2 replicas)
- Configuring replication
- Setting up backup to S3
- Exposing metrics for Prometheus
- Managing failover
- Everything!

## DBA Patterns with Operators

### Pattern: Multi-Environment Management
```yaml
# dev-cluster.yaml
spec:
  instances: 1
  storage:
    size: 10Gi

# prod-cluster.yaml
spec:
  instances: 5
  storage:
    size: 500Gi
  backup:
    retentionPolicy: "90d"
```

### Pattern: Disaster Recovery
```yaml
# Primary cluster in us-east-1
# Backup to S3

# DR cluster in us-west-2
# Restore from same S3 backup
# Can promote to primary if needed
```

## When to Use Operators

### Use Operators When:
- Running production databases in Kubernetes
- Need automated HA and failover
- Want automated backups and PITR
- Managing multiple database clusters
- Need consistent operations across environments

### Manual Management When:
- Learning Kubernetes basics
- Development/testing only
- Simple, ephemeral databases
- Custom requirements not supported by operators

## Production Checklist with Operators

- [ ] Operator deployed and healthy
- [ ] Database cluster with 3+ replicas
- [ ] Automated backups configured
- [ ] Backup tested and verified
- [ ] PITR tested
- [ ] Monitoring integrated with Prometheus/Grafana
- [ ] Alerts configured
- [ ] Failover tested
- [ ] Resource limits set appropriately
- [ ] Storage class uses fast SSD
- [ ] Network policies applied
- [ ] RBAC configured
- [ ] Disaster recovery plan documented

## Congratulations!

You've completed all 10 modules of the Kubernetes for SQL Server DBAs tutorial!

You now know:
✅ Kubernetes fundamentals (Pods, Deployments, Services)
✅ Configuration management (ConfigMaps, Secrets)
✅ Stateful workloads (StatefulSets, PVCs)
✅ Database deployments (PostgreSQL, SQL Server)
✅ Package management (Helm)
✅ Monitoring and observability (Prometheus, Grafana)
✅ Security (RBAC, Network Policies)
✅ Advanced automation (Operators, CRDs)

## Next Steps

1. **Practice**: Deploy a real application with database
2. **Explore**: Try different operators and tools
3. **Contribute**: Share your learnings with the DBA community
4. **Certify**: Consider CKA (Certified Kubernetes Administrator)
5. **Advance**: Explore service meshes (Istio, Linkerd)

## Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [CloudNativePG](https://cloudnative-pg.io/)
- [Operator Hub](https://operatorhub.io/)
- [CNCF Landscape](https://landscape.cncf.io/)
- [Kubernetes Slack](https://slack.k8s.io/)

---

**Thank you for completing this tutorial!** 🎉
