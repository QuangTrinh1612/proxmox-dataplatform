# LXC Module Outputs

output "container_id" {
  description = "The ID of the container"
  value       = proxmox_virtual_environment_container.container.id
}

output "container_name" {
  description = "The name of the container"
  value       = var.container_name
}

output "container_ip_address" {
  description = "The IP address of the container"
  value       = var.ip_address
}

output "container_node" {
  description = "The Proxmox node hosting the container"
  value       = proxmox_virtual_environment_container.container.node_name
}