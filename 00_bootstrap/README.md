# CloudFormation Bootstrap Template

This directory contains the CloudFormation template (`cfn_bootstrap.yml`) that sets up the foundational AWS resources required for GitOps deployment with GitHub Actions.

## Overview

The bootstrap template creates the essential infrastructure components needed to enable secure, keyless authentication between GitHub Actions and AWS for automated deployments.

## Resources Created

### 1. GitHub OIDC Identity Provider
- **Resource**: `GitHubOidcProvider`
- **Purpose**: Enables GitHub Actions to authenticate with AWS using OpenID Connect (OIDC)
- **Security**: No long-lived AWS credentials required in GitHub

### 2. IAM Role for GitHub Actions
- **Resource**: `GitHubActionsRole`
- **Purpose**: Role assumed by GitHub Actions for deployment operations
- **Scope**: Restricted to specific GitHub organization and repository

### 3. S3 Bucket for State Storage
- **Resource**: `StateBucket`
- **Purpose**: Stores Terraform state files
- **Features**:
  - Versioning enabled
  - Encryption at rest (AES256)
  - Public access blocked
  - Unique naming with account ID suffix

## Template Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `GitHubOrganization` | String | ✅ | - | Your GitHub organization name |
| `GitHubRepository` | String | ✅ | - | Your GitHub repository name |
| `WorkloadName` | String | ❌ | `gitops-project` | Identifier for the workload |
| `S3StateBucketBaseName` | String | ❌ | `terraform-state` | Base name for S3 state bucket |
| `TagEnvironment` | String | ❌ | `Prod` | Environment tag value |
| `TagOwner` | String | ✅ | - | Owner tag value |
| `TagGitHubRepo` | String | ✅ | - | GitHub repository tag value |
| `TagManagedBy` | String | ❌ | `SainArchitect` | Managed by tag value |

## Deployment Instructions

### Prerequisites
- AWS CLI installed and configured
- Appropriate AWS permissions to create IAM resources, OIDC providers, and S3 buckets
- GitHub organization and repository details

### Deploy the Stack

1. **Using AWS CLI**:
   ```bash
   aws cloudformation create-stack \
     --stack-name gitops-bootstrap \
     --template-body file://cfn_bootstrap.yml \
     --parameters \
       ParameterKey=GitHubOrganization,ParameterValue=your-github-org \
       ParameterKey=GitHubRepository,ParameterValue=your-repo-name \
       ParameterKey=TagOwner,ParameterValue=your-name \
       ParameterKey=TagGitHubRepo,ParameterValue=your-repo-name \
     --capabilities CAPABILITY_NAMED_IAM
   ```

2. **Using AWS Console**:
   - Navigate to CloudFormation in AWS Console
   - Create stack → Upload template file
   - Fill in the required parameters
   - Acknowledge IAM resource creation
   - Deploy

3. **Monitor Deployment**:
   ```bash
   aws cloudformation wait stack-create-complete --stack-name gitops-bootstrap
   ```

### Retrieve Outputs

After successful deployment, get the important values:

```bash
aws cloudformation describe-stacks \
  --stack-name gitops-bootstrap \
  --query 'Stacks[0].Outputs' \
  --output table
```

**Important Outputs**:
- `GitHubActionsRoleArn`: Use this in GitHub Actions workflows
- `S3StateBucketName`: Use this for Terraform backend configuration
