#!/bin/bash

# Exit on error and verbose output
set -ex

# Install K3s if not already installed
if ! command -v k3s >/dev/null; then
  curl -sfL https://get.k3s.io | \
    INSTALL_K3S_EXEC="--disable=traefik" \
    K3S_TOKEN=${K3S_TOKEN} \
    sh -
    
  # Wait for cluster initialization
  until [ -f /etc/rancher/k3s/k3s.yaml ]; do sleep 2; done
  sudo chown vagrant:vagrant /etc/rancher/k3s/k3s.yaml
  echo "K3s master installed successfully!"
else
  echo "K3s master already installed. Skipping."
fi