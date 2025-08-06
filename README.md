# Odyssey Full-Stack Infrastructure

This repository contains Terraform infrastructure as code for a complete full-stack web application with React frontend, Python Flask backend, AI processing service, and AWS CodePipeline CI/CD.

## Architecture Overview

![Architecture Diagram](docs/architecture.jpg)

### Key Architecture Components

- **Frontend**: React app served via CloudFront + S3
- **Backend**: Python Flask service via public ALB
- **AI Service**: Internal processing service via internal ALB
- **Same ECS Cluster**: Both backend and AI services run in same cluster, private subnets
- **Network Isolation**: AI service only accessible through internal ALB from backend
- **CI/CD**: Separate pipelines for frontend and services with automated ECS deployment

## Stack Components

### Frontend (React)
- **S3**: Static website hosting
- **CloudFront**: CDN with default CloudFront domain
- **CodePipeline**: Automated deployment from GitHub

### Storage (S3)
- **Input Bucket**: `bla-odyssey-dev-s3-input` - For storing input files (requirements, business docs)
- **Output Bucket**: `bla-odyssey-dev-s3-output` - For storing generated artifacts (code, reports, test scenarios)
- **Access Control**: ECS services have read access to input bucket, full access to output bucket

### Backend Services (Python Flask)
- **ECS Fargate**: Containerized services
- **ALB**: Load balancing with HTTP (default ALB domain)
- **ECR**: Container registry
- **Secrets Manager**: Secure configuration
- **CodePipeline**: Docker build and deployment

### AI Processing Service (Internal)
- **ECS Fargate**: Containerized AI service in same cluster as backend
- **Internal ALB**: Private load balancer in private subnets (HTTP only)
- **Security Groups**: Backend-to-AI communication only
- **No Public Access**: Accessible only by Flask backend through internal ALB
- **Same Subnets**: Deployed in same private subnets as backend service
- **Direct Bedrock Integration**: Queries Amazon Bedrock Knowledge Base directly using boto3

### CI/CD Infrastructure
- **CodePipeline**: Orchestrates deployments
- **CodeBuild**: Builds and deploys applications
- **CodeStar Connections**: GitHub integration
- **IAM**: Service roles with least privilege

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5
- GitHub repository with your application code

## Quick Start

### 1. Configure Variables

```bash
# Copy and edit terraform variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your configuration
vim terraform.tfvars
```

Required configuration:
```hcl
github_owner = "your-username"  # GitHub username/organization
github_repo = "your-repo-name"  # Repository name
```

### 2. Bootstrap Infrastructure

```bash
# Bootstrap remote state (one-time setup)
cd bootstrap
terraform init
terraform apply

# Initialize main infrastructure
cd ..
terraform init
terraform workspace new dev
terraform workspace select dev
```

### 3. Deploy Infrastructure

```bash
# Plan and apply infrastructure
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Connect GitHub Repository

After deployment, you need to activate the GitHub connection:

1. Go to AWS Console → Developer Tools → Settings → Connections
2. Find your connection (e.g., `bla-odyssey-dev-github-connection`)
3. Click "Update pending connection"
4. Complete GitHub OAuth flow
5. Connection status should change to "Available"

### 5. Add Buildspec Files to Repository

Copy the buildspec files to your repository root:
- `buildspec-frontend.yml` - React frontend deployment
- `buildspec-backend.yml` - Backend Docker deployment  
- `buildspec-ai.yml` - AI service Docker deployment

## Resource Naming Convention

All resources follow the pattern: `bla-odyssey-<workspace>-<component>-<identifier>`

Examples:
- VPC: `bla-odyssey-dev-vpc-01`
- S3 Bucket: `bla-odyssey-dev-s3-frontend`
- ECS Cluster: `bla-odyssey-dev-cluster`
- Pipeline: `bla-odyssey-dev-frontend-pipeline`

## CI/CD Pipelines

### Frontend Pipeline
1. **Source**: GitHub repository trigger
2. **Build**: CodeBuild project
   - Install Node.js dependencies
   - Build React application
   - Sync to S3 bucket
   - Invalidate CloudFront cache

### Backend Pipeline
1. **Source**: GitHub repository trigger
2. **Build**: CodeBuild project
   - Build Docker image
   - Push to ECR repository
   - ECS performs rolling deployment

### AI Service Pipeline
1. **Source**: GitHub repository trigger
2. **Build**: CodeBuild project
   - Build Docker image
   - Push to ECR repository
   - ECS performs rolling deployment

**Note**: ECS deployment is **not automatic** after ECR push - it's explicitly triggered by CodeBuild

## Accessing Your Applications

After deployment, your applications will be available at:

- **Frontend**: CloudFront default domain (from Terraform output `frontend_cloudfront_domain`)
- **Backend**: ALB default domain (from Terraform output `backend_alb_dns`)
- **AI Service**: Internal only (from Terraform output `ai_internal_alb_dns`)

Get the URLs and bucket names from Terraform outputs:
```bash
terraform output frontend_cloudfront_domain
terraform output backend_alb_dns
terraform output ai_internal_alb_dns
terraform output input_bucket_name
terraform output output_bucket_name
```

## Knowledge Base Integration

### Amazon Bedrock Knowledge Base MCP Integration

The AI Processing Service uses an MCP (Model Context Protocol) sidecar container to query Amazon Bedrock Knowledge Bases:

- **MCP Sidecar**: AWS Labs official MCP server (`public.ecr.aws/awslabs-mcp/awslabs/bedrock-kb-retrieval-mcp-server:latest`)
- **Dynamic KB IDs**: Knowledge Base ID provided per-request, no hardcoded configurations
- **Auto-Discovery**: MCP server discovers available KBs using injected AWS credentials
- **Secure Credentials**: Flat AWS credentials stored in Secrets Manager
- **Container Communication**: AI service calls MCP sidecar via `http://localhost:7000`

