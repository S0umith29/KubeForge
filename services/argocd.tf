# namespace.tf
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# ArgoCD Helm Release
resource "helm_release" "argocd" {
  name = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  namespace = kubernetes_namespace.argocd.metadata[0].name
  version = "7.1.0"

  set {
    name = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name = "server.ingress.enabled"
    value = "false"
  }
  set {
    name = "configs.params.server.insecure"
    value = "true"
  }
  set {
    name = "global.domain"
    value = "ARGOCD_DOMAIN"
  }
  set {
    name = "server.extraArgs[0]"
    value = "--basehref=/"
  }

# For using only http
#  set {
#    name = "server.extraArgs[1]"
#    value = "--insecure"
#  }

# For using only http 
#  set {
#    name = "configs.cm.url"
#    value = "http://ARGOCD_DOMAIN"
#  }
}

# ArgoCD service (optional)
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  depends_on = [helm_release.argocd]
}

# ingress.tf

resource "kubernetes_ingress_v1" "argocd" {
  metadata {
    name = "argocd"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    annotations = {
#      "cert-manager.io/cluster-issuer" = "letsencrypt"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
#      "traefik.ingress.kubernetes.io/router.tls" = "false"
      "external-dns.alpha.kubernetes.io/hostname" = "argocd.soumith.undernet.cs.odu.edu"      
    }
  }
  spec {
    ingress_class_name = "traefik"
#    tls {
#      hosts       = ["argocd.soumith.undernet.cs.odu.edu"]
#      secret_name = "argocd-tls"
#    }
    rule {
      host = "ARGOCD_DOMAIN"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = data.kubernetes_service.argocd_server.metadata[0].name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}
