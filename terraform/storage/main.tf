# Download Debian LXC template if not exists
resource "proxmox_virtual_environment_download_file" "debian_container_template" {
  content_type = "vztmpl"
  datastore_id = var.proxmox_datastore
  node_name    = var.proxmox_node

  url = "http://download.proxmox.com/images/system/debian-13-standard_13.1-2_amd64.tar.zst"
}

# Create LXC container for MinIO
resource "proxmox_virtual_environment_container" "minio_container" {
  description = "MinIO S3-compatible storage server"
  node_name   = var.proxmox_node
  vm_id       = var.minio_vmid

  initialization {
    hostname = var.minio_hostname

    ip_config {
      ipv4 {
        address = var.minio_ip_address
        gateway = var.minio_gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      keys     = var.ssh_public_keys
      password = var.root_password
    }
  }

  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_container_template.id
    type             = "debian"
  }

  disk {
    datastore_id = var.proxmox_datastore
    size         = var.minio_disk_size
  }

  cpu {
    cores = var.minio_cpu_cores
  }

  memory {
    dedicated = var.minio_memory
  }

  features {
    nesting = true
  }

  start_on_boot = true
  started       = true

  # Wait for container to be ready
  provisioner "local-exec" {
    command = "sleep 30"
  }

  # Trigger Ansible provisioning
  provisioner "local-exec" {
    command = "ansible-playbook -i '${var.minio_ip_address},' -u root ansible/minio-playbook.yml"
  }
}

# Output important information
output "minio_container_id" {
  value       = proxmox_virtual_environment_container.minio_container.vm_id
  description = "The ID of the MinIO container"
}

output "minio_ip_address" {
  value       = var.minio_ip_address
  description = "IP address of the MinIO server"
}

output "minio_api_endpoint" {
  value       = "http://${var.minio_ip_address}:9000"
  description = "MinIO API endpoint"
}

output "minio_console_url" {
  value       = "http://${var.minio_ip_address}:9001"
  description = "MinIO Console URL"
}