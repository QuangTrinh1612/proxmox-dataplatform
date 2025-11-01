# Proxmox Connection Variables
variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://192.168.1.100:8006/api2/json"
}

variable "proxmox_user" {
  description = "Proxmox API user"
  type        = string
  default     = "terraform@pve"
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Disable TLS verification"
  type        = bool
  default     = false
}

# LXC Container Variables
variable "target_node" {
  description = "Target Proxmox node"
  type        = string
  default     = "pve"
}

variable "lxc_template" {
  description = "LXC template storage location"
  type        = string
  default     = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "lxc_storage" {
  description = "Storage for LXC rootfs"
  type        = string
  default     = "local-lvm"
}

variable "lxc_hostname" {
  description = "Hostname for MinIO container"
  type        = string
  default     = "minio"
}

variable "lxc_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "lxc_memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "lxc_disk_size" {
  description = "Root disk size"
  type        = string
  default     = "20G"
}

variable "lxc_ip_address" {
  description = "Static IP address for MinIO"
  type        = string
  default     = "192.168.1.100/24"
}

variable "lxc_gateway" {
  description = "Gateway IP"
  type        = string
  default     = "192.168.1.1"
}

variable "lxc_nameserver" {
  description = "DNS nameserver"
  type        = string
  default     = "8.8.8.8"
}

variable "lxc_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

# MinIO Variables
variable "minio_root_user" {
  description = "MinIO root username"
  type        = string
  default     = "admin"
}

variable "minio_root_password" {
  description = "MinIO root password (min 8 chars)"
  type        = string
  sensitive   = true
}

variable "minio_console_port" {
  description = "MinIO console port"
  type        = number
  default     = 9001
}

variable "minio_api_port" {
  description = "MinIO API port"
  type        = number
  default     = 9000
}

variable "minio_bucket_name" {
  description = "Bucket name for Terraform state"
  type        = string
  default     = "terraform-state"
}

variable "ssh_public_key" {
  description = "SSH public key for container access"
  type        = string
  default     = ""
}