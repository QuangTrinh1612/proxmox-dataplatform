# Example Terraform Backend Configuration for MinIO
# 
# This file shows how to configure Terraform to use the MinIO server
# as a backend for storing state files.
#
# Usage:
# 1. Create access keys in MinIO Console (http://<minio-ip>:9001)
# 2. Copy this configuration to your Terraform project
# 3. Update the values with your MinIO details
# 4. Run: terraform init -backend-config=backend.tfvars

terraform {
  backend "s3" {
    # MinIO endpoint configuration
    endpoint                    = "http://192.168.1.100:9000"  # Replace with your MinIO IP
    
    # Bucket and state file path
    bucket                      = "terraform-state"
    key                         = "proxmox/terraform.tfstate"  # Path within bucket
    
    # Region (required for S3 protocol)
    region                      = "us-east-1"
    
    # MinIO-specific settings
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    
    # Access credentials (DO NOT commit these!)
    # Use environment variables or backend config file instead:
    # export AWS_ACCESS_KEY_ID="your-minio-access-key"
    # export AWS_SECRET_ACCESS_KEY="your-minio-secret-key"
    # 
    # Or create a backend.tfvars file:
    # access_key = "your-minio-access-key"
    # secret_key = "your-minio-secret-key"
  }
}

# Alternative: Use backend config file
# Create backend.tfvars with:
# -----------------------------
# endpoint   = "http://192.168.1.100:9000"
# bucket     = "terraform-state"
# key        = "proxmox/terraform.tfstate"
# region     = "us-east-1"
# access_key = "your-minio-access-key"
# secret_key = "your-minio-secret-key"
# 
# Then run:
# terraform init -backend-config=backend.tfvars
