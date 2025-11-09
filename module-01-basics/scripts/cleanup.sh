#!/bin/bash

# Module 1 Cleanup Script
# Removes all resources created in this module

echo "🧹 Cleaning up Module 1 resources..."

# Delete pods in default namespace
echo "Deleting pods in default namespace..."
kubectl delete pod nginx-pod --ignore-not-found=true
kubectl delete pod simple-web-app --ignore-not-found=true
kubectl delete pod multi-container-app --ignore-not-found=true
kubectl delete pod postgres-pod --ignore-not-found=true

# Delete development namespace (if exists)
echo "Deleting development namespace..."
kubectl delete namespace development --ignore-not-found=true

# Delete databases namespace (if exists from challenges)
echo "Deleting databases namespace..."
kubectl delete namespace databases --ignore-not-found=true

echo "✅ Cleanup complete!"
echo ""
echo "To verify, run: kubectl get pods --all-namespaces"
