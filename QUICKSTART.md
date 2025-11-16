# Kubernetes Tutorial - Quick Start Guide

## Get Up and Running in 10 Minutes

This guide will help you verify your environment and run your first Kubernetes workload.

## Prerequisites Check

### 1. Verify Docker Desktop with Kubernetes

```bash
# Check Docker is running
docker version

# Check Kubernetes is enabled
kubectl version --client

# Check cluster is accessible
kubectl cluster-info

# Check nodes are ready
kubectl get nodes
```

**Expected output:**
```
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   5d    v1.28.x
```

If Kubernetes is not enabled:
1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"
5. Wait 2-3 minutes for cluster to start

### 2. Verify kubectl

```bash
# Check kubectl version
kubectl version --short

# Set up bash completion (optional, macOS)
echo 'alias k=kubectl' >> ~/.zshrc
echo 'complete -F __start_kubectl k' >> ~/.zshrc
source ~/.zshrc
```

### 3. Install Helm (for later modules)

```bash
# macOS
brew install helm

# Verify
helm version
```

## Your First Kubernetes Deployment (5 Minutes)

### Step 1: Create a Namespace

```bash
# Create dedicated namespace for learning
kubectl create namespace k8s-tutorial

# Set as default
kubectl config set-context --current --namespace=k8s-tutorial

# Verify
kubectl config view --minify | grep namespace:
```

### Step 2: Deploy Your First Application

```bash
# Create a simple nginx deployment
kubectl create deployment hello-k8s --image=nginx:latest --replicas=3

# Watch it deploy
kubectl get pods -w
# (Press Ctrl+C when all pods are Running)
```

### Step 3: Explore What You Created

```bash
# View the deployment
kubectl get deployments

# View the pods
kubectl get pods

# View the replica set (created automatically)
kubectl get replicasets

# See everything
kubectl get all
```

**You should see:**
- 1 Deployment
- 1 ReplicaSet
- 3 Pods (all Running)

### Step 4: Expose Your Application

```bash
# Create a service to expose the deployment
kubectl expose deployment hello-k8s --type=NodePort --port=80

# Get the service details
kubectl get service hello-k8s

# Get the NodePort
kubectl get service hello-k8s -o jsonpath='{.spec.ports[0].nodePort}'
```

### Step 5: Access Your Application

```bash
# Get the NodePort (will be something like 30000-32767)
NODE_PORT=$(kubectl get service hello-k8s -o jsonpath='{.spec.ports[0].nodePort}')

# Open in browser or use curl
echo "Access your app at: http://localhost:$NODE_PORT"
curl http://localhost:$NODE_PORT
```

You should see the nginx welcome page!

### Step 6: Scale Your Application

```bash
# Scale to 5 replicas
kubectl scale deployment hello-k8s --replicas=5

# Watch the new pods being created
kubectl get pods -w
# (Press Ctrl+C when done)

# Scale back down
kubectl scale deployment hello-k8s --replicas=2
```

### Step 7: Clean Up

```bash
# Delete everything we created
kubectl delete deployment hello-k8s
kubectl delete service hello-k8s

# Verify it's gone
kubectl get all
```

## Congratulations! 🎉

You just:
- ✅ Created a Deployment
- ✅ Scaled an application
- ✅ Exposed it via a Service
- ✅ Accessed it from your browser
- ✅ Cleaned up resources

## What Just Happened? (DBA Perspective)

| Action | Kubernetes | SQL Server Analogy |
|--------|-----------|-------------------|
| Deployment | Application definition | Database creation script |
| Pods | Running instances | SQL Server instances |
| ReplicaSet | Ensures desired count | Availability Group |
| Service | Network endpoint | SQL listener/endpoint |
| Scaling | Add/remove pods | Add/remove replicas |

## Next Steps

### Option 1: Start the Tutorial (Recommended)
```bash
cd /Users/riteshchawla/RC/playground/kubernetes
cat README.md

# Begin Module 1
cd module-01-basics
cat README.md
```

### Option 2: Deploy a Database (Jump Ahead)

**PostgreSQL:**
```bash
# Create namespace
kubectl create namespace databases

# Deploy PostgreSQL
kubectl create deployment postgres \
  --image=postgres:15 \
  --namespace=databases

# Set password
kubectl set env deployment/postgres \
  POSTGRES_PASSWORD=mysecretpassword \
  --namespace=databases

# Wait for ready
kubectl wait --for=condition=available \
  deployment/postgres \
  --namespace=databases \
  --timeout=60s

# Connect
kubectl exec -it deployment/postgres -n databases -- \
  psql -U postgres -c "SELECT version();"
```

**SQL Server:**
```bash
# Create namespace
kubectl create namespace databases

# Create secret for SA password
kubectl create secret generic mssql-secret \
  --from-literal=SA_PASSWORD='YourStrong!Passw0rd' \
  --namespace=databases

# Deploy SQL Server
kubectl create deployment mssql \
  --image=mcr.microsoft.com/mssql/server:2022-latest \
  --namespace=databases

# Configure SQL Server
kubectl set env deployment/mssql \
  ACCEPT_EULA=Y \
  MSSQL_SA_PASSWORD='YourStrong!Passw0rd' \
  --namespace=databases

# Set resource limits (SQL Server needs 2Gi minimum)
kubectl set resources deployment/mssql \
  --requests=memory=2Gi,cpu=1 \
  --limits=memory=4Gi,cpu=2 \
  --namespace=databases

# Wait for ready (takes 30-60 seconds)
kubectl wait --for=condition=available \
  deployment/mssql \
  --namespace=databases \
  --timeout=120s

# Connect
kubectl exec -it deployment/mssql -n databases -- \
  /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P 'YourStrong!Passw0rd' \
  -Q "SELECT @@VERSION"
```

