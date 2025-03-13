#!/bin/bash
set -ex

# Install K3s master (if not already installed)
if ! command -v k3s >/dev/null; then
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -

  # Wait for the token to be generated
  until [ -f /var/lib/rancher/k3s/server/node-token ]; do
    sleep 2
  done

  # Copy the generated token to the shared folder so worker nodes can access it
  sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/k3s-token
  sudo chmod 644 /vagrant/k3s-token

  echo "K3s master installed and token shared successfully!"
else
  echo "K3s master is already installed. Skipping installation."
fi
