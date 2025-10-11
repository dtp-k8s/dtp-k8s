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

echo "🗑️  Clearing existing port-forward sessions for Traefik (if any)..."
pgrep -af 'kubectl port-forward' | grep -viE "screen" | grep "svc/traefik" | awk '{print $1}' | xargs -r kill -9 || true
echo ""

echo "🛠️  Forwarding Traefik to http://localhost:80 ..."
screen -dmS k8s-pf-traefik kubectl port-forward -n traefik svc/traefik 80:web
# screen -dmS k8s-pf-traefik kubectl port-forward -n traefik svc/traefik 443:websecure
echo ""
