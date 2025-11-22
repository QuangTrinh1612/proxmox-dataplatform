# terraform {
#   backend "s3" {
#     bucket = "terraform-state"
#     key    = "homelab/terraform.tfstate"
#     region = "us-east-1"
#     
#     endpoint                    = "http://192.168.1.100:9000"
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     skip_region_validation      = true
#     force_path_style            = true
#     
#     access_key = "minio-access-key"
#     secret_key = "minio-secret-key"
#   }
# }