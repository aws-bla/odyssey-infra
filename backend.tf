terraform {
  backend "s3" {
    # Update these values after running bootstrap
    bucket         = "bla-odyssey-dev-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "bla-odyssey-dev-terraform-lock"
    encrypt        = true

    # Workspace-specific state files
    workspace_key_prefix = "workspaces"
  }
}