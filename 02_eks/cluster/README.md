# EKS Cluster Layer

This directory manages the **core EKS cluster infrastructure** including:

- **EKS Control Plane**: Kubernetes cluster with version 1.35
- **Fargate Profiles**: For Karpenter controller and CoreDNS
- **IRSA Roles**: For EBS CSI, EFS CSI, and ALB Controller
- **Access Management**: IAM users and roles with cluster access
- **Security Groups**: DNS rules for EC2 nodes to Fargate
- **CloudWatch Logs**: Control plane logging

## Why Separate?

This layer is split from Karpenter to **avoid race conditions** during deployment. The Kubernetes provider needs a running cluster to connect to, which doesn't exist during the initial apply.

## State Management

- **State File**: `s3://terraform-state-gitops-project-302879626612/02_eks_cluster/terraform.tfstate`
- **Remote State**: Used by `02_eks/karpenter` layer

## Outputs

Key outputs for downstream dependencies:
- `cluster_name`, `cluster_endpoint`, `cluster_certificate_authority_data`
- `oidc_provider_arn` (for IRSA)
- `node_security_group_id`, `cluster_security_group_id`
- IRSA role ARNs for EBS, EFS, ALB controllers

## Deployment

```bash
cd 02_eks/cluster
terraform init
terraform plan
terraform apply
```

**Next Step**: Deploy Karpenter in `02_eks/karpenter` after cluster is ready.
