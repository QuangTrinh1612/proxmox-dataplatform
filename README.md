# MinIO Server on Proxmox LXC - Infrastructure as Code

This project deploys a MinIO object storage server on Proxmox LXC container using Terraform and Ansible, specifically designed to store Terraform state files.

## Architecture

```
┌─────────────────────────────────────────┐
│         Proxmox VE Host                 │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   LXC Container (Debian 12)       │ │
│  │                                   │ │
│  │   ┌─────────────────────────┐    │ │
│  │   │   MinIO Server          │    │ │
│  │   │   - API: Port 9000      │    │ │
│  │   │   - Console: Port 9001  │    │ │
│  │   │   - Bucket: terraform-  │    │ │
│  │   │     state               │    │ │
│  │   └─────────────────────────┘    │ │
│  │                                   │ │
│  │   Deploy User (sudo access)       │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Prerequisites

### On Your Local Machine

1. **Terraform** (>= 1.5.0)
   ```bash
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
   unzip terraform_1.5.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. **Ansible** (>= 2.10)
   ```bash
   # macOS
   brew install ansible
   
   # Linux (Debian/Ubuntu)
   sudo apt update
   sudo apt install ansible
   
   # Pip
   pip3 install ansible
   ```

3. **SSH Key Pair**
   ```bash
   # Generate SSH key if you don't have one
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

### On Proxmox Host

1. A running Proxmox VE installation
2. Available IP address on your network
3. Storage pool (e.g., `local-lvm`)
4. API access credentials
5. SSH access to Proxmox host

## Directory Structure

```
proxmox-dataplatform/
├── terraform/
│   ├── providers.tf              # Terraform provider configuration
│   ├── variables.tf              # Variable definitions
│   ├── main.tf                   # LXC container creation
│   ├── outputs.tf                # Output values
│   ├── backend-example.tf        # Example backend configuration
│   └── terraform.tfvars.example  # Example variables file
│
└── ansible/
    ├── ansible.cfg               # Ansible configuration
    ├── inventory.yml             # Ansible inventory
    ├── minio-setup.yml           # Main playbook
    ├── group_vars/
    │   └── all.yml               # MinIO variables
    └── templates/
        ├── minio.env.j2          # MinIO environment file
        └── minio.service.j2      # MinIO systemd service
```

## Quick Start Guide

### Step 1: Configure Terraform Variables

1. Navigate to the terraform directory:
   ```bash
   cd terraform
   ```

2. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` with your values:
   ```hcl
   # Proxmox Configuration
   proxmox_endpoint     = "https://192.168.1.50:8006"
   proxmox_username     = "root@pam"
   proxmox_password     = "your-proxmox-password"
   proxmox_node         = "pve"
   
   # Network Configuration
   minio_ip_address     = "192.168.1.100/24"
   network_gateway      = "192.168.1.1"
   
   # User Configuration
   sudo_username        = "deploy"
   sudo_password        = "SecurePassword123!"
   ssh_public_key       = "ssh-rsa AAAAB3Nza... your-key-here"
   ```

### Step 2: Configure MinIO Settings (Optional)

Edit `ansible/group_vars/all.yml` to customize MinIO:

```yaml
minio_root_user: "minioadmin"
minio_root_password: "ChangeThisPassword123!"
minio_data_dir: "/data/minio"
terraform_state_bucket: "terraform-state"
```

**⚠️ IMPORTANT: Change the default passwords in production!**

### Step 3: Deploy Infrastructure

1. Initialize Terraform:
   ```bash
   cd terraform
   terraform init
   ```

2. Review the deployment plan:
   ```bash
   terraform plan
   ```

3. Deploy the MinIO server:
   ```bash
   terraform apply
   ```

   This will:
   - Download Debian 12 LXC template
   - Create LXC container
   - Configure networking
   - Create sudo user
   - Install Python3
   - Run Ansible playbook to install and configure MinIO

4. Note the outputs:
   ```
   Outputs:

   minio_api_url = "http://192.168.1.100:9000"
   minio_console_url = "http://192.168.1.100:9001"
   minio_ip_address = "192.168.1.100"
   sudo_username = "deploy"
   ```

### Step 4: Access MinIO Console

1. Open your browser and navigate to the Console URL:
   ```
   http://192.168.1.100:9001
   ```

2. Login with credentials from `ansible/group_vars/all.yml`:
   - Username: `minioadmin`
   - Password: `minioadmin123` (or your configured password)

3. Verify the `terraform-state` bucket exists

### Step 5: Create Access Keys for Terraform

1. In MinIO Console, navigate to **Access Keys**
2. Click **Create Access Key**
3. Save the **Access Key** and **Secret Key** securely
4. These will be used to configure Terraform backend

### Step 6: Configure Terraform Backend

1. In your Terraform project, create a backend configuration:

   ```hcl
   terraform {
     backend "s3" {
       endpoint                    = "http://192.168.1.100:9000"
       bucket                      = "terraform-state"
       key                         = "project-name/terraform.tfstate"
       region                      = "us-east-1"
       
       skip_credentials_validation = true
       skip_metadata_api_check     = true
       skip_region_validation      = true
       force_path_style            = true
     }
   }
   ```

2. Set environment variables:
   ```bash
   export AWS_ACCESS_KEY_ID="your-minio-access-key"
   export AWS_SECRET_ACCESS_KEY="your-minio-secret-key"
   ```

3. Initialize Terraform with the backend:
   ```bash
   terraform init
   ```

## Manual Ansible Deployment

If you need to run Ansible separately:

