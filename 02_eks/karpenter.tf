module "karpenter" {

  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.37.1"

  cluster_name            = module.eks.cluster_name
  create_node_iam_role    = false
  node_iam_role_arn       = module.eks.eks_managed_node_groups["karpenter"].iam_role_arn
  create_access_entry     = false
  create_instance_profile = true
  enable_spot_termination = true

  enable_irsa                     = true
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "karpenter_ec2_pricing" {
  for_each = {
    "AmazonEC2ReadOnlyAccess"       = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
    "AWSPriceListServiceFullAccess" = "arn:aws:iam::aws:policy/AWSPriceListServiceFullAccess"
  }
  role       = module.karpenter.iam_role_name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "karpenter_sqs" {
  name = "KarpenterSQSPermissions"
  role = module.karpenter.iam_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:GetQueueUrl", "sqs:ListQueues"]
        Resource = "*"
      }
    ]
  })
}


resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "karpenter"
  chart            = "oci://public.ecr.aws/karpenter/karpenter"
  version          = "1.5.0"
  create_namespace = true

  values = [<<-EOF
    settings:
      clusterName:      ${module.eks.cluster_name}
      clusterEndpoint:  ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
      aws:
        defaultInstanceProfile: ${module.karpenter.instance_profile_name}

    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
    # controller:
    #   tolerations:
    #     - key:    "node-role.kubernetes.io/system"
    #       operator: "Exists"
    #       effect:   "NO_SCHEDULE"
  EOF
  ]

  timeout = 3600
}

locals {
  karpenter_yaml_files = fileset("${path.module}/files/karpenter", "*.yaml")

  karpenter_manifests = {
    for f in local.karpenter_yaml_files :
    f => yamldecode(templatefile(
      "${path.module}/files/karpenter/${f}",
      {
        cluster_name          = module.eks.cluster_name
        instance_profile_name = module.karpenter.instance_profile_name
    }))
  }
}

resource "kubernetes_manifest" "karpenter_objects" {
  for_each = local.karpenter_manifests

  manifest = each.value

  computed_fields = [
    "spec.requirements",
    "spec.template.spec.requirements"
  ]

  field_manager {
    name            = "terraform"
    force_conflicts = true
  }

  depends_on = [
    helm_release.karpenter
  ]
}
