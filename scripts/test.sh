#!/usr/bin/env bash
set -e

<<<<<<< HEAD
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
=======
NS=pv-pilot

echo "Waiting for pod..."

POD=$(
kubectl get pods -n $NS \
-l app=privatevault \
-o jsonpath='{.items[0].metadata.name}'
)

kubectl wait \
--for=condition=Ready pod/$POD \
-n $NS \
--timeout=120s

echo "Running pytest in $POD"

kubectl exec -it $POD -n $NS -- pytest
>>>>>>> a069eaf (Stabilize runtime: clean deps, fixed typing, stable deployment)
