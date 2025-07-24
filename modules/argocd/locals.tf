locals {
  #argocd_values = coalesce(file("${path.root}/${var.directory_path}/${var.argocd_values_file_path}"), file("${path.module}/${var.argocd_default_values_file_path}"))
  argocd_values = join("/", [path.root, var.directory_path, var.argocd_values_file_path])
}
