#!/usr/bin/env bash
# Refresh (restart) the Traefik rollout.

set -euo pipefail
kubecolor rollout restart -n traefik daemonset/traefik
kubecolor rollout status -n traefik daemonset/traefik --timeout=30s
echo "✅  Refreshed Traefik rollout."
