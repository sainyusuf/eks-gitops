# Karpenter Layer

This directory manages **Karpenter deployment** on the existing EKS cluster:

- **Karpenter IAM**: Controller role (IRSA) and node instance role
- **Karpenter Helm Chart**: v1.9.0 deployment with custom values
- **NodePools**: Baseline (on-demand) and workload (spot) configurations
- **EC2NodeClass**: Node template with AL2023 AMI
- **Resource Discovery Tags**: Subnet and security group tagging

## Why Separate?

Splitting Karpenter from the cluster layer **eliminates race conditions** where Kubernetes/Helm providers try to connect to a non-existent cluster during `terraform plan`.

## State Management

- **State File**: `s3://terraform-state-gitops-project-302879626612/02_eks_karpenter/terraform.tfstate`
- **Dependencies**: Reads from `02_eks_cluster` and `01_infrastructure` remote states

## Prerequisites

The EKS cluster **must exist** before deploying this layer. Deploy `02_eks/cluster` first.

## Deployment

```bash
cd 02_eks/karpenter
terraform init
terraform plan    # Should now work without "no client config" error
terraform apply
```

## NodePool Strategy

1. **baseline-od**: On-demand ARM instances (t4g/c7g/m7g) for stable workloads
2. **workload-spot**: Spot ARM instances with wide family selection for cost optimization

## Troubleshooting

If you see "Failed to construct REST client" errors, ensure:
1. Cluster exists and is accessible
2. AWS credentials are configured
3. `aws eks update-kubeconfig --name gitops-prod-eks` works
