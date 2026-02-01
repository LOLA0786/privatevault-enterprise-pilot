#!/usr/bin/env bash
set -e

NAMESPACE="pv-pilot"
APP_LABEL="app=privatevault"

echo "Waiting for pod..."

kubectl wait --for=condition=ready pod \
  -l $APP_LABEL \
  -n $NAMESPACE \
  --timeout=180s

# Always get fresh running pod
POD=$(kubectl get pod -n $NAMESPACE \
  -l $APP_LABEL \
  --field-selector=status.phase=Running \
  -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD" ]; then
  echo "❌ No running privatevault pod found"
  exit 1
fi

echo "Running pytest in $POD"

kubectl exec -it "$POD" -n $NAMESPACE -- pytest -q
