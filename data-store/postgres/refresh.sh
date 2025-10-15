#!/usr/bin/env bash
# Refresh (restart) the PostgreSQL rollout and re-establish port-forwarding.

set -euo pipefail
kubecolor rollout restart -n default statefulset/postgres-postgresql
kubecolor rollout status -n default statefulset/postgres-postgresql --timeout=30s

echo "✅  Refreshed PostgreSQL rollout."
