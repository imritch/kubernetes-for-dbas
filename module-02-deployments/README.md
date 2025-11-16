# Module 2: Deployments and ReplicaSets

## Overview

In Module 1, you learned that pods are ephemeral and should not be created directly. In this module, you'll discover **Deployments** - the recommended way to run applications in Kubernetes with built-in scaling, self-healing, and update capabilities.

**Learning Objectives:**
- Understand Deployments and ReplicaSets
- Scale applications horizontally
- Perform rolling updates and rollbacks
- Implement health checks (liveness and readiness probes)
- Manage application lifecycle

**Duration:** 45-60 minutes

## Core Concepts

### Deployments
A **Deployment** manages the lifecycle of your application. It's a declarative way to ensure a specified number of pod replicas are running at all times.

**DBA Analogy:** Think of a Deployment like SQL Server Always On Availability Groups - it ensures your application (database) stays available by managing replicas and handling failures.

**Key features:**
- Automated rollout and rollback
- Self-healing (recreates failed pods)
- Scaling (horizontal)
- Update strategies (rolling, recreate)

### ReplicaSets
A **ReplicaSet** ensures a specified number of pod replicas are running. Deployments create and manage ReplicaSets automatically.

**Relationship:**
```
Deployment → ReplicaSet → Pods
```

**DBA Analogy:**
- Deployment = Always On Availability Group configuration
- ReplicaSet = Replica set at a specific point in time
- Pods = Individual replica instances

### Understanding Replicas

When you specify `--replicas=3` (or `replicas: 3` in YAML), this tells Kubernetes to create and maintain **3 pods** running your application.

**How replicas work:**
1. The **Deployment** creates a **ReplicaSet**
2. The **ReplicaSet** ensures exactly **3 pods** are running at all times
3. If a pod crashes or gets deleted, the ReplicaSet automatically creates a new one to maintain the count

**Key differences from SQL Server Always On:**
- In Kubernetes, all replicas can serve traffic simultaneously (load-balanced)
- There's no concept of "primary" vs "secondary" at the pod level - all pods are identical
- Scaling is instant: `kubectl scale deployment app --replicas=5` immediately creates 2 more pods
- All replicas are active-active, not active-passive

**Example:**
```bash
kubectl create deployment hello-k8s --image=nginx:latest --replicas=3
# Creates: 1 Deployment → 1 ReplicaSet → 3 Pods

kubectl get pods
# You'll see 3 pods named something like:
# hello-k8s-7d4b9c8f6d-abc12
# hello-k8s-7d4b9c8f6d-def34
# hello-k8s-7d4b9c8f6d-ghi56
```

**So remember: replicas = number of pods running your application**

### Health Checks

Kubernetes provides two types of health checks:

1. **Liveness Probe**: Is the container alive?
   - If fails → Kubernetes restarts the container
   - Like monitoring SQL Server service status

