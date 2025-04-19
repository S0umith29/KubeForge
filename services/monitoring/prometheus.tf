resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring" 
  } 
}

resource "helm_release" "prometheus" {
  name = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  version = ">=62.5.0"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  set {
    name = "prometheus.prometheusSpec.service.type"
    value = "ClusterIP"
  }

  set {
    name = "prometheus.prometheusSpec.ingress.enabled"
    value = "false"
  }

  set {
    name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "local-path"
  }

  set {
    name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "10Gi"
  }

  set {
    name = "alertmanager.enabled"
    value = "false"
  }

  set {
    name = "grafana.enabled"
    value = "true"
  }

  set {
    name = "grafana.service.type"
    value = "ClusterIP"
  }

  set {
    name = "grafana.ingress.enabled"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.service.annotations.traefik\\.ingress\\.kubernetes\\.io/ssl-redirect"
    value = "false"
  }

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

data "kubernetes_service" "prometheus_server" {
  metadata {
    name = "prometheus-kube-prometheus-prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  depends_on = [helm_release.prometheus]
}

resource "kubernetes_ingress_v1" "prometheus" {
  metadata {
    name = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
      "external-dns.alpha.kubernetes.io/hostname" = "prometheus.soumith.undernet.cs.odu.edu"
    }
  }
  spec {
    ingress_class_name = "traefik"
   # tls {
    #   hosts       = ["prometheus.soumith.undernet.cs.odu.edu"]
    #   secret_name = "prometheus-tls"
    # }
    rule {
      host = "prometheus.soumith.undernet.cs.odu.edu"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = data.kubernetes_service.prometheus_server.metadata[0].name
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
