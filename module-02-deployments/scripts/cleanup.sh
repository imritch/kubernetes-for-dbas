#!/bin/bash

# Module 2 Cleanup Script

echo "🧹 Cleaning up Module 2 resources..."

# Delete all deployments created in this module
kubectl delete deployment nginx-deploy --ignore-not-found=true
kubectl delete deployment web-app --ignore-not-found=true
kubectl delete deployment versioned-app --ignore-not-found=true
kubectl delete deployment recreate-app --ignore-not-found=true
kubectl delete deployment rolling-app --ignore-not-found=true
kubectl delete deployment liveness-app --ignore-not-found=true
kubectl delete deployment readiness-app --ignore-not-found=true
kubectl delete deployment healthy-app --ignore-not-found=true
kubectl delete deployment resource-managed-app --ignore-not-found=true
kubectl delete deployment guaranteed-qos-app --ignore-not-found=true
kubectl delete deployment postgres-deploy --ignore-not-found=true

echo "✅ Cleanup complete!"
echo ""
echo "To verify, run: kubectl get deployments"
