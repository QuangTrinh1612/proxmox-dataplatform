# Generate random password if not provided
resource "random_password" "minio_password" {
  count   = var.minio_root_password == "" ? 1 : 0
  length  = 16
  special = true
}

locals {
  minio_password = var.minio_root_password != "" ? var.minio_root_password : random_password.minio_password[0].result
  minio_ip       = split("/", var.lxc_ip_address)[0]
}

# MinIO LXC Container
resource "proxmox_lxc" "minio" {
  target_node  = var.target_node
  hostname     = var.lxc_hostname
  ostemplate   = var.lxc_template
  unprivileged = true
  onboot       = true
  start        = true

  cores  = var.lxc_cores
  memory = var.lxc_memory

  rootfs {
    storage = var.lxc_storage
    size    = var.lxc_disk_size
  }

  network {
    name   = "eth0"
    bridge = var.lxc_bridge
    ip     = var.lxc_ip_address
    gw     = var.lxc_gateway
  }

  nameserver = var.lxc_nameserver
  searchdomain = "local"

  ssh_public_keys = var.ssh_public_key != "" ? var.ssh_public_key : null

  features {
    nesting = true
  }

  lifecycle {
    ignore_changes = [
      network,
      mountpoint
    ]
  }
}

# Wait for container to be ready
resource "null_resource" "wait_for_container" {
  depends_on = [proxmox_lxc.minio]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

# Setup MinIO via SSH
resource "null_resource" "setup_minio" {
  depends_on = [null_resource.wait_for_container]

  connection {
    type        = "ssh"
    host        = local.minio_ip
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }

  # Upload setup script
  provisioner "file" {
    content = templatefile("${path.module}/scripts/setup-minio.sh", {
      minio_root_user     = var.minio_root_user
      minio_root_password = local.minio_password
      minio_api_port      = var.minio_api_port
      minio_console_port  = var.minio_console_port
      minio_bucket_name   = var.minio_bucket_name
    })
    destination = "/tmp/setup-minio.sh"
  }

  # Execute setup script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-minio.sh",
      "/tmp/setup-minio.sh"
    ]
  }
}