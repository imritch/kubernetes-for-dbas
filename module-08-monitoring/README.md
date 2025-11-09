# Module 8: Monitoring and Observability

## Overview
Implement comprehensive monitoring for Kubernetes clusters and database workloads using Prometheus and Grafana.

**Duration:** 90 minutes

## Learning Objectives
- Deploy Prometheus for metrics collection
- Configure Grafana for visualization
- Monitor Kubernetes cluster resources
- Monitor database metrics (PostgreSQL, SQL Server)
- Set up alerting rules
- Implement logging with Loki
- Understand the observability pillars

## Core Concepts

### The Three Pillars of Observability

1. **Metrics**: Time-series data (CPU, memory, query rate)
2. **Logs**: Event records (application logs, error messages)
3. **Traces**: Request flow through distributed systems

**DBA Analogy:**
- Metrics = Performance Monitor, DMVs
- Logs = SQL Server Error Log, Extended Events
- Traces = SQL Profiler, Query Store

### Monitoring Stack

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Loki**: Log aggregation
- **Alertmanager**: Alert routing and management

## Hands-On Exercises

### Exercise 1: Install Prometheus Stack
```bash
# Add Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
helm install prometheus prometheus-community/kube-prometheus-stack

# Wait for pods
kubectl get pods -l "release=prometheus"

# Port forward Grafana
kubectl port-forward svc/prometheus-grafana 3000:80

# Access: http://localhost:3000
# Default credentials: admin / prom-operator
```

### Exercise 2: Explore Prometheus Metrics
```bash
# Port forward Prometheus
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090

# Access: http://localhost:9090

# Example PromQL queries:
# - container_memory_usage_bytes
# - rate(container_cpu_usage_seconds_total[5m])
# - kube_pod_status_phase
```

### Exercise 3: Grafana Dashboards
```bash
# Access Grafana
kubectl port-forward svc/prometheus-grafana 3000:80

# Explore pre-installed dashboards:
# - Kubernetes / Compute Resources / Cluster
# - Kubernetes / Compute Resources / Namespace (Pods)
# - Node Exporter / Nodes

# Import dashboard from grafana.com
# Dashboard ID: 6417 (Kubernetes Cluster Monitoring)
```

### Exercise 4: Monitor PostgreSQL with Prometheus
```bash
# Deploy PostgreSQL with postgres_exporter
kubectl apply -f manifests/01-postgres-with-exporter.yaml

# Exporter exposes metrics at :9187/metrics
# Prometheus scrapes automatically via ServiceMonitor

# View PostgreSQL metrics in Grafana
# - pg_up
# - pg_stat_database_tup_fetched
# - pg_stat_activity_count
```

### Exercise 5: Monitor SQL Server
```bash
# Deploy SQL Server with sql_exporter
kubectl apply -f manifests/02-sqlserver-with-exporter.yaml

# Key metrics:
# - mssql_instance_local_time
# - mssql_io_stall_seconds
# - mssql_deadlocks
# - mssql_buffer_cache_hit_ratio
```

### Exercise 6: Custom ServiceMonitor
```bash
# Create ServiceMonitor for app
kubectl apply -f manifests/03-servicemonitor.yaml

# Prometheus discovers and scrapes automatically
# Verify targets in Prometheus UI: Status → Targets
```

### Exercise 7: Alerting Rules
```bash
# Create PrometheusRule
kubectl apply -f manifests/04-alert-rules.yaml

# Example alerts:
# - HighMemoryUsage
# - PodCrashLooping
# - DatabaseDown
# - SlowQueries

# View alerts in Prometheus: Alerts tab
# View in Grafana: Alerting → Alert Rules
```

### Exercise 8: Install Loki for Logging
```bash
# Install Loki stack
helm install loki grafana/loki-stack \
  --set grafana.enabled=false \
  --set prometheus.enabled=false

# View logs in Grafana
# Add Loki data source
# Explore → Select Loki
# Query: {namespace="default"}
```

