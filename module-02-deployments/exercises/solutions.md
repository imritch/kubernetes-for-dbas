# Module 2: Exercise Solutions

## Challenge 1: Create PostgreSQL Deployment

**Task:** Create a deployment for PostgreSQL with specified configuration.

**Solution:**

```yaml
# postgres-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-deploy
  labels:
    app: postgres
    tier: database
spec:
  replicas: 1  # Single replica for now (we'll learn proper patterns in Module 5)
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
        tier: database
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_PASSWORD
          value: mysecretpassword  # Never do this in production! Use Secrets (Module 4)
        - name: POSTGRES_DB
          value: mydb
        ports:
        - containerPort: 5432
          name: postgres
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

Apply it:
```bash
kubectl apply -f postgres-deployment.yaml

# Verify
kubectl get deployment postgres-deploy
kubectl get pods -l app=postgres
```

---

## Challenge 2: Add Liveness Probe to PostgreSQL

**Task:** Add a liveness probe using `pg_isready`.

**Solution:**

```yaml
# postgres-deployment-with-probes.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-deploy
  labels:
    app: postgres
    tier: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
        tier: database
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_PASSWORD
          value: mysecretpassword
        - name: POSTGRES_DB
          value: mydb
        ports:
        - containerPort: 5432
          name: postgres
        # Liveness probe: Is PostgreSQL process running and responding?
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U postgres
          initialDelaySeconds: 30  # Wait for PostgreSQL to start
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        # Readiness probe: Is PostgreSQL ready to accept connections?
        readinessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U postgres
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

Apply and verify:
```bash
kubectl apply -f postgres-deployment-with-probes.yaml

# Watch the pod come up
kubectl get pods -w

# Check the probe configuration
kubectl describe pod <postgres-pod-name> | grep -A 10 "Liveness\|Readiness"

# View events to see probe checks
kubectl get events --sort-by='.lastTimestamp' | grep -i probe
```

**DBA Tip:** The `pg_isready` command is similar to checking SQL Server service status. It returns 0 if PostgreSQL can accept connections.

---

## Challenge 3: Scale PostgreSQL Deployment

**Task:** Scale to 0 replicas (pause), then back to 1.

**Solution:**

```bash
# Scale down to 0 (effectively pausing the database)
kubectl scale deployment postgres-deploy --replicas=0

# Verify all pods are terminated
kubectl get pods -l app=postgres

# Check the deployment (desired replicas = 0)
kubectl get deployment postgres-deploy

# Scale back up to 1
kubectl scale deployment postgres-deploy --replicas=1

# Watch the pod come back
kubectl get pods -l app=postgres -w

# Verify it's running
kubectl get deployment postgres-deploy
```

**Output:**
```
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
postgres-deploy   0/0     0            0           5m
```

Then after scaling back:
```
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
postgres-deploy   1/1     1            1           6m
```

**DBA Analogy:** This is similar to stopping and starting a SQL Server instance, but managed declaratively.

**Warning:** Data is lost when pods are deleted (unless using Persistent Volumes - Module 5)!

---

## Challenge 4: Rolling Update PostgreSQL

**Task:** Simulate a rolling update by changing PostgreSQL version.

**Solution:**

```bash
# Check current image version
kubectl describe deployment postgres-deploy | grep Image:
# Output: Image: postgres:15

# Update to a specific minor version
kubectl set image deployment/postgres-deploy postgres=postgres:15.3

# Watch the rollout
kubectl rollout status deployment/postgres-deploy

# Verify the update
kubectl describe deployment postgres-deploy | grep Image:
# Output: Image: postgres:15.3

# Check rollout history
kubectl rollout history deployment/postgres-deploy

# View the old and new ReplicaSets
kubectl get rs -l app=postgres
```

**What happened?**
1. New ReplicaSet created with postgres:15.3
2. New pod started
3. Old pod terminated after new pod is ready
4. Old ReplicaSet scaled to 0 (kept for rollback)

**Rollback if needed:**
```bash
kubectl rollout undo deployment/postgres-deploy

# Verify rollback
kubectl rollout status deployment/postgres-deploy
kubectl describe deployment postgres-deploy | grep Image:
```

**DBA Considerations:**
- In production, database updates require careful planning
- Schema changes might not be backward-compatible
- Consider maintenance windows
- Test rollback procedures
- Use blue-green or canary deployments for critical databases

---

## Bonus Challenge: Test Health Probes

**Task:** Verify the liveness and readiness probes are working.

**Solution:**

```bash
# Get the pod name
POD_NAME=$(kubectl get pods -l app=postgres -o jsonpath='{.items[0].metadata.name}')

# Check probe status
kubectl describe pod $POD_NAME | grep -A 10 "Conditions:"

# Manually test the liveness probe command
kubectl exec $POD_NAME -- pg_isready -U postgres

# Expected output:
# /tmp:5432 - accepting connections

# Simulate a failure by stopping PostgreSQL (for testing only!)
kubectl exec $POD_NAME -- pg_ctl stop -D /var/lib/postgresql/data

# Watch Kubernetes restart the container
kubectl get pods -w

# You'll see the RESTARTS column increment
```

**Cleanup:**
```bash
# The pod will restart automatically, or you can manually restart:
kubectl delete pod $POD_NAME

# New pod will be created immediately by the ReplicaSet
```

---

## Complete Solution: Production-Grade PostgreSQL Deployment

Here's a more complete example combining all best practices:

```yaml
# production-postgres-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-deploy
  labels:
    app: postgres
    tier: database
    environment: production
spec:
  replicas: 1
  strategy:
    type: Recreate  # For databases, avoid running multiple versions
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
        tier: database
    spec:
      containers:
      - name: postgres
        image: postgres:15.3
        env:
        - name: POSTGRES_PASSWORD
          value: mysecretpassword  # Use Secrets in Module 4
        - name: POSTGRES_DB
          value: productiondb
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        ports:
        - containerPort: 5432
          name: postgres
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U postgres
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 6
        readinessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U postgres && psql -U postgres -c "SELECT 1"
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "512Mi"  # Guaranteed QoS
            cpu: "500m"
        # Note: No persistent volume yet - we'll add in Module 5
```

Deploy and test:
```bash
kubectl apply -f production-postgres-deployment.yaml

# Wait for ready status
kubectl wait --for=condition=available --timeout=60s deployment/postgres-deploy

# Connect and test
kubectl exec -it deployment/postgres-deploy -- psql -U postgres -c "SELECT version();"

# Create test data
kubectl exec -it deployment/postgres-deploy -- psql -U postgres -d productiondb <<EOF
CREATE TABLE health_check (
    id SERIAL PRIMARY KEY,
    check_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TEXT
);
INSERT INTO health_check (status) VALUES ('healthy');
SELECT * FROM health_check;
EOF
```

---

## Key Learnings

From these challenges, you should understand:

✅ How to create production-ready Deployments with resource limits
✅ How to implement health checks for databases
✅ How to scale deployments up and down
✅ How to perform rolling updates and rollbacks
✅ Why single-replica databases need the Recreate strategy
✅ The importance of proper resource allocation

**Important Notes for DBAs:**
1. **Deployments are for stateless apps** - Use StatefulSets for databases (Module 5)
2. **Never put passwords in YAML** - Use Secrets (Module 4)
3. **Data doesn't persist** without Persistent Volumes (Module 5)
4. **Health checks are critical** for automatic recovery
5. **Resource limits prevent the noisy neighbor problem**

---

## Cleanup

```bash
kubectl delete deployment postgres-deploy
```
