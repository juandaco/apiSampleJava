
# Instructions

## Pre-requisites:

- `kubectl` installed
- `terraform` installed
- `helm` installed
- `aws` installed and configured
- Setup `docker-config.json` in the root at the project as taken from [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#log-in-to-docker).

## Deployment

1. Run the deployment script.
    ```bash
    # Make the script executable
    chmod u+x ./deploy
    # Run the script
    ./deploy
    ```

1. Setup DNS pointing to Jenkins K8s installation.
    - Get LoadBalancer domain with `kubectl`
        ```bash
        # Get the DNS from 
        kubectl get svc -A | grep LoadBalancer
        ```

    - Configure the DNS with CNAME or A records to point to Jenkins installation

1. Get credentials for Jenkins admin user from deployment script output or running:
    ```bash
    kubectl -n jenkins get secret jenkins -o go-template='{{ range $k,$v := .data }}{{ printf "%s: %s\n" $k ($v | base64decode) }}{{ end}}'
    ```

1. Access Jenkins and setup projects:
    1. Create project `adidas-sre-challenge`
    1. Setup credentials for:
        - `SONAR_TOKEN`
        - `SNYK_TOKEN`