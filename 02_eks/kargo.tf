module "kargo_irsa" {
  source           = "../modules/eks-irsa"
  application_name = "kargo"
  policy_dir_path  = "files/kargo"
  policy_file_name = "kargo_policy.json"
  namespace        = "kargo"
  service_account  = "kargo-controller"
  eks_cluster_name = module.eks.cluster_name
}

module "kargo_dns_ingress" {
  source           = "../modules/dns_record_ingress"
  hosted_zone_name = "tukang-awan.com"
  ingress_name     = "kargo-api"
  server_namespace = "kargo"
  subdomain_name   = "kargo"
  cluster_name     = module.eks.cluster_name
}
