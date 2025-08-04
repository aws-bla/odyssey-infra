# Odyssey Infra Project

This repository contains Terraform infrastructure as code for AWS resources with remote state management and team collaboration support.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5
- Access to AWS account with permissions to create S3, DynamoDB, and other resources

## Quick Start

**New to this project?** See [SETUP.md](SETUP.md) for step-by-step setup instructions.

## Project Structure

```
├── main.tf                      # Root module configuration
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── backend.tf                   # Remote state backend
├── bootstrap/                   # Initial setup for remote state
└── modules/                     # Reusable m```

## Initial Setup (One-time Bootstrap)

### 1. Bootstrap Remote State Backend

First, create the S3 bucket and DynamoDB table for remote state. The naming follows the pattern `bla-odyssey-<environment>-<component>-<identifier>`:

```bash
cd bootstrap

# For dev environment (default)
terraform init
terraform plan
terraform apply

# For other environments, override variables
terraform apply -var="environment=prod"
```

This creates:
- S3 bucket: `bla-odyssey-dev-terraform-state`
- DynamoDB table: `bla-odyssey-dev-terraform-lock`
- KMS key: `bla-odyssey-dev-kms-01`

### 2. Configure Backend

The `backend.tf` uses workspace-specific naming:

```hcl
terraform {
  backend "s3" {
    bucket         = "bla-odyssey-dev-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "bla-odyssey-dev-terraform-lock"
    encrypt        = true
    workspace_key_prefix = "workspaces"
  }
}
```

### 3. Initialize Main Configuration

```bash
# Return to root directory
cd ..

# Initialize with remote backend
terraform init

# Create and select workspace
terraform workspace new dev
terraform workspace select dev
```

## Team Collaboration

### Shared AWS Account Setup

When multiple developers use the same AWS account:

1. **One-time bootstrap**: Only one team member runs the bootstrap
2. **Individual workspaces**: Each developer creates their own workspace
3. **Resource isolation**: Workspaces prevent resource name conflicts

```bash
# Each developer creates their own workspace
terraform workspace new john-feature-auth
terraform workspace new sarah-vpc-updates
terraform workspace new mike-s3-config
```

This creates isolated resources:
- John: `bla-odyssey-john-feature-auth-vpc-01`
- Sarah: `bla-odyssey-sarah-vpc-updates-vpc-01`
- Mike: `bla-odyssey-mike-s3-config-vpc-01`

## Daily Workflow

### Working with Workspaces

```bash
# List workspaces
terraform workspace list

# Create feature workspace
terraform workspace new feature/my-feature

# Switch workspace
terraform workspace select feature/my-feature

# Delete workspace (after merging)
terraform workspace delete feature/my-feature
```

### Planning and Applying Changes

```bash
# Format and validate
terraform fmt -recursive
terraform validate

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan
```

## Naming Convention

All resources follow the standardized naming pattern:
```
<company>-<project>-<environment>-<component>-<identifier>
```

Examples:
- VPC: `bla-odyssey-dev-vpc-01`
- Subnets: `bla-odyssey-dev-vpc-subnet-public-01`, `bla-odyssey-dev-vpc-subnet-public-02`
- IAM Role: `bla-odyssey-dev-iam-role-01`
- S3 Bucket: `bla-odyssey-dev-s3-data`

## Environment Variables

Set these environment variables to override defaults:

```bash
export TF_VAR_company="bla"                # Company name
export TF_VAR_project="odyssey"            # Project name (or "quantum", "phoenix")
export TF_VAR_region="us-west-2"           # Override default region
export TF_VAR_environment="production"     # Set environment tag
```

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Terraform Init
  run: terraform init -backend-config="bucket=${{ secrets.TF_STATE_BUCKET }}"

- name: Terraform Plan
  run: terraform plan -out=tfplan

- name: Terraform Apply
  run: terraform apply tfplan
  if: github.ref == 'refs/heads/main'
```

## Best Practices

1. **Always use workspaces** for feature branches and environments
2. **Use descriptive workspace names** (e.g., `john-feature-auth`, `sarah-vpc-updates`)
3. **Run `terraform fmt`** before committing
4. **Use pull requests** for all infrastructure changes
5. **Review plans carefully** before applying
6. **State locking** is automatic with DynamoDB - don't force unlock unless necessary
7. **Keep sensitive values** in environment variables or AWS Secrets Manager
8. **Clean up workspaces** after feature completion to avoid resource sprawl

## Troubleshooting

### State Lock Issues
```bash
# Only use if absolutely necessary
terraform force-unlock <lock-id>
```

### Backend Migration
```bash
terraform init -migrate-state
```

### Workspace Issues
```bash
# If workspace is corrupted, recreate it
terraform workspace delete <workspace-name>
terraform workspace new <workspace-name>
```

## Module Usage

Modules are located in the `modules/` directory and use standardized naming:

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  company     = var.company
  project     = var.project
  component   = "vpc"
  vpc_cidr    = "10.0.0.0/16"
  environment = var.environment
}

module "s3" {
  source = "./modules/s3"
  
  company     = var.company
  project     = var.project
  component   = "s3"
  bucket_name = "${local.base_name}-s3-data"
  environment = var.environment
}
```

This creates resources with names like:
- `bla-odyssey-dev-vpc-01`
- `bla-odyssey-dev-s3-data`