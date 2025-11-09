# LXC Module Variables

variable "pve_node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "container_id" {
  description = "Container ID"
  type        = number
  default     = null
}

variable "container_name" {
  description = "Container hostname"
  type        = string
}

variable "container_description" {
  description = "Container description"
  type        = string
  default     = "Managed by Terraform"
}

variable "ostemplate" {
  description = "OS template (e.g., 'local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst')"
  type        = string
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "swap" {
  description = "Swap in MB"
  type        = number
  default     = 512
}

variable "disk_size" {
  description = "Root disk size in GB"
  type        = number
  default     = 8
}

variable "datastore_id" {
  description = "Storage pool name"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "network_vlan" {
  description = "VLAN tag"
  type        = number
  default     = null
}

variable "ip_address" {
  description = "Static IP address (CIDR notation, e.g., '192.168.1.100/24')"
  type        = string
}

variable "gateway" {
  description = "Gateway IP address"
  type        = string
}

variable "nameserver" {
  description = "DNS nameserver"
  type        = string
  default     = "8.8.8.8"
}

variable "ssh_keys" {
  description = "SSH public keys"
  type        = list(string)
  default     = []
}

variable "password" {
  description = "Root password"
  type        = string
  sensitive   = true
  default     = null
}

variable "unprivileged" {
  description = "Run as unprivileged container"
  type        = bool
  default     = true
}

variable "start_on_boot" {
  description = "Start container on boot"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for the container"
  type        = list(string)
  default     = []
}

variable "features" {
  description = "Container features"
  type = object({
    nesting = bool
    fuse    = bool
  })
  default = {
    nesting = false
    fuse    = false
  }
}