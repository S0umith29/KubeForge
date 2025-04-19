resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
      "external-dns.alpha.kubernetes.io/hostname" = "grafana.soumith.undernet.cs.odu.edu"
    }
  }
  spec {
    ingress_class_name = "traefik"
    rule {
      host = "grafana.soumith.undernet.cs.odu.edu"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-grafana"
              port {
                name = "http-web"
              }
            }
          }
        }
      }
    }
  }
  depends_on = [helm_release.prometheus]
}
