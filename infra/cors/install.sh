#!/usr/bin/env bash

set -euo pipefail

# Set current directory to the script's location
cd "$(dirname "$0")"

# This is a locally defined Helm chart, so no need to add a repo

echo "🚚  Installing the CORS middleware via Helm..."
if helm list -A --short | grep -q '^cors$'; then
    if gum confirm "⚠️  CORS middleware Helm release already exists. Upgrade?" ; then
        echo "🛠️  Upgrading CORS middleware via Helm..."
        helm upgrade --install cors ./helm/cors --namespace default -f values.yaml --wait
        echo "✅  Upgraded CORS middleware."
    else
        echo "⏭️  Skipping CORS middleware installation."
    fi
else
    # Install CORS middleware via Helm
    echo "🛠️  Installing CORS middleware via Helm..."
    helm upgrade --install cors ./helm/cors --namespace default -f values.yaml --wait
    echo "✅  Installed CORS middleware."
fi
echo ""
