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
provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  load_config_file       = false
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
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.0.6"
  namespace        = "ingress"
  create_namespace = true
  values = [
    file("${path.module}/ingress-nginx-values.yaml")
  ]
}

# Cert Manager
resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.6.1"
  namespace        = "cert-manager"
  create_namespace = true
  set {
    name  = "installCRDs"
    value = true
  }
  depends_on = [
    helm_release.nginx_ingress
  ]
}
resource "kubectl_manifest" "cluster-issuer-crd" {
  yaml_body = file("${path.module}/cluster-issuer.yaml")
  depends_on = [
    helm_release.cert-manager
  ]
}

# Jenkins
resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = "3.8.6"
  namespace        = "jenkins"
  create_namespace = true
  values = [
    file("${path.module}/jenkins-values.yaml")
  ]
  depends_on = [
    kubectl_manifest.cluster-issuer-crd
  ]
}
