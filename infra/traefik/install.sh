#!/usr/bin/env bash

set -euo pipefail

# Set current directory to the script's location
cd "$(dirname "$0")"


# Check if Traefik Helm repo is present, add if not
if ! helm repo list -o yaml | yq '.[].name' | grep -q '^traefik$'; then
    echo "🚚  Adding Traefik Helm repo..."
    helm repo add traefik https://traefik.github.io/charts
    helm repo update
    echo "✅  Added Traefik Helm repo."
fi
echo ""

echo "🚚  Installing Traefik via Helm..."
if helm list -A --short | grep -q '^traefik$'; then
    if gum confirm "⚠️  Traefik Helm release already exists. Upgrade?" ; then
        echo "🛠️  Upgrading Traefik via Helm..."
        helm upgrade --install traefik traefik/traefik --namespace traefik --create-namespace -f values.yaml --wait
        echo "✅  Upgraded Traefik."
    else
        echo "⏭️  Skipping Traefik installation."
    fi
else
    echo "🛠️  Installing Traefik via Helm..."
    helm upgrade --install traefik traefik/traefik --namespace traefik --create-namespace -f values.yaml --wait
    echo "✅  Installed Traefik."
fi
echo ""
