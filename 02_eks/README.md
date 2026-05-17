# EKS Infrastructure - Split Architecture

This directory contains the EKS cluster infrastructure split into two separate Terraform layers:

## Directory Structure

```
02_eks/
├── cluster/          # Layer 1: EKS cluster core infrastructure
│   ├── cluster.tf    # EKS module, Fargate profiles
│   ├── irsa.tf       # IRSA roles (EBS, EFS, ALB)
│   ├── provider.tf   # AWS provider only
│   ├── data.tf       # Remote state from infrastructure
│   ├── outputs.tf    # Cluster info, OIDC, IRSA roles
│   └── README.md     # Cluster layer documentation
│
├── karpenter/        # Layer 2: Karpenter deployment
│   ├── karpenter.tf  # Karpenter module, Helm, manifests
│   ├── tags.tf       # Resource discovery tags
│   ├── provider.tf   # AWS + Kubernetes + Helm providers
│   ├── data.tf       # Remote state from cluster + infra
│   ├── outputs.tf    # Karpenter outputs
│   ├── README.md     # Karpenter layer documentation
│   └── files/        # NodePool and EC2NodeClass manifests
│
└── MIGRATION_GUIDE.md  # This file
```

## Why Split?

### Old Problem (Single Directory)
```
02_eks/ 
└── All resources in one state
    ❌ Kubernetes provider tries to connect during plan
    ❌ "Failed to construct REST client: no client config"
    ❌ Race conditions during deployment
```

### New Solution (Two Layers)
```
Layer 1: cluster/     → Creates EKS cluster (AWS provider only)
Layer 2: karpenter/   → Deploys Karpenter (connects to existing cluster)
    ✅ No race conditions
    ✅ Clean provider separation
    ✅ Separate state files
```

## Deployment Order

**Always deploy in this order:**

```bash
# 1. Deploy cluster first
cd 02_eks/cluster
terraform init && terraform apply

# 2. Deploy Karpenter second
cd ../karpenter
terraform init && terraform apply
```

## State Files

| Layer | S3 State Key |
|-------|-------------|
| Cluster | `02_eks_cluster/terraform.tfstate` |
| Karpenter | `02_eks_karpenter/terraform.tfstate` |

## Key Benefits

1. **No Race Conditions**: Karpenter layer connects to existing cluster
2. **Separate State Management**: Changes to Karpenter don't risk cluster
3. **Clear Dependencies**: Explicit remote state references
4. **Easier Lifecycle Management**: 
   - Cluster changes rarely
   - Karpenter/NodePools update frequently
   - Different apply cadences
5. **Better CI/CD**: Separate pipeline jobs for each layer

## Quick Start

### New Deployment
```bash
# Infrastructure
cd 01_infrastructure && terraform apply

# Cluster
cd ../02_eks/cluster && terraform apply

# Karpenter
cd ../karpenter && terraform apply
```

### Update Karpenter Only
```bash
cd 02_eks/karpenter
terraform plan
terraform apply
```

### Update Cluster Only
```bash
cd 02_eks/cluster
terraform plan
terraform apply
```

## Documentation

- [Cluster Layer README](cluster/README.md)
- [Karpenter Layer README](karpenter/README.md)
- [Migration Guide](MIGRATION_GUIDE.md) - Detailed migration instructions

## Dependencies Graph

```
01_infrastructure
    ↓ (VPC, subnets)
02_eks/cluster
    ↓ (cluster info, OIDC)
02_eks/karpenter
    ↓ (Karpenter controller)
03_cluster_bootstrap (ArgoCD, Traefik)
```
