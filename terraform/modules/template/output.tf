# VM Module Outputs
output "vm_template_id" {
  description = "The ID of the VM"
  value       = proxmox_virtual_environment_vm.ubuntu_template.id
}

output "vm_template_name" {
  description = "The name of the VM"
  value       = proxmox_virtual_environment_vm.ubuntu_template.name
}