#!/usr/bin/env bash
set -e

echo "=============================="
echo " PRIVATEVAULT ENTERPRISE TEST "
echo "=============================="

ROOT=$(cd .. && pwd)

################################
# 1. CLUSTER CHECK
################################
echo "[1/6] Checking Kubernetes..."

kubectl cluster-info >/dev/null 2>&1 || {
  echo "❌ Kubernetes not running"
  exit 1
}

################################
# 2. DEPLOY
################################
echo "[2/6] Deploying PrivateVault..."

cd $ROOT
./scripts/install.sh

################################
# 3. WAIT FOR PODS
################################
echo "[3/6] Waiting for pods..."

kubectl wait \
  --for=condition=ready pod \
  --all \
  -n pv-pilot \
  --timeout=180s

################################
# 4. RUNTIME TEST
################################
echo "[4/6] Running agent demo..."

./scripts/run-demo.sh

################################
# 5. VERIFY EVIDENCE
################################
echo "[5/6] Verifying receipts..."

RECEIPT=$(ls /tmp/pv-receipts/*.json | head -n1)

if [ ! -f "$RECEIPT" ]; then
  echo "❌ No receipt found"
  exit 1
fi

./scripts/verify-evidence.sh "$RECEIPT"

################################
# 6. TAMPER TEST
################################
echo "[6/6] Testing tamper detection..."

cp "$RECEIPT" /tmp/tampered.json
sed -i 's/agent/test-agent/' /tmp/tampered.json

if ./scripts/verify-evidence.sh /tmp/tampered.json; then
  echo "❌ Tamper NOT detected"
  exit 1
else
  echo "✅ Tamper detected"
fi

################################
echo ""
echo "🎉 ALL TESTS PASSED"
echo "READY FOR DEMO"
################################
