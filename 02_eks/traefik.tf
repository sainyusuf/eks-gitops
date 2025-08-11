# resource "kubernetes_namespace" "traefik" {
#   depends_on = [module.eks]
#   metadata {
#     name = "traefik"
#     labels = {
#       "app.kubernetes.io/name" = "traefik"
#     }
#   }
# }

# resource "helm_release" "traefik" {
#   depends_on = [kubernetes_namespace.traefik]
#   name       = "traefik"
#   repository = "https://traefik.github.io/charts"
#   chart      = "traefik"
#   namespace  = kubernetes_namespace.traefik.metadata[0].name
#   version    = "37.0.0"
#   create_namespace = false

#   values = [
#     templatefile("files/traefik/values.yaml", {
#     })
#   ]
# }
