# Setup Instructions

## Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.5
- Access to AWS account with permissions to create S3, DynamoDB, KMS, VPC, IAM, and other resources

## Quick Setup

### 1. Clone and Configure
```bash
git clone <repository-url>
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
```hcl
company     = "bla"
project     = "odyssey"
region      = "us-east-1"
environment = "dev"
vpc_cidr    = "10.0.0.0/16"
```

### 2. Bootstrap State Backend
```bash
cd bootstrap
terraform init
terraform apply
cd ..
```

### 3. Initialize and Deploy
Backend is already configured for bla-odyssey naming:

### 4. Initialize and Deploy
```bash
terraform init
terraform workspace new dev
terraform plan
terraform apply
```

## Multi-Environment Setup

For different environments (prod, staging, etc.):

```bash
# Bootstrap for prod
cd bootstrap
terraform apply -var="environment=prod"

# Update backend config and init
terraform init -backend-config="bucket=bla-odyssey-prod-terraform-state"
terraform workspace new prod
```

## Resource Naming
All resources follow: `<company>-<project>-<environment>-<component>-<identifier>`

Examples:
- VPC: `bla-odyssey-dev-vpc-01`
- S3: `bla-odyssey-dev-s3-data`