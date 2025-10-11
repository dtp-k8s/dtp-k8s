#!/usr/bin/env bash
# Reset MicroK8s cluster.

set -euo pipefail

# cd to the root of the repository
cd "$(git rev-parse --show-toplevel)"

# Confirm using `gum`
if ! command -v gum &> /dev/null; then
    echo "❌  gum is not installed. Please run setup.sh first."
    exit 1
fi
if ! gum confirm "This will reset your MicroK8s cluster. Do you want to continue?"; then
    echo "❌  Aborting."
    exit 1
fi

# Kill existing port-forward sessions
echo "☠️  Clearing existing port-forward sessions..."
pgrep -af 'kubectl port-forward' | grep -viE "screen" | awk '{print $1}' | xargs -r kill -9 || true

# Return the MicroK8s node to the default initial state.
echo "🧹  Resetting MicroK8s cluster..."
# Force sudo to prompt for password if needed.
sudo -K
# `reset` must be run with sudo
sudo microk8s reset

echo ""

# Re-enable required MicroK8s add-ons.
echo "♻️  Re-enabling MicroK8s add-ons..."
microk8s enable dns
microk8s enable hostpath-storage
microk8s enable metrics-server
microk8s enable dashboard
