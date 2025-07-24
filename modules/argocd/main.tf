################################################################################
# ArgoCD
################################################################################
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace_argocd
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "argocd" {
  depends_on       = [kubernetes_namespace.argocd]
  count            = var.create_argocd ? 1 : 0
  name             = "argocd"
  namespace        = var.namespace_argocd
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_version

  values = [templatefile(local.argocd_values, {
    argocd_iam_role_arn = var.argocd_irsa_role_arn
  })]
}

resource "kubernetes_ingress_v1" "argocd_server_ingress" {
  metadata {
    name      = "argocd-server-ingress"
    namespace = "argocd"
    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"

      # This is you want to redirect HTTP to HTTPS. Please uncomment if needed and pass the required variables.
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/certificate-arn" = var.acm_certificate_arn
      "alb.ingress.kubernetes.io/ssl-policy"      = var.ssl_policy
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.argocd]
}
