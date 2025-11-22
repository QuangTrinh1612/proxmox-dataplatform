variable "proxmox_node" {
    type = string
    description = "Proxmox VE node name"
    default = "proxmox"
}

variable "vm_username" {
    type = string
    description = "Proxmox VM User Name"
    default = "vm_user"
}

variable "vm_password" {
    type = string
    description = "Proxmox VM User Password"
    sensitive = true
}

variable "datastore_id" {
    type = string
    description = "Proxmox Datastore ID"
    default = "local-lvm"
}

variable "vm_template_id" {
  description = "VM Template ID"
  type        = number
  default     = null
}

# VM Module Variables
variable "vm_id" {
  description = "VM ID"
  type        = number
  default     = null
}

variable "vm_name" {
  description = "VM name"
  type        = string
}

variable "vm_description" {
  description = "VM description"
  type        = string
  default     = "Managed by Terraform"
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "cpu_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Disk size (e.g., '32G')"
  type        = number
  default     = 32
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
  default     = null
}

variable "gateway" {
  description = "Gateway IP address"
  type        = string
  default     = null
}

variable "nameserver" {
  description = "DNS nameserver"
  type        = string
  default     = "8.8.8.8"
}

variable "start_on_boot" {
  description = "Start VM on boot"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for the VM"
  type        = list(string)
  default     = []
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}