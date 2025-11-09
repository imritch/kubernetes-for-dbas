# Module 1: Exercise Solutions

## Challenge 1: Create a PostgreSQL Pod

**Task:** Create a pod running PostgreSQL with the specified configuration.

**Solution:**

```bash
kubectl run postgres-pod \
  --image=postgres:15 \
  --env="POSTGRES_PASSWORD=mysecretpassword"
```

Or using a manifest file (`postgres-pod.yaml`):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: postgres-pod
spec:
  containers:
  - name: postgres
    image: postgres:15
    env:
    - name: POSTGRES_PASSWORD
      value: mysecretpassword
    ports:
    - containerPort: 5432
```

Apply it:
```bash
kubectl apply -f postgres-pod.yaml
```

**Verification:**
```bash
kubectl get pod postgres-pod
kubectl logs postgres-pod
```

---

## Challenge 2: Create Namespace and Deploy PostgreSQL

**Task:** Create a `databases` namespace and deploy the PostgreSQL pod there.

**Solution:**

```bash
# Create the namespace
kubectl create namespace databases

# Create the pod in the namespace (imperative)
kubectl run postgres-pod \
  --image=postgres:15 \
  --env="POSTGRES_PASSWORD=mysecretpassword" \
  --namespace=databases
```

Or using the manifest approach:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: postgres-pod
  namespace: databases
spec:
  containers:
  - name: postgres
    image: postgres:15
    env:
    - name: POSTGRES_PASSWORD
      value: mysecretpassword
    ports:
    - containerPort: 5432
```

Apply it:
```bash
kubectl apply -f postgres-pod.yaml
```

**Verification:**
```bash
kubectl get pods -n databases
kubectl get namespaces
```

---

## Challenge 3: Add Labels to PostgreSQL Pod

**Task:** Add the specified labels to your PostgreSQL pod.

**Solution:**

```bash
# Method 1: Add labels one at a time
kubectl label pod postgres-pod app=postgres -n databases
kubectl label pod postgres-pod tier=database -n databases
kubectl label pod postgres-pod environment=dev -n databases

# Method 2: Add multiple labels at once (requires recreating pod)
kubectl delete pod postgres-pod -n databases

# Create with labels in manifest
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: postgres-pod
  namespace: databases
  labels:
    app: postgres
    tier: database
    environment: dev
spec:
  containers:
  - name: postgres
    image: postgres:15
    env:
    - name: POSTGRES_PASSWORD
      value: mysecretpassword
    ports:
    - containerPort: 5432
EOF
```

**Verification:**
```bash
kubectl get pod postgres-pod -n databases --show-labels

# Filter by label
kubectl get pods -n databases -l tier=database
kubectl get pods -n databases -l app=postgres,environment=dev
```

---

## Challenge 4: Connect to PostgreSQL and Run a Query

**Task:** Use `kubectl exec` to connect to PostgreSQL and execute a query.

**Solution:**

```bash
# Execute the query
kubectl exec -it postgres-pod -n databases -- psql -U postgres -c "SELECT version();"

# Alternative: Open an interactive psql session
kubectl exec -it postgres-pod -n databases -- psql -U postgres

# Inside psql, you can run various queries:
# SELECT version();
# \l                    -- List databases
# \dt                   -- List tables
# CREATE DATABASE testdb;
# \c testdb            -- Connect to testdb
# CREATE TABLE test (id SERIAL PRIMARY KEY, name TEXT);
# INSERT INTO test (name) VALUES ('Kubernetes');
# SELECT * FROM test;
# \q                   -- Quit
```

**Expected Output:**
```
                                                           version
-----------------------------------------------------------------------------------------------------------------------------
 PostgreSQL 15.x on x86_64-pc-linux-gnu, compiled by gcc (Debian x.x.x-x) x.x.x, 64-bit
(1 row)
```

**DBA Tip:** This is similar to using `sqlcmd -S localhost -U sa -Q "SELECT @@VERSION"` in SQL Server.

---

## Complete Solution: All Challenges Combined

Here's a complete manifest file that satisfies all challenges:

```yaml
# challenge-all.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: databases
---
apiVersion: v1
kind: Pod
metadata:
  name: postgres-pod
  namespace: databases
  labels:
    app: postgres
    tier: database
    environment: dev
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
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
```

Apply everything at once:
```bash
kubectl apply -f challenge-all.yaml

# Wait for pod to be ready
kubectl wait --for=condition=ready pod/postgres-pod -n databases --timeout=60s

# Run the query
kubectl exec -it postgres-pod -n databases -- psql -U postgres -c "SELECT version();"
```

---

## Bonus Challenges

### Bonus 1: View PostgreSQL Logs
```bash
kubectl logs postgres-pod -n databases

# Follow logs in real-time
kubectl logs -f postgres-pod -n databases
```

### Bonus 2: Check PostgreSQL Configuration
```bash
kubectl exec postgres-pod -n databases -- cat /var/lib/postgresql/data/postgresql.conf

# Or check specific settings
kubectl exec postgres-pod -n databases -- psql -U postgres -c "SHOW max_connections;"
kubectl exec postgres-pod -n databases -- psql -U postgres -c "SHOW shared_buffers;"
```

### Bonus 3: Create a Database and Table
```bash
kubectl exec -it postgres-pod -n databases -- psql -U postgres <<EOF
CREATE DATABASE sales;
\c sales
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO customers (name, email) VALUES ('John Doe', 'john@example.com');
SELECT * FROM customers;
EOF
```

---

## Cleanup

After completing the challenges:

```bash
# Delete the pod
kubectl delete pod postgres-pod -n databases

# Delete the namespace (and all resources in it)
kubectl delete namespace databases
```

---

## Key Learnings

From these challenges, you should now understand:

✅ How to create pods both imperatively and declaratively
✅ How to work with namespaces for resource isolation
✅ How to apply and filter by labels
✅ How to execute commands inside running containers
✅ The basics of running stateful applications (databases) in Kubernetes

**Note:** In production, you would NEVER run databases this way! We'll learn proper stateful workload patterns with StatefulSets and Persistent Volumes in Module 5.
