#!/usr/bin/env bash

# 1. Verify needed tools and files

# Verify that tools are installed.
function verify_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "You need to have installed $1 to proceed..."
    exit
  fi
}
verify_command 'kubectl'
verify_command 'helm'
verify_command 'terraform'
verify_command 'aws'

# AWS CLI with credentials for user.
if ! aws iam get-user >/dev/null 2>&1; then
  echo 'You need to login into AWS CLI to run IaC commands...'
  exit
fi

# Ensure that docker-config.json exists.
if [ ! -f docker-config.json ]; then
  echo 'You need the docker-config.json file in place to proceed...'
  exit
fi

# 2. Deploy infrastructure and install K8s base applications
pushd terraform || exit
  # Install needed providers and dependencies
  terraform init
  # Deploy infrastructure and install applications
  terraform apply -auto-approve
  # Create kubectl context with the created AWS EKS
  aws eks --region "$(terraform output -raw region)" update-kubeconfig --name "$(terraform output -raw cluster_name)"
popd || exit

# 3. Create docker credentials to interact with registry
kubectl -n jenkins create secret generic regcred \
    --from-file=.dockerconfigjson=docker-config.json \
    --type=kubernetes.io/dockerconfigjson

# 4. Print Jenkins admin credentials
# shellcheck disable=SC2016
kubectl -n jenkins get secret jenkins -o go-template='{{ range $k,$v := .data }}{{ printf "%s: %s\n" $k ($v | base64decode) }}{{ end}}'
