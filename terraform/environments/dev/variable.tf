# Dev Environment - Variables
variable "pve_endpoint" {
    type = string
    description = "Proxmox VE API endpoint URL"
    default = "https://192.168.1.100:8006/"
}

variable "pve_username" {
    type = string
    description = "Proxmox VE username"
    default = "root"
}

variable "pve_password" {
    type = string
    description = "Proxmox VE password"
    sensitive = true
}

# variable "pve_token_id" {
#   description = "Proxmox API Token ID"
#   type        = string
# }

# variable "pve_token_secret" {
#   description = "Proxmox API Token Secret"
#   type        = string
#   sensitive   = true
# }

variable "vm_image_url" {
  description = "VM Template URL"
  type = string
  default = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "vm_image_file_name" {
  description = "VM Template File Name"
  type = string
  default = "jammy-server-cloudimg-amd64.img"
}

variable "proxmox_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = true
}

variable "pve_node_name" {
  description = "Proxmox node name"
  type        = string
}

# Network Configuration
variable "network_bridge" {
  description = "Network bridge name"
  type        = string
  default     = "vmbr0"
}

variable "network_vlan" {
  description = "VLAN tag"
  type        = number
  default     = null
}

variable "gateway" {
  description = "Network gateway"
  type        = string
  default     = "192.168.1.1"
}

variable "nameserver" {
  description = "DNS nameserver"
  type        = string
  default     = "8.8.8.8"
}

# Storage Configuration
variable "datastore_id" {
  description = "Default storage pool"
  type        = string
  default     = "local-lvm"
}

# SSH Keys
variable "ssh_public_keys" {
  description = "SSH public keys for access"
  type        = list(string)
  default     = []
}

# Dev Lab VM Configuration
variable "devlab_vm_id" {
  description = "Dev Lab VM ID"
  type        = number
  default     = 100
}

# Dev Lab VM Configuration
variable "vm_template_id" {
  description = "Dev Lab VM ID"
  type        = number
  default     = 100
}

variable "devlab_hostname" {
  description = "Dev Lab hostname"
  type        = string
  default     = "devlab"
}

variable "vm_template_name" {
  description = "VM Template Name"
  type        = string
  default     = "ubuntu-template"
}

variable "vm_template_description" {
  description = "VM Template Description"
  type        = string
  default     = "Ubuntu VM Template"
}

variable "devlab_ip_address" {
  description = "Dev Lab IP address (CIDR)"
  type        = string
  default     = "192.168.1.100/24"
}

variable "devlab_cpu_cores" {
  description = "Dev Lab CPU cores"
  type        = number
  default     = 4
}

variable "devlab_cpu_sockets" {
  description = "Dev Lab CPU sockets"
  type        = number
  default     = 1
}

variable "devlab_memory" {
  description = "Dev Lab memory in MB"
  type        = number
  default     = 8192
}

variable "devlab_disk_size" {
  description = "Dev Lab disk size"
  type        = number
  default     = 50
}

variable "devlab_vm_username" {
    type = string
    description = "DevLab VM User Name"
    default = "vm_user"
}

variable "devlab_vm_password" {
    type = string
    description = "DevLab VM User Password"
    sensitive = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key file for Ansible"
  type        = string
  default     = "~/.ssh/id_rsa"
}