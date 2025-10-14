#!/usr/bin/env bash

set -euo pipefail

# Set current directory to the script's location
cd "$(dirname "$0")"

# This is a locally defined Helm chart, so no need to add a repo

echo "🚚  Installing the Authentication API via Helm..."
if helm list -A --short | grep -q '^auth-api$'; then
    if gum confirm "⚠️  Authentication API Helm release already exists. Upgrade?" ; then
        echo "🛠️  Upgrading Authentication API via Helm..."
        helm upgrade --install auth-api ./helm/auth-api --namespace default -f values.yaml --wait
        echo "✅  Upgraded Authentication API."
    else
        echo "⏭️  Skipping Authentication API installation."
    fi
else
    # Install Authentication API via Helm
    echo "🛠️  Installing Authentication API via Helm..."
    helm upgrade --install auth-api ./helm/auth-api --namespace default -f values.yaml --wait
    echo "✅  Installed Authentication API."
fi
echo ""
