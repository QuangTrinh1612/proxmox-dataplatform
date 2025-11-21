# Network Module Variables

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "bridge_ports" {
  description = "Bridge ports (optional, for advanced configuration)"
  type        = string
  default     = ""
}

variable "vlan_aware" {
  description = "Enable VLAN awareness"
  type        = bool
  default     = true
}

variable "firewall_enabled" {
  description = "Enable firewall"
  type        = bool
  default     = false
}

variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    action  = string
    type    = string
    comment = string
    dport   = optional(string)
    proto   = optional(string)
    source  = optional(string)
    dest    = optional(string)
  }))
  default = []
}
