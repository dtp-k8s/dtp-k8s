#!/usr/bin/env bash
# Install core DT platform services on the active MicroK8s cluster and enable port forwarding.

set -euo pipefail

# cd to the root of the repository
cd "$(git rev-parse --show-toplevel)"

echo "🛠️  Clearing existing port-forward sessions (if any)..."
pgrep -af 'kubectl port-forward' | grep -viE "screen" | awk '{print $1}' | xargs -r kill -9 || true

############################################################################################

### DASHBOARD ###

# Forward K8s dashboard to localhost:8443, kill existing sessions first
echo "🛠️  Forwarding Kubernetes Dashboard to https://localhost:8443 ..."
screen -dmS k8s-pf-dashboard kubectl port-forward -n kube-system svc/kubernetes-dashboard 8443:443
echo ""

############################################################################################

# List install scripts to run here.  Each script should:
# - Check if the service is already installed, and skip if so.
# - Install the service if not already installed (`helm upgrade --install`).
# - Clear any existing port-forward sessions for the service (`kill` processes found via `ps ax | grep`).
# - Set up port forwarding via a detached screen session (`screen -dmS`).

./infra/traefik/install.sh
./data-store/postgres/install.sh
./data-store/phppgadmin/install.sh

############################################################################################

# Display port forward information
echo "✅  Port forwarding set up via screen sessions. Current processes:"
pgrep -af 'kubectl port-forward' | grep -viE "screen" | grep "kubectl port-forward"
echo ""
