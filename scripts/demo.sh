#!/bin/bash
set -e

echo "=== PrivateVault Enterprise Demo ==="

echo "Deploying system..."
./scripts/install.sh

echo "Running demo workflow..."
sleep 10

echo "Fetching receipt..."
POD=$(kubectl get pods -n pv-pilot -l app=privatevault -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n pv-pilot $POD -- cat /app/receipt.json > demo-receipt.json

echo "Verifying receipt..."
./scripts/verify-evidence.sh demo-receipt.json

echo "Tamper test..."
sed -i 's/outputs-demo-hash/hacked/' demo-receipt.json || true

echo "Re-verifying (should fail)..."
./scripts/verify-evidence.sh demo-receipt.json || echo "Tampering detected"

echo "Demo complete."
