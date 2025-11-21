# Storage Module Variables

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "storage_id" {
  description = "Storage ID"
  type        = string
}

variable "storage_type" {
  description = "Storage type (dir, lvm, nfs, cifs, etc.)"
  type        = string
  default     = "dir"
}

variable "path" {
  description = "Storage path (for directory-based storage)"
  type        = string
  default     = null
}

variable "content_types" {
  description = "Content types allowed on this storage"
  type        = list(string)
  default     = ["images", "rootdir", "vztmpl", "iso"]
}

variable "shared" {
  description = "Mark storage as shared"
  type        = bool
  default     = false
}

variable "enabled" {
  description = "Enable this storage"
  type        = bool
  default     = true
}
