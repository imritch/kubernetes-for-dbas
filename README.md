# Kubernetes for SQL Server DBAs: A Hands-On Tutorial

Welcome! This tutorial is designed specifically for experienced SQL Server DBAs who want to master Kubernetes through practical, progressive exercises.

## 🎯 Learning Objectives

By the end of this tutorial, you will:
- Understand core Kubernetes concepts and architecture
- Deploy and manage stateless and stateful applications
- Run production-grade databases (PostgreSQL & SQL Server) in Kubernetes
- Implement service discovery, load balancing, and networking
- Manage configuration and secrets securely
- Use Helm for package management
- Implement monitoring and observability
- Apply security best practices with RBAC
- Work with Operators for automated database management

## 📋 Prerequisites

### Software Requirements
- **Docker Desktop** with Kubernetes enabled ([Installation Guide](https://docs.docker.com/desktop/kubernetes/))
- **kubectl** CLI tool (comes with Docker Desktop)
- **Helm** v3+ ([Installation Guide](https://helm.sh/docs/intro/install/))
- **Git** for cloning repositories
- A code editor (VS Code recommended)

### Knowledge Prerequisites
- Basic understanding of containers and Docker
- Familiarity with YAML syntax
- Command-line proficiency
- SQL and database concepts (you've got this covered!)

### Verify Your Setup
```bash
# Check Docker is running
docker version

# Check Kubernetes is enabled and running
kubectl version --client
kubectl cluster-info

# Check Helm is installed
helm version

# Verify you can access the cluster
kubectl get nodes
```

You should see your Docker Desktop node in a `Ready` state.

## 🗺️ Tutorial Structure

This tutorial is organized into 10 progressive modules, each building on previous concepts:

### **Module 1: Kubernetes Basics**
- Understanding Pods, Namespaces, and Labels
- Your first deployment: A simple web application
- Imperative vs Declarative management
- **Duration:** 30-45 minutes

### **Module 2: Deployments and ReplicaSets**
- Scaling applications horizontally
- Rolling updates and rollbacks
- Health checks (liveness and readiness probes)
- **Duration:** 45-60 minutes

### **Module 3: Services and Networking**
- Service types: ClusterIP, NodePort, LoadBalancer
- Service discovery and DNS
- Ingress controllers
- **Duration:** 60 minutes

### **Module 4: ConfigMaps and Secrets**
- Externalizing configuration
- Managing sensitive data
- Environment variables vs volume mounts
- **Duration:** 45 minutes

### **Module 5: Persistent Volumes and StatefulSets**
- Understanding storage in Kubernetes
- Deploying PostgreSQL with persistent storage
- StatefulSets vs Deployments
- **Duration:** 90 minutes

### **Module 6: Advanced Stateful Workloads**
- Running SQL Server on Kubernetes
- Backup and restore strategies
- High availability considerations
- **Duration:** 90 minutes

### **Module 7: Helm Charts**
- Helm fundamentals
- Creating custom charts
- Managing releases
- **Duration:** 60 minutes

### **Module 8: Monitoring and Observability**
- Prometheus for metrics collection
- Grafana for visualization
- Logging with Loki or EFK stack
- **Duration:** 90 minutes

### **Module 9: Security and RBAC**
- Role-Based Access Control
- Service Accounts
- Network Policies
- Secrets management best practices
- **Duration:** 60 minutes

### **Module 10: Operators and Custom Resources**
- Understanding Operators
- Using database operators (Postgres, SQL Server)
- Custom Resource Definitions (CRDs)
- **Duration:** 90 minutes

## 🚀 Getting Started

### Quick Start (10 Minutes)
New to Kubernetes? Start here: **[QUICKSTART.md](./QUICKSTART.md)**

This will help you:
- Verify your environment is ready
- Deploy your first application
- Understand basic commands
- Get comfortable with kubectl

### Set Up Your Environment
```bash
# Navigate to tutorial directory
cd /Users/riteshchawla/RC/playground/kubernetes

# Create a dedicated namespace for the tutorial
kubectl create namespace k8s-tutorial

# Set it as your default context
kubectl config set-context --current --namespace=k8s-tutorial

# Verify the namespace
kubectl config view --minify | grep namespace:
```

### Tutorial Navigation

**📘 Files to Know:**
- **[QUICKSTART.md](./QUICKSTART.md)** - Get started in 10 minutes
- **[TUTORIAL_INDEX.md](./TUTORIAL_INDEX.md)** - Module overview and navigation guide
- **[README.md](./README.md)** - This file (full tutorial overview)

Each module is in its own directory with:
- `README.md` - Step-by-step instructions and explanations
- `manifests/` - Kubernetes YAML files
- `scripts/` - Helper scripts for setup and cleanup
- `exercises/` - Practice challenges

Start with Module 1:
```bash
cd module-01-basics
cat README.md
```

## 📚 Additional Resources

- [Official Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Docker Desktop Kubernetes Guide](https://docs.docker.com/desktop/kubernetes/)
- [Kubernetes Patterns Book](https://k8spatterns.io/)

## 💡 Tips for SQL Server DBAs

As you go through this tutorial, you'll notice parallels to SQL Server concepts:

| SQL Server Concept | Kubernetes Equivalent |
|-------------------|----------------------|
| SQL Server Instance | Pod |
| Availability Group | StatefulSet with replicas |
| Logins & Roles | Service Accounts & RBAC |
| Linked Servers | Services & DNS |
| Extended Events | Prometheus metrics |
| SQL Agent Jobs | CronJobs |
| Always On | Operators with HA |

## 🆘 Troubleshooting

If you encounter issues:

```bash
# Check pod status
kubectl get pods

# View pod logs
kubectl logs <pod-name>

# Describe a resource for detailed info
kubectl describe pod <pod-name>

# Get events
kubectl get events --sort-by='.lastTimestamp'

# Clean up and start fresh
kubectl delete namespace k8s-tutorial
kubectl create namespace k8s-tutorial
```

## 📝 Notes

- Each module is self-contained and can be completed independently
- Estimated total time: 12-15 hours spread across multiple sessions
- All examples use Docker Desktop Kubernetes (single-node cluster)
- Some advanced features may require additional setup

---

**Ready to begin?** Head to [Module 1: Kubernetes Basics](./module-01-basics/README.md)

Happy learning! 🚢☸️
