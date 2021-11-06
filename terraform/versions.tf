terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.64.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13.0"
    }
  }

  required_version = ">= 1.0.10"
}

