#!/usr/bin/env bash
# Refresh (restart) the Traefik rollout.

set -euo pipefail
kubecolor rollout restart -n traefik daemonset/traefik
kubecolor rollout status -n traefik daemonset/traefik --timeout=30s
echo "✅  Refreshed Traefik rollout."

echo "🗑️  Clearing existing port-forward sessions for Traefik (if any)..."
pgrep -af 'kubectl port-forward' | grep -viE "screen" | grep "svc/traefik" | awk '{print $1}' | xargs -r kill -9 || true
echo ""

echo "🛠️  Forwarding Traefik to http://localhost:80 ..."
screen -dmS k8s-pf-traefik kubectl port-forward -n traefik svc/traefik 80:web
# screen -dmS k8s-pf-traefik kubectl port-forward -n traefik svc/traefik 443:websecure
echo "✅  Port-forward established."
echo ""
