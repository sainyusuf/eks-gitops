module "kargo_irsa" {
  source           = "../modules/eks-irsa"
  application_name = "kargo"
  policy_dir_path  = "files/kargo"
  policy_file_name = "kargo_policy.json"
  namespace        = "kargo"
  service_account  = "kargo-controller"
  eks_cluster_name = module.eks.cluster_name
}
