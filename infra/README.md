# Infrastructure manifests

This directory contains setup files for the infrastructure components of the DT platform.  This include the Traefik reverse proxy, authentication API, and login webpage.

Each directory contains:

- `install.sh` &mdash; the install script to load the component into the Kubernetes cluster (via [Helm](https://helm.sh/)).  The script should:
  - Check that any necessary Helm repos are installed; if not, run `helm repo add`.
  - Prompt before upgrading an existing install (check using `helm list -Aq | grep`).
  - Set up any necessary port-forwards, avoiding duplicate sessions.
- `values.yaml` &mdash; values to apply when installing the Helm chart.
- `component.yaml` &mdash; used by the DT platform to build a component registry.

For locally defined Helm charts, we include:

- `Dockerfile`: image build instructions for a Deployment/ReplicaSet/etc.  If multiple images are required, use `foo.Dockerfile`, `bar.Dockerfile`, etc.
  - You must build and push these images manually.  You can use a free account on [Docker Hub](https://hub.docker.com/) for this.
  - See `docker build --help`, `docker tag --help`, `docker push --help`
- `helm/<foo>`: The [Helm chart](https://helm.sh/docs/topics/charts/).  We use a subdirectory within `helm/` as some Helm commands may use the directory name as the default name for generating Kubernetes manifest files.

!!!warning
    Never use the `default` function in your Helm charts.  Instead, default values should be stored in a `values.yaml` within the Helm chart directory, which informs users of which values are available to be overridden in their personal `values.yaml` file.
