#!/usr/bin/env bash
# Refresh (restart) the PhpPgAdmin rollout.  Note active sessions will be dropped
# (re-login required).

set -euo pipefail
kubecolor rollout restart -n default deployment/phppgadmin
kubecolor rollout status -n default deployment/phppgadmin --timeout=30s
echo "✅  Refreshed PhpPgAdmin rollout."
