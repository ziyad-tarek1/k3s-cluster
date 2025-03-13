#!/bin/bash

# Exit on error and verbose output
set -ex

# Wait for master API to be ready
echo "Waiting for master node to be ready..."
while ! nc -z 192.168.56.101 6443; do
  sleep 2
done

# Install K3s agent if not already installed
if ! command -v k3s >/dev/null; then
  curl -sfL https://get.k3s.io | \
    K3S_URL=${K3S_URL} \
    K3S_TOKEN=${K3S_TOKEN} \
    sh -
  echo "Joined K3s cluster successfully!"
else
  echo "K3s agent already installed. Skipping."
fi