```bash
cd ansible

# Run with password prompt
ansible-playbook -i inventory.yml minio-setup.yml \
  -e "minio_host=192.168.1.100" \
  -e "ansible_user=deploy" \
  --ask-become-pass

# Or with environment variable
export ANSIBLE_BECOME_PASS="your-sudo-password"
ansible-playbook -i inventory.yml minio-setup.yml \
  -e "minio_host=192.168.1.100" \
  -e "ansible_user=deploy"
```

## Verification Steps

### 1. Check Container Status

```bash
# On Proxmox host
pct status 200
pct list | grep minio
```

### 2. SSH into Container

```bash
ssh deploy@192.168.1.100
```

### 3. Check MinIO Service

```bash
# Inside container
sudo systemctl status minio

# Check MinIO process
ps aux | grep minio

# Check listening ports
sudo netstat -tlnp | grep minio
```

### 4. Test MinIO API

```bash
# From your local machine
curl http://192.168.1.100:9000/minio/health/live

# Expected output: OK
```

### 5. Use MinIO Client

```bash
# Inside container
mc alias set local http://localhost:9000 minioadmin minioadmin123
mc ls local/
mc ls local/terraform-state
```

## Troubleshooting

### Container Fails to Start

```bash
# Check container logs on Proxmox
pct enter 200
journalctl -xe

# Check Proxmox system logs
tail -f /var/log/syslog
```

### MinIO Service Not Starting

```bash
# Inside container
sudo journalctl -u minio -f

# Check environment file
sudo cat /etc/minio/minio.env

# Check data directory permissions
ls -la /data/minio
```

### Cannot Access MinIO Console

```bash
# Check firewall (if enabled)
sudo iptables -L -n

# Check if port is listening
sudo netstat -tlnp | grep 9001

# Check MinIO logs
sudo journalctl -u minio --no-pager
```

### Terraform Backend Connection Issues

```bash
# Test S3 endpoint
curl -v http://192.168.1.100:9000

# Verify credentials
mc alias set test http://192.168.1.100:9000 ACCESS_KEY SECRET_KEY
mc ls test/

# Check Terraform verbose output
TF_LOG=DEBUG terraform init
```

### Ansible Connection Issues

```bash
# Test SSH connection
ssh -v deploy@192.168.1.100

# Test Ansible connectivity
ansible minio -i inventory.yml -m ping

# Run with verbose output
ansible-playbook -vvv -i inventory.yml minio-setup.yml
```

## Security Best Practices

### 1. Change Default Passwords

```yaml
# Edit ansible/group_vars/all.yml
minio_root_user: "admin"
minio_root_password: "VeryStrongPassword123!@#"
```

### 2. Enable SSL/TLS (Recommended for Production)

```yaml
# In ansible/group_vars/all.yml
minio_enable_ssl: true
```

Then place certificates in `/etc/minio/certs/`:
- `public.crt` - SSL certificate
- `private.key` - Private key

### 3. Restrict Network Access

```bash
# On Proxmox host, add firewall rules
pct set 200 -firewall 1

# Allow only specific IPs
iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 9000 -j ACCEPT
iptables -A INPUT -p tcp --dport 9000 -j DROP
```

### 4. Use IAM Policies

Create specific access policies in MinIO Console for Terraform:
- Read/Write access only to `terraform-state` bucket
- No admin privileges

### 5. Regular Backups

```bash
# Backup MinIO data directory
tar -czf minio-backup-$(date +%Y%m%d).tar.gz /data/minio

# Backup to remote location
rsync -avz /data/minio/ backup-server:/backups/minio/
```

## Maintenance

### Update MinIO

```bash
# Edit ansible/group_vars/all.yml
minio_version: "RELEASE.2024-XX-XXTXX-XX-XXZ"

# Run Ansible playbook
cd ansible
ansible-playbook -i inventory.yml minio-setup.yml
```

### Monitor Storage Usage

```bash
# Inside container
mc admin info local/

# Check disk usage
df -h /data/minio
```

### View Access Logs

```bash
# MinIO audit logs
sudo journalctl -u minio -f

# System logs
sudo tail -f /var/log/syslog
```

## Cleanup

### Destroy Infrastructure

```bash
cd terraform
terraform destroy
```

This will:
1. Stop the MinIO container
2. Delete the LXC container
3. Remove the container from Proxmox

**⚠️ WARNING: This will delete all data including state files!**

### Manual Cleanup

```bash
# On Proxmox host
pct stop 200
pct destroy 200

# Remove template (optional)
rm /var/lib/vz/template/cache/debian-12-standard_12.7-1_amd64.tar.zst
```

## Advanced Configuration

### Custom Storage Pool

```hcl
# In terraform.tfvars
minio_storage_pool = "nvme-pool"
minio_rootfs_size = "50G"
```

### Additional Data Disk

Modify `terraform/main.tf`:

```hcl
disk {
  datastore_id = "nvme-pool"
  size         = "100G"
}
```

### High Availability Setup

For production HA setup:
1. Deploy multiple MinIO containers
2. Configure MinIO distributed mode
3. Use load balancer (HAProxy/nginx)
4. Shared storage backend

## References

- [Terraform bpg/proxmox Provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [MinIO Documentation](https://min.io/docs/minio/linux/index.html)
- [Terraform S3 Backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [Ansible Documentation](https://docs.ansible.com/)

## License

MIT License - Feel free to modify and use for your projects

## Support

For issues:
1. Check logs: `sudo journalctl -u minio -f`
2. Verify network connectivity
3. Review Terraform/Ansible output
4. Check Proxmox container status

---

**Built with ❤️ using Infrastructure as Code**
