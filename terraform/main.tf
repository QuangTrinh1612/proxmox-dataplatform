resource "proxmox_virtual_environment_download_file" "debian_12_lxc_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "http://download.proxmox.com/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
}

resource "proxmox_virtual_environment_container" "minio" {
  description = "MinIO Object Storage for Terraform State"
  node_name   = var.proxmox_node
  vm_id       = var.minio_vmid

  initialization {
    hostname = var.minio_hostname

    ip_config {
      ipv4 {
        address = var.minio_ip_address
        gateway = var.network_gateway
      }
    }

    dns {
      server = var.dns_server
    }

    user_account {
      keys     = [trimspace(var.ssh_public_key)]
      password = var.sudo_password
    }
  }

  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_12_lxc_template.id
    type             = "debian"
  }

  disk {
    datastore_id = var.minio_storage_pool
    size         = var.minio_rootfs_size
  }

  cpu {
    cores = var.minio_cores
  }

  memory {
    dedicated = var.minio_memory
    swap      = var.minio_swap
  }

  features {
    nesting = true
  }

  startup {
    order      = "1"
    up_delay   = "30"
    down_delay = "30"
  }

  started = true

  # Wait for container to be ready
  provisioner "remote-exec" {
    inline = [
      "echo 'Container is ready'"
    ]

    connection {
      type     = "ssh"
      user     = "root"
      password = var.sudo_password
      host     = split("/", var.minio_ip_address)[0]
      timeout  = "2m"
    }
  }

  # Create sudo user
  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y sudo python3 python3-pip",
      "useradd -m -s /bin/bash ${var.sudo_username}",
      "echo '${var.sudo_username}:${var.sudo_password}' | chpasswd",
      "usermod -aG sudo ${var.sudo_username}",
      "mkdir -p /home/${var.sudo_username}/.ssh",
      "echo '${trimspace(var.ssh_public_key)}' > /home/${var.sudo_username}/.ssh/authorized_keys",
      "chown -R ${var.sudo_username}:${var.sudo_username} /home/${var.sudo_username}/.ssh",
      "chmod 700 /home/${var.sudo_username}/.ssh",
      "chmod 600 /home/${var.sudo_username}/.ssh/authorized_keys",
      "echo '${var.sudo_username} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/${var.sudo_username}",
      "chmod 440 /etc/sudoers.d/${var.sudo_username}"
    ]

    connection {
      type     = "ssh"
      user     = "root"
      password = var.sudo_password
      host     = split("/", var.minio_ip_address)[0]
      timeout  = "5m"
    }
  }

  # Trigger Ansible provisioning
  provisioner "local-exec" {
    command = <<-EOT
      sleep 10
      cd ../ansible && \
      ansible-playbook -i inventory.yml minio-setup.yml \
        -e "minio_host=${split("/", var.minio_ip_address)[0]}" \
        -e "ansible_user=${var.sudo_username}" \
        -e "ansible_become_pass=${var.sudo_password}"
    EOT
  }
}