### Option 3: Explore on Your Own

```bash
# List all resources
kubectl get all --all-namespaces

# Get help on any command
kubectl help
kubectl get --help
kubectl create --help

# Explore different resource types
kubectl api-resources

# View cluster info
kubectl cluster-info
kubectl get nodes -o wide
kubectl top nodes  # (requires metrics-server)
```

## Common Commands Cheat Sheet

```bash
# Viewing resources
kubectl get pods                    # List pods
kubectl get deployments             # List deployments
kubectl get services                # List services
kubectl get all                     # List common resources
kubectl get all --all-namespaces    # List everything cluster-wide

# Detailed information
kubectl describe pod <pod-name>     # Detailed pod info
kubectl logs <pod-name>             # View logs
kubectl logs -f <pod-name>          # Stream logs

# Interacting with pods
kubectl exec -it <pod-name> -- bash # Shell into pod
kubectl port-forward <pod-name> 8080:80  # Forward port

# Creating resources
kubectl create deployment ...       # Create deployment
kubectl expose deployment ...       # Create service
kubectl apply -f <file.yaml>        # Create from YAML

# Updating resources
kubectl scale deployment ...        # Scale replicas
kubectl set image deployment ...    # Update image
kubectl edit deployment ...         # Edit in place

# Deleting resources
kubectl delete pod <pod-name>       # Delete pod
kubectl delete deployment <name>    # Delete deployment
kubectl delete -f <file.yaml>       # Delete from YAML

# Namespaces
kubectl get namespaces              # List all namespaces (or: kubectl get ns)
kubectl get namespaces -o wide      # List with more details
kubectl describe namespace <name>   # Detailed namespace info
kubectl create namespace <name>     # Create namespace
kubectl get pods -n <namespace>     # View in namespace
kubectl config set-context --current --namespace=<name>  # Set default

# Help
kubectl --help                      # General help
kubectl <command> --help            # Command help
kubectl explain <resource>          # Resource documentation
```

## Troubleshooting

### Pods Not Starting?
```bash
# Check pod status
kubectl get pods

# Get detailed information
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'

# View logs
kubectl logs <pod-name>
```

### Common Issues

**Issue: ImagePullBackOff**
```bash
# Cause: Can't download container image
# Solution: Check image name and internet connection
kubectl describe pod <pod-name> | grep -A 5 "Events:"
```

**Issue: CrashLoopBackOff**
```bash
# Cause: Container keeps crashing
# Solution: Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Previous crash logs
```

**Issue: Pending**
```bash
# Cause: Not enough resources or scheduling issues
# Solution: Check events
kubectl describe pod <pod-name>
```

**Issue: Can't connect to cluster**
```bash
# Restart Docker Desktop
# Or reset Kubernetes: Docker Desktop → Settings → Kubernetes → Reset
```

### Reset Everything

```bash
# Delete all resources in namespace
kubectl delete namespace k8s-tutorial

# Or reset entire Kubernetes cluster
# Docker Desktop → Settings → Kubernetes → Reset Kubernetes Cluster
```

## Environment Setup for DBAs

### Useful Aliases (add to ~/.zshrc or ~/.bashrc)

```bash
# Kubectl shortcuts
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias ke='kubectl exec -it'

# Namespace shortcuts
alias kn='kubectl config set-context --current --namespace'

# Watch resources
alias kw='kubectl get pods -w'
```

### Kubectl Context and Config

```bash
# View current context
kubectl config current-context

# View all contexts
kubectl config get-contexts

# Switch context (if you have multiple clusters)
kubectl config use-context docker-desktop

# View config
kubectl config view
```

## Ready to Learn?

Now that you've verified everything works, you're ready for the full tutorial:

```bash
cd /Users/riteshchawla/RC/playground/kubernetes
cat TUTORIAL_INDEX.md
cd module-01-basics
cat README.md
```

## Quick Reference Card

Print or save this for easy reference:

```
Kubernetes Resource Hierarchy:
├── Namespace (logical isolation)
    ├── Deployment (desired state)
    │   └── ReplicaSet (ensures replicas)
    │       └── Pod (running container)
    └── Service (network endpoint)
        └── Endpoints (pod IPs)

DBA Translation:
Namespace     = Database/Schema
Deployment    = AG Configuration
ReplicaSet    = Replica Set
Pod           = SQL Instance
Service       = Listener/Endpoint
ConfigMap     = Config File
Secret        = Encrypted Credential
PVC           = Disk Volume
```

---

**Questions?** Start with [Module 1: Kubernetes Basics](./module-01-basics/README.md)

**Need help?** Check the [Main README](./README.md) for more resources

**Happy Learning!** 🚀
