# Storage Module Main Configuration

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }
}

# Storage configuration
# This module provides storage management helpers
# Can be extended to manage different storage types (NFS, CIFS, LVM, etc.)

locals {
  storage_config = {
    storage_id    = var.storage_id
    storage_type  = var.storage_type
    path          = var.path
    content_types = var.content_types
    shared        = var.shared
    enabled       = var.enabled
  }
}
