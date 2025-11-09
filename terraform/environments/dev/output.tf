# Dev Environment - Outputs

output "devlab_vm_id" {
  description = "Dev Lab VM ID"
  value       = module.devlab_vm.vm_id
}

output "devlab_ip_address" {
  description = "Dev Lab IP address"
  value       = module.devlab_vm.vm_ip_address
}