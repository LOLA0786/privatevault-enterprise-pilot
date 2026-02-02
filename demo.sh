#!/bin/bash
set -e

echo "Building image..."
docker build -t privatevault:demo -f runtime/Dockerfile .

echo "Loading into kind..."
kind load docker-image privatevault:demo --name pv-demo

echo "Restarting..."
kubectl rollout restart deploy/privatevault -n pv-pilot

echo "Waiting..."
kubectl rollout status deploy/privatevault -n pv-pilot

echo "Forwarding..."
kubectl port-forward -n pv-pilot deploy/privatevault 8000:8000
