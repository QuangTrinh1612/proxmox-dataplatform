# LXC Module Main Configuration

terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_container" "container" {
  node_name   = var.pve_node_name
  vm_id       = var.container_id
  description = var.container_description
  tags        = var.tags

  unprivileged = var.unprivileged
  
  operating_system {
    template_file_id = var.ostemplate
  }

  cpu {
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  network_interface {
    name    = "eth0"
    bridge  = var.network_bridge
    vlan_id = var.network_vlan
  }

  initialization {
    hostname = var.container_name

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    dns {
      servers = [var.nameserver]
    }

    user_account {
      keys     = var.ssh_keys
      password = var.password
    }
  }

  features {
    nesting = var.features.nesting
    fuse    = var.features.fuse
  }

  started = true

  lifecycle {
    ignore_changes = [
      network_interface,
    ]
  }
}