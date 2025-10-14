#!/usr/bin/env bash
# Refresh (restart) the Authentication API rollout.  Note active sessions will be dropped
# (re-login required).

set -euo pipefail
kubecolor rollout restart -n default deployment/auth-api
kubecolor rollout status -n default deployment/auth-api --timeout=30s
echo "✅  Refreshed Authentication API rollout."
