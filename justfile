############################################################
# Justfile for Kubernetes-based DT platform
#
# Just is like Make, but targets scripts instead of builds.
# No more .PHONY targets!
# Just reference: https://just.systems/man/en/
############################################################

# Default task: launch interactive menu
default:
    just --choose

# Set chmod +x for all .sh files in the project
chmod:
    #!/usr/bin/env bash
    find . -name "*.sh" -type f -exec chmod +x {} \;
    echo "✅ Set chmod +x for all .sh files.  See the \`ensure_source.sh\` template file for "
    echo "   creating scripts that must be sourced instead of executed directly."

######### KUBERNETES #########

# Launch the Kubernetes dashboard
dashboard:
    #!/usr/bin/env bash
    microk8s dashboard-proxy

# List all active kubectl port-forwards
port-forwards:
    #!/usr/bin/env bash
    ps ax | grep -vi "grep" | grep SCREEN | grep --color=auto "k8s-pf-"

# Refresh all kubectl port-forwards
refresh-port-forwards:
    #!/usr/bin/env bash
    echo "🗑️  Clearing existing port-forward sessions (if any)..."
    pgrep -af 'kubectl port-forward' | grep -viE "screen" | awk '{print $1}' | xargs -r kill -9 || true
    echo "🛠️  Forwarding Traefik to http://localhost:80 ..."
    screen -dmS k8s-pf-traefik kubectl port-forward -n traefik svc/traefik 80:web
    echo "🛠️  Forwarding PostgreSQL service to http://localhost:5432 ..."
    screen -dmS k8s-pf-postgres kubectl port-forward -n default svc/postgres-postgresql 5432:tcp-postgresql

######### PRE-COMMIT #########

# Run pre-commit hooks
pre-commit:
    #!/usr/bin/env bash
    pre-commit run --all-files --config ./configs/pre-commit-config.yaml

# Run pre-push hooks
pre-push:
    #!/usr/bin/env bash
    pre-commit run --all-files --config ./configs/pre-commit-config.yaml --hook-stage pre-push

# Update pre-commit hooks
pre-commit-update:
    #!/usr/bin/env bash
    pre-commit autoupdate --config ./configs/pre-commit-config.yaml

######### IMPORTS #########

# Include other justfiles
import "./data-store/postgres/justfile"
