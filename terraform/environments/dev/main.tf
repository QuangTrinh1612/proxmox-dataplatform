# VM Template
module "template_vm" {
  source            = "../../modules/template"
  
  pve_node_name     = var.pve_node_name

  vm_template_id    = var.vm_template_id
  vm_template_name  = var.vm_template_name
  vm_template_description = var.vm_template_description
  
  vm_username = var.devlab_vm_username
  vm_password = var.devlab_vm_password
  
  cpu_cores   = var.devlab_cpu_cores
  cpu_sockets = var.devlab_cpu_sockets
  memory      = var.devlab_memory
  disk_size   = var.devlab_disk_size
  
  datastore_id   = var.datastore_id
  network_bridge = var.network_bridge
  network_vlan   = var.network_vlan
  
  tags = ["ubuntu", "vm-template"]
}

# Dev Lab VM
module "devlab_vm" {
  source = "../../modules/vm"
  
  pve_node_name = var.pve_node_name

  vm_id         = var.devlab_vm_id
  vm_name       = var.devlab_hostname
  vm_description = "Development Lab VM with Spark"
  
  vm_username = var.devlab_vm_username
  vm_password = var.devlab_vm_password
  
  cpu_cores   = var.devlab_cpu_cores
  cpu_sockets = var.devlab_cpu_sockets
  memory      = var.devlab_memory
  disk_size   = var.devlab_disk_size
  
  datastore_id   = var.datastore_id
  network_bridge = var.network_bridge
  network_vlan   = var.network_vlan
  
  vm_template_id = module.template_vm.vm_template_id

  ip_address = var.devlab_ip_address
  gateway    = var.gateway
  nameserver = var.nameserver
  
  start_on_boot = true
  
  tags = ["devlab", "spark", "dev"]
}