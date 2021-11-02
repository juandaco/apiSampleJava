# K8s installations
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

# Base resources
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}
resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

# Application Environments
resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }
}
resource "kubernetes_namespace" "stage" {
  metadata {
    name = "stage"
  }
}
resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
}

# Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.6"
  namespace  = "ingress"
  values = [
    file("${path.module}/ingress-nginx-values.yaml")
  ]
}

# Cert Manager
resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.6.1"
  namespace  = "cert-manager"
  set {
    name  = "installCRDs"
    value = true
  }
}
variable "letsencrypt_email" {
  description = "Email for Let's Encrypt notifications."
  default     = "juandacorias@gmail.com"
  type        = string
}
resource "kubernetes_manifest" "cluster-issuer-crd" {
  depends_on = [
    helm_release.cert-manager
  ]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        email  = var.letsencrypt_email
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [{
          http01 = {
            ingress = {
              class = "nginx"
            }
          }
        }]
      }
    }
  }
}

# Jenkins
# resource "helm_release" "jenkins" {
#   name       = "jenkins"
#   repository = "https://charts.jenkins.io"
#   chart      = "jenkinsci"
#   version    = "3.8.6"
#   namespace  = "jenkins"

#   values = [
#     file("${path.module}/jenkins-values.yaml")
#   ]
# }
