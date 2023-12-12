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

# Path to config file for the Kubernetes provider as variable
variable "kubeconfig" {
  type = string
  # Load the kubeconfig from your home directory (default location for Docker Desktop Kubernetes)
  default = "~/.kube/config"
}

# Kubernetes provider configuration
provider "kubernetes" {
  config_path = var.kubeconfig
}

# Helm provider configuration
provider "helm" {
  # Local Kubernetes cluster from Docker Desktop
  kubernetes {
    # Load the kubeconfig from your home directory
    config_path = var.kubeconfig
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
