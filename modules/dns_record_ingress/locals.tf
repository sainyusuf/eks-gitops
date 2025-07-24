locals {
  ingress_tag = join(
    "/",
    [var.server_namespace,
    var.ingress_name]
  )
}