### MCP Server Configuration

The MCP sidecar container is configured with:

```hcl
# Essential environment variables
AWS_REGION = "us-east-1"
FASTMCP_LOG_LEVEL = "ERROR"
BEDROCK_KB_RERANKING_ENABLED = "false"

# AWS credentials injected as secrets
AWS_ACCESS_KEY_ID = "<from-secrets-manager>"
AWS_SECRET_ACCESS_KEY = "<from-secrets-manager>"
# AWS_SESSION_TOKEN = "<optional-for-temporary-creds>"
```

### AWS Credentials Management

```bash
# Update AWS credentials for MCP server
aws secretsmanager update-secret \
  --secret-id bla-odyssey-dev-mcp-credentials \
  --secret-string '{
    "AWS_ACCESS_KEY_ID": "AKIA...",
    "AWS_SECRET_ACCESS_KEY": "your-secret-key"
  }'

# For temporary credentials, include session token
aws secretsmanager update-secret \
  --secret-id bla-odyssey-dev-mcp-credentials \
  --secret-string '{
    "AWS_ACCESS_KEY_ID": "ASIA...",
    "AWS_SECRET_ACCESS_KEY": "your-secret-key",
    "AWS_SESSION_TOKEN": "your-session-token"
  }'

# Restart AI service to pick up credential changes
aws ecs update-service --cluster bla-odyssey-dev-cluster --service bla-odyssey-dev-ai-service --force-new-deployment
```

### Using Knowledge Base in AI Service

```python
# Query specific Knowledge Base (KB ID required)
response = requests.post(
    "http://your-ai-alb-domain/kb/query",
    json={
        "query": "your search query",
        "knowledgeBaseId": "kb-123456789"  # Required: provide KB ID
    }
)

# List available Knowledge Bases (auto-discovered)
response = requests.get("http://your-ai-alb-domain/kb/list")

# AI processing with KB enhancement
response = requests.post(
    "http://your-ai-alb-domain/ai/process",
    json={
        "query": "your search query",
        "knowledgeBaseId": "kb-123456789"
    }
)
```

### API Endpoints

- `POST /kb/query`: Query Knowledge Base via MCP server (requires `knowledgeBaseId`)
- `GET /kb/list`: List auto-discovered Knowledge Bases
- `GET /health`: Health check for AI service
- `POST /ai/process`: AI processing with optional KB enhancement

### MCP Server Architecture

```
┌─────────────────┐    HTTP     ┌─────────────────┐    AWS API    ┌──────────────────┐
│   AI Service    │ ──────────► │   MCP Server    │ ────────────► │ Bedrock KB API   │
│   (Port 8000)   │ localhost   │   (Port 7000)   │               │                  │
└─────────────────┘   :7000     └─────────────────┘               └──────────────────┘
        │                               │
        │                               │
        ▼                               ▼
┌─────────────────┐               ┌─────────────────┐
│ App Secrets     │               │ MCP Credentials │
│ (AI Config)     │               │ (AWS Creds)     │
└─────────────────┘               └─────────────────┘
```

## Secrets Management

### Managing Application Secrets

