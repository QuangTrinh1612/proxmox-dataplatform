output "minio_ip" {
  description = "MinIO server IP address"
  value       = local.minio_ip
}

output "minio_api_url" {
  description = "MinIO API endpoint"
  value       = "http://${local.minio_ip}:${var.minio_api_port}"
}

output "minio_console_url" {
  description = "MinIO Console URL"
  value       = "http://${local.minio_ip}:${var.minio_console_port}"
}

output "minio_bucket" {
  description = "Terraform state bucket name"
  value       = var.minio_bucket_name
}

output "minio_root_user" {
  description = "MinIO root username"
  value       = var.minio_root_user
}

output "minio_root_password" {
  description = "MinIO root password"
  value       = local.minio_password
  sensitive   = true
}

output "container_id" {
  description = "Proxmox LXC container ID"
  value       = proxmox_lxc.minio.vmid
}

output "backend_config" {
  description = "Backend configuration for migrating state to MinIO"
  value = <<-EOT
    terraform {
      backend "s3" {
        bucket                      = "${var.minio_bucket_name}"
        key                         = "terraform.tfstate"
        region                      = "us-east-1"
        endpoint                    = "http://${local.minio_ip}:${var.minio_api_port}"
        access_key                  = "${var.minio_root_user}"
        secret_key                  = "<your-minio-password>"
        skip_credentials_validation = true
        skip_metadata_api_check     = true
        skip_region_validation      = true
        force_path_style            = true
      }
    }
  EOT
}