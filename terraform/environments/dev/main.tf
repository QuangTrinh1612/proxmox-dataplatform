# VM Template
module "template_vm" {
  source = "../../modules/template"
  
  proxmox_node = var.proxmox_node

  vm_template_id          = var.vm_template_id
  vm_template_name        = var.vm_template_name
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
  
  ssh_public_key_path = var.ssh_public_key_path
  
  tags = ["ubuntu", "vm-template"]
}

# Dev Lab VM
module "devlab_vm" {
  source = "../../modules/vm"
  
  proxmox_node = var.proxmox_node

  vm_id          = var.devlab_vm_id
  vm_name        = var.devlab_hostname
  vm_description = "Development Lab VM"
  
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
  
  ssh_public_key_path = var.ssh_public_key_path  # Add SSH key
  
  start_on_boot = true
  
  tags = ["devlab", "dev"]
}

# Extract IP address without CIDR notation
locals {
  devlab_ip = split("/", var.devlab_ip_address)[0]
}

# 1. Remove old SSH host key
resource "null_resource" "remove_old_ssh_key" {
  depends_on = [module.devlab_vm]

  provisioner "local-exec" {
    command = "ssh-keygen -R ${local.devlab_ip} 2>/dev/null || true"
  }

  triggers = {
    vm_id = module.devlab_vm.vm_id
  }
}

# 2. Wait for SSH to be ready
resource "null_resource" "wait_for_ssh" {
  depends_on = [null_resource.remove_old_ssh_key]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for SSH to be available on ${local.devlab_ip}..."
      timeout 300 bash -c 'until ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -i ${var.ssh_private_key_path} ${var.devlab_vm_username}@${local.devlab_ip} "echo SSH is ready"; do echo "Waiting..."; sleep 5; done'
      echo "SSH is now available!"
    EOT
  }

  triggers = {
    vm_id = module.devlab_vm.vm_id
  }
}

# Apply Ansible to configure the VM after creation
resource "null_resource" "ansible_install_minio" {
  depends_on = [module.devlab_vm]

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook \
        -i ${local.devlab_ip}, \
        -u ${var.devlab_vm_username} \
        --private-key ${var.ssh_private_key_path} \
        ../../../ansible/install_minio.yml
    EOT
  }

  triggers = {
    vm_id = module.devlab_vm.vm_id
  }
}