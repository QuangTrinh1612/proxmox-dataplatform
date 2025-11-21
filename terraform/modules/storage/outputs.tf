# Storage Module Outputs

output "storage_config" {
  description = "Storage configuration"
  value       = local.storage_config
}

output "storage_id" {
  description = "Storage identifier"
  value       = var.storage_id
}