2. **Readiness Probe**: Is the container ready to serve traffic?
   - If fails → Kubernetes stops sending traffic (but doesn't restart)
   - Like checking if SQL Server has completed recovery

## Hands-On Exercises

### Exercise 1: Create Your First Deployment

```bash
# Create a deployment imperatively
kubectl create deployment nginx-deploy --image=nginx:latest --replicas=3

# Watch the deployment rollout
kubectl rollout status deployment/nginx-deploy

# Check the deployment
kubectl get deployments

# See the ReplicaSet created automatically
kubectl get replicasets

# See the pods
kubectl get pods

# Get everything together
kubectl get all
```

**What happened?**
1. Deployment created a ReplicaSet
2. ReplicaSet created 3 pods
3. Pods are running nginx containers

### Exercise 2: Understanding the Hierarchy

Let's examine the relationship between Deployment, ReplicaSet, and Pods:

```bash
# Get deployment details
kubectl describe deployment nginx-deploy

# Get the ReplicaSet name
kubectl get rs

# Describe the ReplicaSet (notice the owner reference)
kubectl describe rs <replicaset-name>

# Get pod details (notice the owner reference)
kubectl describe pod <pod-name>

# See the labels that tie everything together
kubectl get deployment nginx-deploy --show-labels
kubectl get rs --show-labels
kubectl get pods --show-labels
```

### Exercise 3: Declarative Deployment

Now let's use a proper YAML manifest:

```bash
# Apply the deployment
kubectl apply -f manifests/01-simple-deployment.yaml

# Verify
kubectl get deployment web-app

# Get pods with label selector
kubectl get pods -l app=web-app
```

### Exercise 4: Scaling Applications

**Scaling** adjusts the number of pod replicas:

```bash
# Scale imperatively
kubectl scale deployment web-app --replicas=5

# Watch the new pods being created
kubectl get pods -w
# (Ctrl+C to exit)

# Scale down
kubectl scale deployment web-app --replicas=2

# Watch pods terminating
kubectl get pods -w

# Better way: Edit the manifest and apply
# Edit manifests/01-simple-deployment.yaml (change replicas to 4)
kubectl apply -f manifests/01-simple-deployment.yaml

# Verify
kubectl get deployment web-app
```

**DBA Parallel:** Similar to adding/removing replicas in an Always On AG, but much faster!

### Exercise 5: Self-Healing Demonstration

Let's see Kubernetes self-healing in action:

```bash
# Ensure web-app is running with 3 replicas
kubectl scale deployment web-app --replicas=3

# List the pods
kubectl get pods -l app=web-app

# Delete one pod manually
kubectl delete pod <pod-name>

# Immediately check pods again
kubectl get pods -l app=web-app -w

# Notice: The ReplicaSet immediately creates a new pod to maintain 3 replicas!
```

**DBA Analogy:** Like automatic replica failover in Always On - the system self-heals!

### Exercise 6: Rolling Updates

Update your application with zero downtime:

```bash
# Apply the initial deployment
kubectl apply -f manifests/02-versioned-deployment.yaml

# Check the image version
kubectl describe deployment versioned-app | grep Image:

# Update the image (rolling update)
kubectl set image deployment/versioned-app nginx=nginx:1.24

# Watch the rollout
kubectl rollout status deployment/versioned-app

# See the rollout history
kubectl rollout history deployment/versioned-app

# Describe the deployment to see both old and new ReplicaSets
kubectl get rs
```

**What happened?**
1. New ReplicaSet created with nginx:1.24
2. New pods gradually replace old pods
3. Old ReplicaSet scaled down to 0 (but kept for rollback)

### Exercise 7: Rollback

Made a mistake? Rollback easily:

```bash
# Make a bad update (image doesn't exist)
kubectl set image deployment/versioned-app nginx=nginx:broken-tag

# Watch it fail
kubectl rollout status deployment/versioned-app

# Check pod status (some will be in ImagePullBackOff)
kubectl get pods

# Rollback to previous version
kubectl rollout undo deployment/versioned-app

# Verify the rollback
kubectl rollout status deployment/versioned-app

# Check history
kubectl rollout history deployment/versioned-app

# Rollback to a specific revision
kubectl rollout undo deployment/versioned-app --to-revision=1
```

**DBA Analogy:** Like restoring a database from backup, but instant!

### Exercise 8: Update Strategies

Kubernetes supports different update strategies:

```bash
# Apply the recreate strategy deployment
kubectl apply -f manifests/03-recreate-strategy.yaml

# Update the image
kubectl set image deployment/recreate-app nginx=nginx:1.24

# Notice: All pods terminate before new ones start (brief downtime)
kubectl get pods -w

# Compare with RollingUpdate strategy
kubectl apply -f manifests/04-rolling-update-strategy.yaml

# Update this deployment
kubectl set image deployment/rolling-app nginx=nginx:1.24

# Notice: New pods start before old ones terminate (zero downtime)
kubectl get pods -w
```

**Strategy Comparison:**

| Strategy | Downtime | Use Case |
|----------|----------|----------|
| **RollingUpdate** | None | Stateless apps, web services |
| **Recreate** | Brief | Apps that can't run multiple versions simultaneously |

### Exercise 9: Health Checks - Liveness Probes

```bash
# Deploy an app with liveness probe
kubectl apply -f manifests/05-liveness-probe.yaml

# Watch the pods
kubectl get pods -w

# Describe the pod to see probe configuration
kubectl describe pod <pod-name>

# Check events to see if probes are working
kubectl get events --sort-by='.lastTimestamp' | grep -i liveness
```

The liveness probe checks if the application is healthy. If it fails, Kubernetes restarts the container.

### Exercise 10: Health Checks - Readiness Probes

```bash
# Deploy an app with readiness probe
kubectl apply -f manifests/06-readiness-probe.yaml

# Watch the pods
kubectl get pods

# Notice the READY column: 0/1 until readiness probe succeeds
# Then: 1/1 when the app is ready to serve traffic
```

### Exercise 11: Combined Liveness and Readiness Probes

```bash
# Deploy an app with both probes
kubectl apply -f manifests/07-combined-probes.yaml

# Check pod status
kubectl get pods

# Describe to see both probes
kubectl describe pod <pod-name> | grep -A 5 "Liveness\|Readiness"

# Watch events
kubectl get events --sort-by='.lastTimestamp'
```

**DBA Tip:**
- Liveness = "Is SQL Server service running?"
- Readiness = "Has SQL Server completed database recovery?"

### Exercise 12: Resource Requests and Limits

```bash
# Apply deployment with resource constraints
kubectl apply -f manifests/08-resource-limits.yaml

# Check the pod's resource allocation
kubectl describe pod <pod-name> | grep -A 10 "Requests:\|Limits:"

# View resource usage (requires metrics-server)
kubectl top pods
```

**DBA Analogy:** Like setting max server memory and min server memory in SQL Server.

## Practice Challenges

Try these on your own:

1. **Challenge 1:** Create a deployment for PostgreSQL
   - Image: `postgres:15`
   - Replicas: 1 (databases need special handling for multiple replicas)
   - Environment variable: `POSTGRES_PASSWORD=mysecretpassword`
   - Resource requests: 256Mi memory, 250m CPU
   - Resource limits: 512Mi memory, 500m CPU

2. **Challenge 2:** Add a liveness probe to the PostgreSQL deployment
   - Use `exec` probe type
   - Command: `pg_isready -U postgres`
   - Initial delay: 30 seconds
   - Period: 10 seconds

3. **Challenge 3:** Scale the PostgreSQL deployment to 0 replicas (pause), then back to 1

4. **Challenge 4:** Simulate a rolling update by changing the PostgreSQL image from `postgres:15` to `postgres:15.3`

**Solutions in `exercises/solutions.md`**

## Cleanup

```bash
# Delete specific deployments
kubectl delete deployment nginx-deploy web-app versioned-app

# Delete all deployments
kubectl delete deployments --all

# Or use the cleanup script
./scripts/cleanup.sh
```

## Key Takeaways

✅ Always use Deployments (not bare Pods) for stateless applications
✅ ReplicaSets are managed automatically by Deployments
✅ Scaling is simple: change `replicas` field
✅ Rolling updates provide zero-downtime deployments
✅ Rollbacks are instant and safe
✅ Health probes ensure application reliability
✅ Resource limits prevent resource starvation

## Common Patterns for DBAs

### Pattern 1: Read Replicas
For read-heavy workloads, you could scale read-only replicas:
```yaml
# Primary database: 1 replica (write)
# Read replicas: Multiple replicas (read-only)
```
We'll explore this in Module 5 with StatefulSets.

### Pattern 2: Blue-Green Deployments
Run two versions side-by-side, switch traffic:
```bash
# Deploy v1 (blue)
kubectl apply -f app-v1.yaml

# Deploy v2 (green)
kubectl apply -f app-v2.yaml

# Switch traffic by updating service selector
# We'll cover this in Module 3
```

### Pattern 3: Canary Deployments
Gradually roll out to a subset of users:
```bash
# 90% on v1, 10% on v2
# Increase v2 gradually if metrics look good
```

## Next Steps

You now understand how to manage application lifecycle with Deployments. Next, you'll learn how to expose these applications to network traffic with **Services**.

**Continue to:** [Module 3: Services and Networking](../module-03-services/README.md)

## Reference Commands

```bash
# Deployment management
kubectl create deployment <name> --image=<image>
kubectl apply -f deployment.yaml
kubectl get deployments
kubectl describe deployment <name>
kubectl delete deployment <name>

# Scaling
kubectl scale deployment <name> --replicas=<count>

# Updates and rollbacks
kubectl set image deployment/<name> <container>=<new-image>
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>
kubectl rollout undo deployment/<name>
kubectl rollout undo deployment/<name> --to-revision=<n>

# ReplicaSets
kubectl get replicasets
kubectl describe rs <name>

# Debugging
kubectl logs deployment/<name>
kubectl describe deployment <name>
kubectl get events
```

## Additional Resources

- [Deployments Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [ReplicaSet Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
- [Configure Liveness, Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
