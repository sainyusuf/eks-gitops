# Migration Guide: 02_eks Split into Cluster and Karpenter

## Overview

The `02_eks` directory has been refactored into two separate layers to solve race conditions during deployment:

- **02_eks/cluster**: Core EKS cluster infrastructure
- **02_eks/karpenter**: Karpenter deployment and configuration

## State File Changes

| Old State Path | New State Path |
|---------------|---------------|
| `02_eks/terraform.tfstate` | `02_eks_cluster/terraform.tfstate` |
| — | `02_eks_karpenter/terraform.tfstate` |

## Why This Change?

### Problem: Race Condition
The old structure had Kubernetes/Helm providers trying to connect to the cluster during `terraform plan`, causing errors:
```
Error: Failed to construct REST client
cannot create REST client: no client config
```

### Solution: Separation of Concerns
1. **Cluster Layer**: Deploys EKS cluster using AWS provider only
2. **Karpenter Layer**: Deploys Karpenter after cluster exists, using Kubernetes/Helm providers

## Migration Path

### Option 1: Fresh Deployment (Recommended if cluster doesn't exist yet)

If you haven't deployed the EKS cluster yet, simply use the new structure:

```bash
# Step 1: Deploy cluster
cd 02_eks/cluster
terraform init
terraform plan
terraform apply

# Step 2: Deploy Karpenter
cd ../karpenter
terraform init
terraform plan    # No more "no client config" errors!
terraform apply
```

### Option 2: State Migration (If cluster already exists)

If you have an existing cluster deployed with the old structure:

#### Step 1: Backup Current State
```bash
cd 02_eks
terraform state pull > ../02_eks_state_backup.json
```

#### Step 2: Initialize New Directories
```bash
cd cluster
terraform init

cd ../karpenter
terraform init
```

#### Step 3: Import Existing Resources

You'll need to import your existing resources into the new state files. This is complex and requires careful mapping. Consider using `terraform import` for each resource.

**Alternative**: If acceptable, destroy the old stack and redeploy with the new structure.

## What Changed?

### Cluster Directory (`02_eks/cluster/`)

**Contains:**
- EKS module configuration
- Fargate profiles (Karpenter, CoreDNS)
- IRSA roles (EBS, EFS, ALB)
- Security group rules for DNS
- Cluster access entries

**Provider:** AWS only (no Kubernetes/Helm)

**Key Outputs:**
- `cluster_name`
- `cluster_endpoint`
- `oidc_provider_arn`
- `node_security_group_id`
- IRSA role ARNs

### Karpenter Directory (`02_eks/karpenter/`)

**Contains:**
- Karpenter module (IAM roles)
- Helm release (Karpenter chart)
- NodePool and EC2NodeClass manifests
- Resource discovery tags (subnets, security groups)
- Kubernetes namespace

**Providers:** AWS, Kubernetes, Helm

**Dependencies:**
- Remote state: `02_eks_cluster/terraform.tfstate`
- Remote state: `01_infrastructure/terraform.tfstate`

## Remote State References

### Old (02_eks):
```hcl
# No remote state - everything in one place
```

### New (02_eks/karpenter):
```hcl
data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "terraform-state-gitops-project-302879626612"
    key    = "02_eks_cluster/terraform.tfstate"
    region = "eu-central-1"
  }
}
```

## CI/CD Pipeline Updates

Update your GitHub Actions or CI/CD pipeline to deploy in sequence:

```yaml
jobs:
  deploy-cluster:
    name: Deploy EKS Cluster
    steps:
      - name: Terraform Apply Cluster
        working-directory: 02_eks/cluster
        run: |
          terraform init
          terraform apply -auto-approve

  deploy-karpenter:
    name: Deploy Karpenter
    needs: deploy-cluster
    steps:
      - name: Terraform Apply Karpenter
        working-directory: 02_eks/karpenter
        run: |
          terraform init
          terraform apply -auto-approve
```

## Benefits of This Structure

✅ **No More Race Conditions**: Kubernetes providers connect to existing cluster
✅ **Separate State Files**: Lower blast radius, safer changes
✅ **Cleaner Dependencies**: Explicit separation between infrastructure layers
✅ **Easier Lifecycle Management**: Update Karpenter independently from cluster
✅ **Better CI/CD**: Separate jobs for cluster vs. tooling

## Troubleshooting

### Issue: "no client config" error in cluster directory
**Solution:** This shouldn't happen - cluster directory doesn't use Kubernetes provider

### Issue: Can't connect to cluster in karpenter directory
**Solution:** Ensure cluster is deployed first and accessible:
```bash
aws eks update-kubeconfig --name gitops-prod-eks --region eu-central-1
kubectl get nodes
```

### Issue: Remote state not found
**Solution:** Verify cluster layer was applied and state file exists in S3

## Rollback Plan

If you need to rollback to the old structure:

1. Keep the backup: `02_eks_state_backup.json`
2. Old code is still in `02_eks/` (outdated files)
3. Can restore state and reapply old config if needed

## Questions?

This is a significant architectural improvement that follows Terraform best practices for managing Kubernetes infrastructure. The split eliminates race conditions and makes the codebase more maintainable.