### Exercise 9: Database-Specific Dashboards
```bash
# Import PostgreSQL dashboard
# Dashboard ID: 9628 (PostgreSQL Database)

# Import SQL Server dashboard
# Dashboard ID: 14183 (SQL Server)

# Customize for your environment
```

### Exercise 10: Alert Notifications
```bash
# Configure Alertmanager
kubectl edit secret prometheus-kube-prometheus-alertmanager

# Add receivers (email, Slack, PagerDuty)
# Apply alertmanager-config.yaml
```

## Practice Challenges

1. **Challenge 1:** Create custom Grafana dashboard for PostgreSQL
2. **Challenge 2:** Set up alert for database down (no connections)
3. **Challenge 3:** Monitor query performance (slow queries)
4. **Challenge 4:** Create alert for high disk usage on database PVC
5. **Challenge 5:** Set up log aggregation for all database logs

**Solutions in `exercises/solutions.md`**

## Key Manifest Files (to be created)

- `01-postgres-with-exporter.yaml` - PostgreSQL with metrics
- `02-sqlserver-with-exporter.yaml` - SQL Server with metrics
- `03-servicemonitor.yaml` - Prometheus service discovery
- `04-alert-rules.yaml` - Database alerting rules
- `05-grafana-dashboard.json` - Custom dashboard

## Key Metrics for DBAs

### PostgreSQL Metrics
```promql
# Database size
pg_database_size_bytes

# Active connections
pg_stat_activity_count

# Transaction rate
rate(pg_stat_database_xact_commit[5m])

# Cache hit ratio
pg_stat_database_blks_hit / (pg_stat_database_blks_hit + pg_stat_database_blks_read)

# Replication lag
pg_replication_lag

# Slow queries
pg_stat_statements_mean_time_seconds
```

### SQL Server Metrics
```promql
# Buffer cache hit ratio
mssql_buffer_cache_hit_ratio

# Page life expectancy
mssql_page_life_expectancy

# Batch requests per second
rate(mssql_batch_requests[1m])

# Deadlocks
rate(mssql_deadlocks[5m])

# Wait stats
mssql_waitstats_wait_time_ms
```

### Kubernetes Metrics
```promql
# Pod CPU usage
rate(container_cpu_usage_seconds_total[5m])

# Pod memory usage
container_memory_usage_bytes

# Disk usage
kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes

# Pod restarts
rate(kube_pod_container_status_restarts_total[15m])
```

## Key Takeaways

✅ Prometheus is the standard for Kubernetes monitoring
✅ Grafana provides powerful visualization
✅ ServiceMonitor enables automatic metric discovery
✅ Database exporters expose database-specific metrics
✅ Alerting prevents issues before they impact users
✅ Log aggregation completes the observability picture

## Sample Alert Rules

```yaml
# Database down
- alert: DatabaseDown
  expr: pg_up == 0
  for: 1m
  annotations:
    summary: "PostgreSQL is down"

# High connection count
- alert: HighConnections
  expr: pg_stat_activity_count > 90
  for: 5m
  annotations:
    summary: "PostgreSQL connection count high"

# Replication lag
- alert: ReplicationLag
  expr: pg_replication_lag > 60
  for: 5m
  annotations:
    summary: "PostgreSQL replication lag > 60s"

# Low cache hit ratio
- alert: LowCacheHitRatio
  expr: pg_cache_hit_ratio < 0.90
  for: 10m
  annotations:
    summary: "PostgreSQL cache hit ratio < 90%"
```

## DBA Patterns

### Pattern: Complete Observability
```yaml
# Metrics: Prometheus + exporters
# Logs: Loki + promtail
# Traces: Jaeger (for application tracing)
# Dashboards: Grafana
# Alerts: Alertmanager → PagerDuty/Slack
```

### Pattern: Database Health Dashboard
```
Panels:
- Database status (up/down)
- Connection count
- Transaction rate
- Cache hit ratio
- Disk usage
- Replication lag
- Top 10 slow queries
- Error log tail
```

## Next Steps
**Continue to:** [Module 9: Security and RBAC](../module-09-security-rbac/README.md)

---
*Note: This is a simplified outline. Full tutorial content will be expanded when you're ready to work on this module.*
