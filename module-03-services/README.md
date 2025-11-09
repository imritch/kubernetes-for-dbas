# Module 3: Services and Networking

## Overview
Learn how to expose your applications and enable network communication in Kubernetes.

**Duration:** 60 minutes

## Learning Objectives
- Understand Kubernetes Services and service discovery
- Work with different Service types (ClusterIP, NodePort, LoadBalancer)
- Configure DNS-based service discovery
- Understand Ingress for HTTP routing
- Implement network communication between pods

## Core Concepts

### Services
A Service provides stable networking for ephemeral pods.

**DBA Analogy:** Like a SQL Server listener in an Availability Group - provides a stable endpoint even when replicas change.

**Service Types:**
- **ClusterIP** (default): Internal cluster access only
- **NodePort**: Exposes service on each node's IP at a static port
- **LoadBalancer**: Creates external load balancer (cloud providers)
- **ExternalName**: Maps service to DNS name

### DNS Service Discovery
Every Service gets a DNS name: `<service-name>.<namespace>.svc.cluster.local`

**DBA Analogy:** Like SQL Server network aliases - applications use the DNS name, not the pod IP.

## Hands-On Exercises

### Exercise 1: ClusterIP Service (Internal Access)
```bash
# Deploy an app
kubectl apply -f manifests/01-deployment-with-service.yaml

# Access the service from another pod
kubectl run test-pod --rm -it --image=busybox -- wget -qO- http://web-service:80
```

### Exercise 2: NodePort Service (External Access)
```bash
# Apply NodePort service
kubectl apply -f manifests/02-nodeport-service.yaml

# Access via browser
# http://localhost:<node-port>
```

### Exercise 3: Service Discovery with DNS
```bash
# Create multiple services
kubectl apply -f manifests/03-multi-tier-app.yaml

# Test DNS resolution
kubectl run dns-test --rm -it --image=busybox -- nslookup web-service
```

### Exercise 4: Headless Service (StatefulSets)
```bash
# Deploy headless service
kubectl apply -f manifests/04-headless-service.yaml

# Each pod gets its own DNS entry
# pod-0.service-name.namespace.svc.cluster.local
```

### Exercise 5: Ingress Controller
```bash
# Enable ingress on Docker Desktop
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# Deploy ingress
kubectl apply -f manifests/05-ingress.yaml

# Access via http://localhost/
```

## Practice Challenges

1. **Challenge 1:** Create a Deployment with 3 replicas and expose it via ClusterIP service
2. **Challenge 2:** Create a multi-tier app (frontend → backend → database) with proper service networking
3. **Challenge 3:** Expose an application using NodePort and access it from your browser
4. **Challenge 4:** Configure an Ingress to route traffic based on path (/api → backend, /web → frontend)

**Solutions in `exercises/solutions.md`**

## Key Manifest Files (to be created)

- `01-deployment-with-service.yaml` - Basic service example
- `02-nodeport-service.yaml` - External access
- `03-multi-tier-app.yaml` - Frontend, backend, database
- `04-headless-service.yaml` - For StatefulSets
- `05-ingress.yaml` - HTTP routing

## Key Takeaways

✅ Services provide stable networking for pods
✅ ClusterIP for internal communication
✅ NodePort for simple external access
✅ DNS-based service discovery is automatic
✅ Ingress provides HTTP/HTTPS routing and SSL termination

## DBA Patterns

### Pattern: Database Connection Strings
```yaml
# Application connects to: postgres-service:5432
# Not to individual pod IPs (which change)
```

### Pattern: Read Replicas
```yaml
# write-service → primary database
# read-service → read replicas (load balanced)
```

## Next Steps
**Continue to:** [Module 4: ConfigMaps and Secrets](../module-04-configmaps-secrets/README.md)

---
*Note: This is a simplified outline. Full tutorial content will be expanded when you're ready to work on this module.*
