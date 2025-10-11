# dtp-k8s

Kubernetes-based Digital Twin Platform demo

## Project setup

### Quickstart

This repo assumes a Linux environment with `apt` and `bash`, e.g. Ubuntu.  Windows users should use [WSL](https://code.visualstudio.com/docs/remote/wsl).  Note that WSL automatically sets up port-forwarding between Windows and the WSL virtual machine, essential for most Kubernetes functionality.

0. Clone this repo using `git clone` or `gh repo clone`.
1. Run:

    ```sh
    find . -type f -name "*.example.env" -exec sh -c \
        'for f; do envfile="${f%.example.env}.env"; cp --update=none "$f" "$envfile"; done' sh {} +
    ```

   to generate `.env` files from the provided `.example.env` files.  Change values as desired.
2. Run `./setup.sh` to set up required software packages and start a MicroK8s cluster.
3. Run `./scripts/gen-k8s-secrets.sh` to generate and apply Kubernetes secrets.
4. Run `./scripts/micro-k8s-init.sh` to set up the **core** components of the DT platform.
5. Use the DT platform UI (🚧 TODO) to install/remove digital twins.

### The justfile

[`just`](https://just.systems/man/en/) is a program for organizing project scripts, similar to `make` for compilation artifacts.  Use `just` without any arguments to show a menu of available commands.

!!!warning
    While `just` commands can take arguments, this will break the chooser.  Use interactive prompts instead.  You may use `just` to collect arguments to be passed to a separate executable.

### Visual Studio code setup

`.vscode/extensions.json` contains a list of recommendend VS Code extensions. To view these, open your command palette (default `Ctrl+Shift+P`) and enter: "Extensions: Show Recommended Extensions".  To add an extension to the recommendations, right click it in the Extensions panel and select "Add to Workspace Recommendations".

`.vscode/settings.json` contains a list of VS Code settings for the workspace.  Edit directly or using the GUI (default `Ctrl+,`).

## The MicroK8s cluster

We use [MicroK8s](https://microk8s.io/) for local development:

- MicroK8s containers run "bare-metal" without the need for a virtual machine.
- Multi-node support with `microk8s add-node` and `microk8s join`
- [Upgrade to managed Kubernetes](https://ubuntu.com/kubernetes/managed) at any time
- [Official add-ons](https://microk8s.io/docs/addons) &mdash; although we will sometimes install packages via Helm instead for more configuration options

See the [command reference](https://microk8s.io/docs/command-reference) for a description of available MicroK8s commands.

### Setting up `kubectl`

We will use standalone `kubectl` rather than the one bundled with `microk8s`.  Note that `setup.sh` will create a `kubectl` configuration file for you, using the following commands:

```sh
mkdir -p ~/.kube
microk8s config > ~/.kube/config
```

If you wish to set up multiple configurations, you will need to merge changes to your `~/.kube/config` file **manually** and disable the corresponding section in `setup.sh`.

### The `hostpath-storage` add-on

We use hostpath storage for our MicroK8s cluster (enabled automatically in `setup.sh`).  This binds PersistentVolumes to directories on the host node.  This can be seen from the `kubectl describe` output for a PersistentVolume:

```yaml
# partial output
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /var/snap/microk8s/common/default-storage/default-data-postgres-postgresql-0-pvc-2719ed84-129c-4ba3-8dfc-131783763e78
    HostPathType:  DirectoryOrCreate
```

!!!note
    The storage location can be customized by [creating a custom StorageClass](https://microk8s.io/docs/addon-hostpath-storage#customize-directory-used-for-persistentvolume) and assigning it to any new PersistentVolumeClaims.

### Setting up Kubernetes secrets

Secrets for the Kubernetes cluster are stored in `k8s-secrets/`.  They can be generated automatically from `.env` files (stored in `k8s-env/`) using the `scripts/gen-k8s-secrets` script.  This script automatically converts all `.env` files in `k8s-env/` into Kubernetes manifests, stores them in `k8s-secrets/`, and applies them.

Manually created manifests in `k8s-secrets/` will also be applied, but will be overwritten if a matching `.env` file exists in `k8s-env/`.

## Git hooks and pre-commit

We use [`pre-commit`](https://pre-commit.com/index.html) to set up pre-commit and pre-push hooks for Git.

- Use

  ```sh
  pre-commit install -c <config>
  ```

  to install the hook scripts (this is done for you in `setup.sh`).
- Use

  ```sh
  pre-commit run --all-files
  ```

  to manually run all hook scripts against the entire Git repository, instead of just staged files.

Note that some hooks may modify files; these changes must be staged before running `git commit` and/or `git push` again.
