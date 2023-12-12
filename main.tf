terraform {
  required_providers {
    # Kubernetes provider
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    # Helm provider
    helm = {
      source  = "hashicorp/helm"
    }
  }
}

# Kubernetes provider configuration
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "docker-desktop"
}

# Helm provider configuration
provider "helm" {
  # Local Kubernetes cluster from Docker Desktop
  kubernetes {
    # Load the kubeconfig from your home directory
    config_path = "~/.kube/config"
  }
}
# Install cert-manager helm chart using terraform
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.13.0"
  namespace        = "cert-manager"
  create_namespace = "true"
  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "prometheus.enabled"
    value = "false"
  }

}

resource "helm_release" "cert_manager_dependents" {
  name        = "cert-manager-depenedents"
  chart       = "cert-manager-depenedents"
  keyring     = ""
  repository  = "charts/"
  max_history = "5"

  values = [
    file("charts/cert-manager-depenedents/values.yaml"),
  ]

  depends_on = [
    helm_release.cert_manager,
  ]
}
