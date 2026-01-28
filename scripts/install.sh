#!/bin/bash
set -e

echo "Deploying PrivateVault Enterprise Pilot..."

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml

echo "Waiting for pods..."
kubectl wait --for=condition=ready pod \
  -l app=privatevault \
  -n pv-pilot \
  --timeout=180s

echo "Deployment successful."
kubectl get pods -n pv-pilot
