output "minio_container_id" {
  description = "MinIO container ID"
  value       = proxmox_virtual_environment_container.minio.vm_id
}

output "minio_ip_address" {
  description = "MinIO IP address"
  value       = split("/", var.minio_ip_address)[0]
}

output "minio_console_url" {
  description = "MinIO Console URL"
  value       = "http://${split("/", var.minio_ip_address)[0]}:9001"
}

output "minio_api_url" {
  description = "MinIO API URL"
  value       = "http://${split("/", var.minio_ip_address)[0]}:9000"
}

output "sudo_username" {
  description = "Sudo user created for deployment"
  value       = var.sudo_username
}

output "next_steps" {
  description = "Next steps to configure Terraform backend"
  value       = <<-EOT
    1. Access MinIO Console at: http://${split("/", var.minio_ip_address)[0]}:9001
    2. Login with credentials (check ansible/group_vars/all.yml)
    3. Create a bucket named 'terraform-state'
    4. Create an access key for Terraform
    5. Configure your Terraform backend with:
       - endpoint: http://${split("/", var.minio_ip_address)[0]}:9000
       - bucket: terraform-state
       - key: path/to/terraform.tfstate
       - region: us-east-1 (or your configured region)
  EOT
}
