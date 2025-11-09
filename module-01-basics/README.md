# Module 1: Kubernetes Basics

## Overview

In this module, you'll learn the fundamental building blocks of Kubernetes by deploying your first containerized application. Think of this as understanding the basic SQL Server components before managing complex Always On configurations.

**Learning Objectives:**
- Understand Pods (the atomic unit in Kubernetes)
- Work with Namespaces for resource isolation
- Use Labels and Selectors for organization
- Compare imperative vs declarative approaches
- Inspect and debug running containers

**Duration:** 30-45 minutes

## Core Concepts

### Pods
A **Pod** is the smallest deployable unit in Kubernetes. Think of it like a SQL Server instance - it's the basic runtime environment for your application.

**Key characteristics:**
- Can contain one or more containers (usually one)
- Containers in a pod share network and storage
- Pods are ephemeral (can be destroyed and recreated)
- Each pod gets its own IP address

**DBA Analogy:** Pod = SQL Server Instance, Container = SQL Server process

### Namespaces
**Namespaces** provide logical isolation within a cluster, similar to SQL Server schemas or databases separating objects.

**Common uses:**
- Environment separation (dev, staging, prod)
- Team/project isolation
- Resource quota enforcement

### Labels and Selectors
**Labels** are key-value pairs attached to resources for organization and selection.

**DBA Analogy:** Labels are like SQL Server Extended Properties - metadata for organization and filtering.

## Hands-On Exercises

### Exercise 1: Exploring Your Cluster

Let's start by understanding what's already running:

```bash
# View all namespaces
kubectl get namespaces

# View system pods (Docker Desktop's infrastructure)
kubectl get pods -n kube-system

# Get detailed information about a node
kubectl get nodes -o wide

# Describe your node to see capacity and conditions
kubectl describe node docker-desktop
```

**What you're seeing:** Similar to querying `sys.dm_os_sys_info` to understand your SQL Server environment.

### Exercise 2: Create Your First Pod (Imperative Way)

Let's deploy a simple nginx web server:

```bash
# Create a pod imperatively (quick, but not recommended for production)
kubectl run nginx-pod --image=nginx:latest

# Check if it's running
kubectl get pods

# Watch the pod status in real-time
kubectl get pods -w
# (Press Ctrl+C to exit)

# Get detailed information
kubectl describe pod nginx-pod

# View pod logs
kubectl logs nginx-pod

# Execute a command inside the pod
kubectl exec -it nginx-pod -- /bin/bash
# Inside the container, try:
#   nginx -v
#   cat /etc/nginx/nginx.conf
#   exit
```

**DBA Parallel:** This is like using `sqlcmd` to quickly create a database - fast but not reproducible.

### Exercise 3: Create a Pod Declaratively

Now the proper way - using YAML manifests:

```bash
# Apply the manifest
kubectl apply -f manifests/01-simple-pod.yaml

# Verify it's running
kubectl get pod simple-web-app

# Compare with the imperative pod
kubectl get pods
```

**DBA Parallel:** This is like using a T-SQL script in source control - reproducible and auditable.

### Exercise 4: Working with Labels

Labels are crucial for organizing and selecting resources:

```bash
# View pods with labels
kubectl get pods --show-labels

# Filter pods by label
kubectl get pods -l app=web

# Add a label to an existing pod
kubectl label pod nginx-pod environment=learning

# Update a label
kubectl label pod nginx-pod environment=development --overwrite

# Remove a label
kubectl label pod nginx-pod environment-

# View pods with specific columns
kubectl get pods -L app,tier,environment
```

### Exercise 5: Working with Namespaces

Namespaces provide isolation:

```bash
# Create a new namespace
kubectl create namespace development

# Apply a pod to a specific namespace
kubectl apply -f manifests/02-namespaced-pod.yaml -n development

# List pods in a specific namespace
kubectl get pods -n development

# List pods across all namespaces
kubectl get pods --all-namespaces
# or shorthand:
kubectl get pods -A

# Set default namespace for current context
kubectl config set-context --current --namespace=development

# Verify
kubectl config view --minify | grep namespace:
```

