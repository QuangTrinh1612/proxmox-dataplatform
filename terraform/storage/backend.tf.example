# Example: How to use MinIO as Terraform S3 backend
# Copy this to your Terraform project's backend.tf

terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "my-project/terraform.tfstate"
    region = "us-east-1"  # Can be any value for MinIO

    # MinIO endpoint
    endpoint = "http://192.168.1.200:9000"

    # Credentials
    access_key = "minioadmin"
    secret_key = "minioadmin123"

    # MinIO-specific settings
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}

# Alternative: Using environment variables for credentials
# Set these in your shell:
# export AWS_ACCESS_KEY_ID=minioadmin
# export AWS_SECRET_ACCESS_KEY=minioadmin123
# export AWS_ENDPOINT_URL_S3=http://192.168.1.200:9000
#
# Then use simplified backend config:
# terraform {
#   backend "s3" {
#     bucket                      = "terraform-state"
#     key                         = "my-project/terraform.tfstate"
#     region                      = "us-east-1"
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     skip_region_validation      = true
#     force_path_style            = true
#   }
# }