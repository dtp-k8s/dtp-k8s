#!/usr/bin/env bash

set -euo pipefail

# Create a timestamped log file
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S_%z)
LOGFILE="logs/setup_$TIMESTAMP.log"
mkdir -p logs
exec > >(tee -a "$LOGFILE") 2>&1

echo "=============================================="
echo " Kubernetes-Based Digital Twin Platform Demo"
echo " Setup Script"
echo " Timestamp: $(date -Iseconds)"
echo "=============================================="
echo ""

# Check $PATH variable
echo "🔍  Checking if $HOME/.local/bin is in your PATH..."
if ! echo "$PATH" | tr ':' '\n' | grep -q "$HOME/.local/bin"; then
    echo "❌  $HOME/.local/bin is not in your PATH. Please add it and try again."
    exit 1
fi
echo "✅  $HOME/.local/bin is in your PATH."
echo ""

# Set up microk8s group
echo "🛠️  Checking user membership to the microk8s group..."
if ! getent group microk8s &> /dev/null; then
    sudo usermod -a -G microk8s "$USER"
    echo "✅  Added $USER to microk8s group. Log out and back in to apply the changes and re-run this setup script."
    exit 1
else
    echo "✅  $USER is in the microk8s group."
fi

# Update package lists
echo "🛠️  Updating package lists..."
sudo apt-get update -yqo APT::Get::HideAutoRemove=1
echo "✅  Package lists updated."
echo ""

# Add charm.sh repository (for gum)
echo "🛠️  Adding charm.sh APT repository for gum..."
sudo mkdir -p /etc/apt/keyrings
if ! apt-cache show gum &> /dev/null; then
    curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *' | sudo tee /etc/apt/sources.list.d/charm.list
    sudo chmod 644 /etc/apt/keyrings/charm.gpg
    echo "✅  Added charm.sh repository."
else
    echo "✅  Found gum in the APT cache, skipping repository addition."
fi
echo ""

# Add Neo4j repository (for cypher-shell)
echo "🛠️  Adding Neo4j APT repository for cypher-shell..."
sudo mkdir -p /etc/apt/keyrings
if ! apt-cache show cypher-shell &> /dev/null; then
    curl -fsSL https://debian.neo4j.com/neotechnology.gpg.key | gpg --dearmor -o /etc/apt/keyrings/neo4j.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/neo4j.gpg] https://debian.neo4j.com stable latest' | sudo tee /etc/apt/sources.list.d/neo4j.list
    sudo chmod 644 /etc/apt/keyrings/neo4j.gpg
    echo "✅  Added Neo4j repository."
else
    echo "✅  Found cypher-shell in the APT cache, skipping repository addition."
fi
echo ""

# Add repository for Docker
echo "🛠️  Adding Docker APT repository..."
sudo mkdir -p /etc/apt/keyrings
if ! apt-cache show docker-ce &> /dev/null; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
    sudo chmod 644 /etc/apt/keyrings/docker.gpg
    echo "✅  Added Docker repository."
else
    echo "✅  Found docker in the APT cache, skipping repository addition."
fi
echo ""

# Add repository for Kubernetes tools
echo "🛠️  Adding Kubernetes APT repository..."
sudo mkdir -p /etc/apt/keyrings
if ! apt-cache show kubectl &> /dev/null; then
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo chmod 644 /etc/apt/keyrings/kubernetes.gpg
    echo "✅  Added Kubernetes repository."
else
    echo "✅  Found kubectl in the APT cache, skipping repository addition."
fi
echo ""

# Update package lists again
echo "🛠️  Updating package lists (again)..."
sudo apt-get update -yqo APT::Get::HideAutoRemove=1
echo "✅  Package lists updated."
echo ""

# Remove unofficial Docker packages if they exist
echo "🗑️  Removing unofficial Docker packages..."
sudo apt-get purge -yo APT::Get::HideAutoRemove=1 docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
echo "✅  Unofficial Docker packages removed."
echo ""

# Install apt packages
echo "🛠️  Installing required apt packages..."
REQUIRED_APT_PACKAGES=(
    authbind
    curl
    cypher-shell
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fzf
    git
    gum
    just
    jq
    kubectl
    kubecolor
    mosquitto-clients
    pgcli
    pre-commit
    python3
    python3-click
    screen
    shellcheck
    skate
    wget
)
sudo apt-get install -yqo APT::Get::HideAutoRemove=1 "${REQUIRED_APT_PACKAGES[@]}"
echo "✅  Required apt packages installed."
echo ""

# Ensure snaps are enabled
echo "🛠️  Ensuring snaps are enabled..."
if ! command -v snap &> /dev/null; then
    sudo apt install -yqo APT::Get::HideAutoRemove=1 snapd
fi
echo "✅  snaps are enabled."
echo ""

# Refresh snaps
echo "🛠️  Refreshing snaps..."
sudo snap refresh
echo "✅  snaps are refreshed."
echo ""

# Install required snap packages
echo "🛠️  Installing required packages (snap)..."
sudo snap install yq
sudo snap install helm --classic
sudo snap install microk8s --classic
echo "✅  Required snap packages installed."
echo ""

# Set up the microk8s cluster
echo "🛠️  Setting up the microk8s cluster..."
mkdir -p ~/.kube
sudo microk8s config > ~/.kube/config
sudo chown -f -R "$USER" ~/.kube
echo "🛠️  Starting microk8s..."
microk8s start
echo "✅  microk8s started."
echo ""

# Enable required microk8s addons
echo "🛠️  Enabling required microk8s addons..."
microk8s enable dns
microk8s enable hostpath-storage
microk8s enable metrics-server
microk8s enable dashboard
echo ""

# Grant kubectl permission to bind to low-numbered ports
echo "🛠️  Granting kubectl permission to bind to low-numbered ports..."
sudo setcap 'cap_net_bind_service=+ep' /usr/bin/kubectl
echo "✅  Granted kubectl permission to bind to low-numbered ports."
echo ""

# Set up git aliases
echo "🛠️  Setting up git aliases..."
git config --local alias.root 'rev-parse --show-toplevel'
git config --local alias.st 'status --short --branch'
git config --local alias.cfg 'config --list'
echo "✅  Git aliases set up."
echo ""

# Check Git configuration for user.name and user.email
echo "🛠️  Checking Git configuration..."
if ! git config --get user.name &> /dev/null; then
    read -rp "Enter your Git user.name: " git_username
    git config user.name "$git_username"
    echo "✅  Git user.name set to '$git_username'."
else
    echo "✅  Git user.name is already set to '$(git config --get user.name)'."
fi
if ! git config --get user.email &> /dev/null; then
    read -rp "Enter your Git user.email: " git_useremail
    git config user.email "$git_useremail"
    echo "✅  Git user.email set to '$git_useremail'."
else
    echo "✅  Git user.email is already set to '$(git config --get user.email)'."
fi
echo ""

# Install pre-commit hooks
echo "🛠️  Installing pre-commit hooks..."
pre-commit install -c configs/pre-commit-config.yaml
echo "✅  Pre-commit hooks installed."
echo ""

echo "🏁🎉  Setup complete! 🎉🏁"
