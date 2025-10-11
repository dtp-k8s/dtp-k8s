#!/usr/bin/env bash

set -euo pipefail

# Set current directory to the script's location
cd "$(dirname "$0")"

# This is a locally defined Helm chart, so no need to add a repo

echo "🚚  Installing PhpPgAdmin via Helm..."
if helm list -A --short | grep -q '^phppgadmin$'; then
    if gum confirm "⚠️  PhpPgAdmin Helm release already exists. Upgrade?" ; then
        echo "🛠️  Upgrading PhpPgAdmin via Helm..."
        helm upgrade --install phppgadmin ./helm/phppgadmin --namespace default -f values.yaml --wait
        echo "✅  Upgraded PhpPgAdmin."
    else
        echo "⏭️  Skipping PhpPgAdmin installation."
    fi
else
    # Install PhpPgAdmin via Helm
    echo "🛠️  Installing PhpPgAdmin via Helm..."
    helm upgrade --install phppgadmin ./helm/phppgadmin --namespace default -f values.yaml --wait
    echo "✅  Installed PhpPgAdmin."
fi
echo ""
