terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.vm_name
  description = var.vm_description
  node_name   = var.pve_node_name
  vm_id       = var.vm_id

  tags = var.tags

  clone {
    vm_id = var.vm_template_id
    full  = true
  }

  cpu {
    cores   = var.cpu_cores
    sockets = var.cpu_sockets
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size
    file_format  = "raw"
  }

  network_device {
    bridge = var.network_bridge
    vlan_id = var.network_vlan
  }

  dynamic "initialization" {
    for_each = var.ip_address != null ? [1] : []
    content {
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
        username = var.vm_username
        password = var.vm_password
      }
    }
  }

  on_boot = var.start_on_boot

  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }
}