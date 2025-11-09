terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name      = var.vm_template_name
  node_name = var.pve_node_name
  vm_id     = var.vm_template_id

  template = true
  started  = false

  machine     = "q35"
  bios        = "ovmf"
  description = var.vm_template_description

  cpu {
    cores = var.cpu_cores
    sockets = var.cpu_sockets
  }

  memory {
    dedicated = var.memory
  }

  efi_disk {
    datastore_id = var.datastore_id
    type         = "4m"
  }

  disk {
    datastore_id = var.datastore_id
    file_id      = proxmox_virtual_environment_download_file.cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = var.vm_username
      password = var.vm_password
    }
    # user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  network_device {
    bridge = var.network_bridge
    vlan_id = var.network_vlan
  }

  tags = var.tags

}

resource "proxmox_virtual_environment_download_file" "cloud_image" {
    content_type = "iso"
    datastore_id = "local"
    node_name    = var.pve_node_name
    url          = var.vm_image_url
    file_name    = var.vm_image_file_name
    overwrite    = true
}