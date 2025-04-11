# namespace.tf
resource "kubernetes_namespace" "uptime_kuma" {
  metadata {
    name = "uptime-kuma"
  }
}

# pvc.tf
resource "kubernetes_persistent_volume_claim" "uptime_kuma_data" {
  metadata {
    name      = "uptime-kuma-data"
    namespace = kubernetes_namespace.uptime_kuma.metadata[0].name
  }
  spec {
    storage_class_name = "local-path-immediate"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

# pv.tf

resource "kubernetes_persistent_volume" "uptime_kuma_pv" {
  metadata {
    name = "uptime-kuma-pv"
  }
  spec {
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Delete"
    storage_class_name = "local-path-immediate"  # Match the PVC's StorageClass
    persistent_volume_source {
      host_path {
        path = "/var/lib/rancher/k3s/storage/uptime-kuma"  # Subdirectory under k3s storage
        type = "DirectoryOrCreate"  # Create if it doesn’t exist
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = ["worker1"]
          }
        }
      }
    }
  }
}
# storage-class
resource "kubernetes_storage_class" "local_path_immediate" {
  metadata {
    name = "local-path-immediate"
  }
  storage_provisioner = "rancher.io/local-path"
  reclaim_policy = "Delete"
  volume_binding_mode = "Immediate"
}

# deplopyment.tf
resource "kubernetes_deployment" "uptime_kuma" {
  metadata {
    name      = "uptime-kuma"
    namespace = kubernetes_namespace.uptime_kuma.metadata[0].name
    labels = {
      app = "uptime-kuma"
    }
  }
  spec {
    replicas = 1
    strategy {
      type = "Recreate"  # Due to PVC
    }
    selector {
      match_labels = {
        app = "uptime-kuma"
      }
    }
    template {
      metadata {
        labels = {
          app = "uptime-kuma"
        }
      }
      spec {
        container {
          name  = "uptime-kuma"
          image = "louislam/uptime-kuma:1.23.16"
          image_pull_policy = "IfNotPresent"
          security_context {
            read_only_root_filesystem = true
          }
          port {
            container_port = 3001
          }
          resources {
            requests = {
              memory = "1024Mi"
              cpu    = "200m"
            }
            limits = {
              memory = "1024Mi"
            }
          }
          volume_mount {
            name       = "data"
            mount_path = "/app/data"
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 3001
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 3001
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.uptime_kuma_data.metadata[0].name
          }
        }
      }
    }
  }
}

# service.tf
resource "kubernetes_service" "uptime_kuma" {
  metadata {
    name      = "uptime-kuma"
    namespace = kubernetes_namespace.uptime_kuma.metadata[0].name
  }
  spec {
    selector = {
      app = "uptime-kuma"
    }
    port {
      name        = "http"
      port        = 80
      target_port = "3001"
    }
    type = "ClusterIP"
  }
}

# ingress.tf
resource "kubernetes_ingress_v1" "uptime_kuma" {
  metadata {
    name      = "uptime-kuma"
    namespace = kubernetes_namespace.uptime_kuma.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer"                  = "letsencrypt"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web,websecure"  # HTTP and HTTPS
      "traefik.ingress.kubernetes.io/router.tls"         = "false"           # Enable TLS
      "external-dns.alpha.kubernetes.io/hostname"        = "UPTIME_KUMA_DOMAIN"
    }
  }
  spec {
    ingress_class_name = "traefik"  # Optional; omit unless customized in k3s
    tls {
      hosts       = ["UPTIME_KUMA_DOMAIN"]
      secret_name = "uptime-kuma-tls"
    }
    rule {
      host = "UPTIME_KUMA_DOMAIN"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.uptime_kuma.metadata[0].name
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
