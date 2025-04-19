terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = ">=2.6.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.27.0"
    }
  }
}

provider "kubernetes" {
  config_path = "../../k3s.yaml"
}

provider "helm" {
  kubernetes {
    config_path = "../../k3s.yaml"
  }
}