```bash
# Update application secrets in AWS Secrets Manager
aws secretsmanager update-secret \
  --secret-id bla-odyssey-dev-app-secrets \
  --secret-string '{
    "database_url": "postgresql://user:pass@host:5432/db",
    "api_key": "your-api-key",
    "jwt_secret": "your-jwt-secret",
    "redis_url": "redis://host:6379"
  }'

# Update MCP server AWS credentials (flat structure)
aws secretsmanager update-secret \
  --secret-id bla-odyssey-dev-mcp-credentials \
  --secret-string '{
    "AWS_ACCESS_KEY_ID": "AKIA...",
    "AWS_SECRET_ACCESS_KEY": "your-secret-access-key"
  }'

# For temporary credentials (STS assume role)
aws secretsmanager update-secret \
  --secret-id bla-odyssey-dev-mcp-credentials \
  --secret-string '{
    "AWS_ACCESS_KEY_ID": "ASIA...",
    "AWS_SECRET_ACCESS_KEY": "your-secret-access-key",
    "AWS_SESSION_TOKEN": "your-session-token"
  }'
```

### Accessing Secrets in Applications

Secrets are automatically injected into ECS containers:

```python
# Python example
import json
import os
import boto3

def get_secrets():
    secrets_client = boto3.client('secretsmanager')
    secret_name = os.environ.get('SECRETS_NAME', 'bla-odyssey-dev-app-secrets')
    response = secrets_client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

secrets = get_secrets()
database_url = secrets['database_url']
```

## Development Workflow

### Local Development

```bash
# Frontend development
cd odyssey-app/frontend
npm start  # Runs on http://localhost:3000

# Backend development
cd odyssey-app/backend
pip install -r requirements.txt
python app.py  # Runs on http://localhost:5000

# AI service development
cd odyssey-services/ai-service
pip install -r requirements.txt
python app.py  # Runs on http://localhost:8000
```

### Triggering Deployments

Deployments are automatically triggered by pushing to the configured branch:

```bash
# Make changes to your code
git add .
git commit -m "Update application"
git push origin main  # Triggers all relevant pipelines
```

## Monitoring and Troubleshooting

### Pipeline Status

Monitor pipeline status in AWS Console:
- CodePipeline → Pipelines
- CodeBuild → Build projects

### CloudWatch Logs

```bash
# View ECS service logs
aws logs tail /ecs/bla-odyssey-dev-backend --follow
aws logs tail /ecs/bla-odyssey-dev-ai --follow

# View CodeBuild logs
aws logs tail /aws/codebuild/bla-odyssey-dev-frontend-build --follow
```

### Health Checks

- Frontend: Use CloudFront domain from Terraform output
- Backend: Use ALB domain from Terraform output + `/health`
- AI Service: Internal only - accessible via backend at `/api/ai/process`

### Common Issues

1. **GitHub connection pending**: Complete OAuth flow in AWS Console
2. **Build failures**: Check CodeBuild logs and buildspec files
3. **ECS deployment issues**: Verify ECR images and ECS service configuration

## Security Architecture

### Network Security
- **Public Tier**: CloudFront, Public ALB (Backend only)
- **Private Tier**: ECS services, Internal ALB (AI service)
- **Security Groups**: Least-privilege access between tiers

### AI Service Security
- **Internal Only**: No public internet access
- **Backend Proxy**: All AI requests go through Flask backend
- **Security Group Rules**:
  - Backend ECS → AI Internal ALB (port 8000)
  - AI ECS ← Internal ALB only
  - No direct frontend → AI communication

## Security Best Practices

- S3 bucket is private (CloudFront access only)
- ECS services in private subnets
- AI service isolated from public internet
- Secrets stored in AWS Secrets Manager
- IAM roles follow least-privilege principle
- CodeStar Connections for secure GitHub integration
- No hardcoded secrets or personal access tokens
- Security groups follow least-privilege access patterns
- Infrastructure uses parameterized configuration

## Cost Optimization

- ECS Fargate with minimal CPU/memory allocation
- CloudFront caching reduces origin requests
- S3 lifecycle policies for old versions
- ECR lifecycle policies for old images
- CloudWatch log retention policies
- CodeBuild on-demand pricing

## Infrastructure Validation

The infrastructure follows AWS best practices for security, maintainability, and resource management. See validation reports for detailed analysis.

## Cleanup

```bash
# Destroy infrastructure
terraform destroy

# Clean up bootstrap resources
cd bootstrap
terraform destroy
```

## Module Structure

```
modules/
├── vpc/          # VPC with public/private subnets
├── iam/          # IAM roles and policies
├── s3/           # S3 bucket for frontend
├── cloudfront/   # CloudFront distribution
├── secrets/      # Secrets Manager
├── ecr/          # Container registries
├── alb/          # Application Load Balancers
├── ecs/          # ECS cluster and services
├── codebuild/    # CodeBuild projects
└── codepipeline/ # CodePipeline workflows
```

Each module is self-contained with variables, outputs, and proper resource tagging.