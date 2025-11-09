# VM Module Outputs
output "vm_id" {
  description = "The ID of the VM"
  value       = proxmox_virtual_environment_vm.vm.id
}

output "vm_name" {
  description = "The name of the VM"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "vm_ip_address" {
  description = "The IP address of the VM"
  value       = var.ip_address
}

output "vm_node" {
  description = "The Proxmox node hosting the VM"
  value       = proxmox_virtual_environment_vm.vm.node_name
}