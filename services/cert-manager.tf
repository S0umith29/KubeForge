resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true
  version    = "v1.14.4"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "null_resource" "wait_for_cert_manager_crds" {
  depends_on = [helm_release.cert_manager]

  provisioner "local-exec" {
    command = <<EOT
      until kubectl get crd clusterissuers.cert-manager.io --kubeconfig ../k3s.yaml >/dev/null 2>&1; do
        echo "Waiting for Cert-Manager CRDs to be available..."
        sleep 5
      done
      echo "Cert-Manager CRDs are ready."
    EOT
  }
}

resource "kubernetes_manifest" "letsencrypt_cluster_issuer" {
  depends_on = [null_resource.wait_for_cert_manager_crds]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "YOUR_EMAIL"
        privateKeySecretRef = {
          name = "letsencrypt-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "traefik"
              }
            }
          }
        ]
      }
    }
  }
}
