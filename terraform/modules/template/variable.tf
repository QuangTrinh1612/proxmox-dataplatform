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

variable "vm_template_name" {
  description = "VM Template Name"
  type        = string
  default     = "ubuntu-template"
}

variable "vm_template_id" {
  description = "VM Template ID"
  type        = number
  default     = null
}

variable "vm_template_description" {
  description = "VM Template Description"
  type        = string
  default     = "Ubuntu VM Template"
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

variable "tags" {
  description = "Tags for the VM template"
  type        = list(string)
  default     = []
}

variable "vm_image_url" {
  description = "VM Template URL"
  type = string
  default = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "vm_image_file_name" {
  description = "VM Template File Name"
  type = string
  default = "jammy-server-cloudimg-amdc64.img"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}