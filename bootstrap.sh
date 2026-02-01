#!/usr/bin/env bash
set -e

echo "======================================"
echo " PrivateVault Demo Bootstrap"
echo "======================================"

# Check deps
for cmd in docker kind kubectl git; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "❌ Missing dependency: $cmd"
    exit 1
  fi
done

echo "✅ Dependencies OK"

CLUSTER=pv-demo
NAMESPACE=pv-pilot
IMAGE=privatevault:demo

# Delete old cluster
if kind get clusters | grep -q "$CLUSTER"; then
  echo "🧹 Deleting old cluster..."
  kind delete cluster --name $CLUSTER
fi

# Create cluster
echo "🚀 Creating kind cluster..."
kind create cluster --name $CLUSTER

kubectl config use-context kind-$CLUSTER

# Build image
echo "🐳 Building Docker image..."
docker buildx build \
  -t privatevault:demo \
  -f runtime/Dockerfile \
  runtime \
  --load


# Load image
echo "📦 Loading image into kind..."
kind load docker-image $IMAGE --name $CLUSTER

# Namespace
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy
echo "📡 Deploying..."
./scripts/install.sh

# Patch pull policy
kubectl patch deployment privatevault -n $NAMESPACE \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"privatevault","imagePullPolicy":"Never"}]}}}}'

# Restart
kubectl rollout restart deployment privatevault -n $NAMESPACE

# Wait
echo "⏳ Waiting for rollout..."
kubectl rollout status deployment/privatevault -n $NAMESPACE

# Test
echo "🧪 Running tests..."
./scripts/test.sh

echo "======================================"
echo "✅ PrivateVault Demo READY"
echo "======================================"
