# Network Module Main Configuration

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }
}

# This module provides network configuration helpers
# Network interfaces are typically configured per VM/LXC
# This can be extended for advanced network management

# Placeholder for firewall configuration
# Firewall rules can be added here based on requirements

locals {
  network_config = {
    vlan_aware        = var.vlan_aware
    firewall_enabled  = var.firewall_enabled
    bridge_ports      = var.bridge_ports
  }
}
