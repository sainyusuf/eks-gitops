# Karpenter Configuration
# This file manages Karpenter IAM and Helm chart deployment
# NodePool and EC2NodeClass manifests are managed in karpenter_config layer

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.15.1"

  cluster_name = data.terraform_remote_state.cluster.outputs.cluster_name
  namespace    = "karpenter"

  node_iam_role_use_name_prefix = false
  node_iam_role_name            = "gitops-eks-karpenter-node-role"

  # Use IRSA instead of Pod Identity for Fargate compatibility
  create_pod_identity_association = false

  # Override the assume role policy to use IRSA instead of Pod Identity
  iam_role_source_assume_policy_documents = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Principal = {
          Federated = data.terraform_remote_state.cluster.outputs.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.terraform_remote_state.cluster.outputs.oidc_provider_arn, "/^(.*provider/)/", "")}:aud" = "sts.amazonaws.com"
            "${replace(data.terraform_remote_state.cluster.outputs.oidc_provider_arn, "/^(.*provider/)/", "")}:sub" = "system:serviceaccount:karpenter:karpenter"
          }
        }
      }]
    })
  ]

  tags = var.tags
}

# Create karpenter namespace for Fargate profile
resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
    labels = {
      name = "karpenter"
    }
  }
}

# Deploy Karpenter Helm chart
resource "helm_release" "karpenter" {
  depends_on = [module.karpenter, kubernetes_namespace.karpenter]

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  namespace  = "karpenter"
  version    = "1.9.0"

  wait    = true  # Wait for CRDs to be installed
  timeout = 120   # 2 minutes timeout

  values = [
    <<-EOT
    dnsPolicy: Default
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
    controller:
      env:
        - name: AWS_REGION
          value: ${var.region}
      resources:
        requests:
          cpu: "1"
          memory: "1Gi"
        limits:
          cpu: "1"
          memory: "1Gi"
      healthProbe:
        port: 8081
      livenessProbe:
        initialDelaySeconds: 30
        timeoutSeconds: 30
        periodSeconds: 10
        failureThreshold: 6
      readinessProbe:
        initialDelaySeconds: 30
        timeoutSeconds: 30
        periodSeconds: 10
        failureThreshold: 3
    settings:
      clusterName: ${data.terraform_remote_state.cluster.outputs.cluster_name}
      clusterEndpoint: ${data.terraform_remote_state.cluster.outputs.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    webhook:
      enabled: false
    EOT
  ]
}
