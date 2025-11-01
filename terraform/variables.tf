variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox VE username (e.g., root@pam)"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox VE password"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = false
}

variable "proxmox_ssh_username" {
  description = "SSH username for Proxmox host"
  type        = string
  default     = "root"
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "minio_vmid" {
  description = "VM ID for MinIO LXC container"
  type        = number
  default     = 200
}

variable "minio_hostname" {
  description = "Hostname for MinIO container"
  type        = string
  default     = "minio"
}

variable "minio_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "minio_memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "minio_swap" {
  description = "Swap in MB"
  type        = number
  default     = 512
}

variable "minio_rootfs_size" {
  description = "Root filesystem size"
  type        = string
  default     = "8G"
}

variable "minio_storage_pool" {
  description = "Storage pool for container"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "minio_ip_address" {
  description = "Static IP address for MinIO (CIDR format, e.g., 192.168.1.100/24)"
  type        = string
}

variable "network_gateway" {
  description = "Network gateway"
  type        = string
}

variable "dns_server" {
  description = "DNS server"
  type        = string
  default     = "8.8.8.8"
}

variable "ssh_public_key" {
  description = "SSH public key for the sudo user"
  type        = string
}

variable "sudo_username" {
  description = "Username for the sudo user"
  type        = string
  default     = "deploy"
}

variable "sudo_password" {
  description = "Password for the sudo user"
  type        = string
  sensitive   = true
}
