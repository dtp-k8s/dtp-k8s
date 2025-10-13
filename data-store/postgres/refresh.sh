#!/usr/bin/env bash
# Refresh (restart) the PostgreSQL rollout and re-establish port-forwarding.

set -euo pipefail
kubecolor rollout restart -n default statefulset/postgres-postgresql
kubecolor rollout status -n default statefulset/postgres-postgresql --timeout=30s

echo "✅  Refreshed PostgreSQL rollout."

echo "🗑️  Clearing existing port-forward sessions for PostgreSQL (if any)..."
pgrep -af 'kubectl port-forward' | grep -viE "screen" | grep "svc/postgres" | awk '{print $1}' | xargs -r kill -9 || true
echo ""

echo "🛠️  Forwarding PostgreSQL service to http://localhost:5432 ..."
screen -dmS k8s-pf-postgres kubectl port-forward -n default svc/postgres-postgresql 5432:tcp-postgresql
echo "✅  Port-forward established."
echo ""