### Exercise 6: Inspecting and Debugging

Essential troubleshooting commands:

```bash
# Get pod details in YAML format
kubectl get pod simple-web-app -o yaml

# Get pod details in JSON format
kubectl get pod simple-web-app -o json

# Get specific field using JSONPath
kubectl get pod simple-web-app -o jsonpath='{.status.podIP}'

# View events (like SQL Server error log)
kubectl get events --sort-by='.lastTimestamp'

# Stream logs (like tail -f)
kubectl logs -f simple-web-app

# Get logs from a crashed pod
kubectl logs simple-web-app --previous
```

### Exercise 7: Multi-Container Pod

Deploy a pod with multiple containers (sidecar pattern):

```bash
# Apply the multi-container pod
kubectl apply -f manifests/03-multi-container-pod.yaml

# Check both containers are running
kubectl get pod multi-container-app

# View logs from a specific container
kubectl logs multi-container-app -c web-app
kubectl logs multi-container-app -c sidecar

# Execute into a specific container
kubectl exec -it multi-container-app -c web-app -- /bin/sh
```

**DBA Analogy:** This is like running multiple services on one SQL Server instance (DB Engine + SSRS + SSAS).

## Practice Challenges

Try these exercises on your own:

1. **Challenge 1:** Create a pod running PostgreSQL
   - Use image: `postgres:15`
   - Set environment variable: `POSTGRES_PASSWORD=mysecretpassword`
   - Name it: `postgres-pod`

2. **Challenge 2:** Create a namespace called `databases` and deploy the PostgreSQL pod there

3. **Challenge 3:** Add labels to your PostgreSQL pod:
   - `app=postgres`
   - `tier=database`
   - `environment=dev`

4. **Challenge 4:** Use `kubectl exec` to connect to PostgreSQL and run a query:
   ```bash
   kubectl exec -it postgres-pod -- psql -U postgres -c "SELECT version();"
   ```

**Solutions are in `exercises/solutions.md`**

## Cleanup

Remove resources created in this module:

```bash
# Delete specific pods
kubectl delete pod nginx-pod simple-web-app

# Delete using manifest file
kubectl delete -f manifests/01-simple-pod.yaml

# Delete all pods in current namespace
kubectl delete pods --all

# Delete namespace (and everything in it)
kubectl delete namespace development

# Or run the cleanup script
./scripts/cleanup.sh
```

## Key Takeaways

✅ Pods are the fundamental unit in Kubernetes
✅ Namespaces provide logical isolation
✅ Labels enable flexible resource organization
✅ Declarative (YAML) approach is preferred over imperative commands
✅ `kubectl describe`, `logs`, and `exec` are your debugging friends

## Common Pitfalls for DBAs

| ❌ Don't | ✅ Do |
|---------|------|
| Store data in pods directly | Use Persistent Volumes (Module 5) |
| Use imperative commands in production | Use YAML manifests in version control |
| Run pods directly | Use Deployments (Module 2) |
| Hardcode passwords | Use Secrets (Module 4) |

## Next Steps

Now that you understand pods and basic Kubernetes concepts, you're ready to learn about **Deployments and ReplicaSets** in Module 2, where you'll discover how to:
- Scale applications automatically
- Perform rolling updates
- Ensure high availability

**Continue to:** [Module 2: Deployments and ReplicaSets](../module-02-deployments/README.md)

## Reference Commands

```bash
# Essential kubectl commands for this module
kubectl get pods                          # List pods
kubectl get pods -o wide                 # List with more details
kubectl describe pod <name>               # Detailed pod information
kubectl logs <pod-name>                  # View pod logs
kubectl exec -it <pod> -- <command>      # Execute command in pod
kubectl delete pod <name>                 # Delete a pod
kubectl apply -f <file.yaml>             # Create/update from YAML
kubectl get pods --show-labels           # Show labels
kubectl get pods -l <label>=<value>      # Filter by label
```

## Additional Resources

- [Kubernetes Pod Documentation](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Kubectl Command Reference](https://kubernetes.io/docs/reference/kubectl/)
- [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
