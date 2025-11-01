# Proxmox Provider Variables
variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
  default     = "https://proxmox.example.com:8006"
}

variable "proxmox_username" {
  description = "Proxmox username"
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Proxmox password"
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
  default     = "pve"
}

variable "proxmox_datastore" {
  description = "Proxmox storage location"
  type        = string
  default     = "local-lvm"
}

# MinIO Container Variables
variable "minio_vmid" {
  description = "VM ID for MinIO container"
  type        = number
  default     = 200
}

variable "minio_hostname" {
  description = "Hostname for MinIO container"
  type        = string
  default     = "minio"
}

variable "minio_ip_address" {
  description = "Static IP address for MinIO (CIDR notation)"
  type        = string
  default     = "192.168.1.200/24"
}

variable "minio_gateway" {
  description = "Gateway IP address"
  type        = string
  default     = "192.168.1.1"
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "ssh_public_keys" {
  description = "SSH public keys for root user"
  type        = list(string)
  default     = []
}

variable "root_password" {
  description = "Root password for the container"
  type        = string
  sensitive   = true
}

variable "minio_disk_size" {
  description = "Disk size for MinIO container in GB"
  type        = number
  default     = 50
}

variable "minio_cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "minio_memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}