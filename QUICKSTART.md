# Quick Start Guide - MinIO on Proxmox

## 5-Minute Setup

### Prerequisites Check
```bash
# Verify installations
terraform version  # Should be >= 1.5.0
ansible --version  # Should be >= 2.10
ssh-keygen -l -f ~/.ssh/id_rsa.pub  # Verify SSH key exists
```

### Step 1: Configure (2 minutes)

```bash
cd proxmox-dataplatform

# Copy and edit Terraform variables
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
nano terraform/terraform.tfvars
```

**Minimum required changes:**
- `proxmox_endpoint` - Your Proxmox IP (e.g., https://192.168.1.50:8006)
- `proxmox_password` - Your Proxmox root password
- `proxmox_node` - Your Proxmox node name (e.g., "pve")
- `minio_ip_address` - Available IP for MinIO (e.g., 192.168.1.100/24)
- `network_gateway` - Your network gateway (e.g., 192.168.1.1)
- `ssh_public_key` - Your SSH public key
- `sudo_password` - A secure password for the deploy user

```bash
# Edit MinIO credentials (IMPORTANT!)
nano ansible/group_vars/all.yml
```

**Change:**
- `minio_root_password` - Set a strong password

### Step 2: Deploy (3 minutes)

```bash
cd terraform

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy!
terraform apply -auto-approve
```

### Step 3: Access MinIO

After deployment completes (2-3 minutes):

1. **Open MinIO Console:**
   ```
   http://<your-minio-ip>:9001
   ```

2. **Login:**
   - Username: `minioadmin`
   - Password: (from ansible/group_vars/all.yml)

3. **Create Access Key:**
   - Go to "Access Keys" in the menu
   - Click "Create Access Key"
   - Save the Access Key and Secret Key

### Step 4: Configure Terraform Backend

In your Terraform project:

```hcl
# backend.tf
terraform {
  backend "s3" {
    endpoint                    = "http://<your-minio-ip>:9000"
    bucket                      = "terraform-state"
    key                         = "my-project/terraform.tfstate"
    region                      = "us-east-1"
    
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
```

Set credentials:
```bash
export AWS_ACCESS_KEY_ID="<your-access-key>"
export AWS_SECRET_ACCESS_KEY="<your-secret-key>"

terraform init
```

## Done! 🎉

Your Terraform state is now stored securely in MinIO!

## Common Commands

```bash
# Check MinIO status
ssh deploy@<minio-ip> sudo systemctl status minio

# View MinIO logs
ssh deploy@<minio-ip> sudo journalctl -u minio -f

# Restart MinIO
ssh deploy@<minio-ip> sudo systemctl restart minio

# Destroy everything
cd terraform && terraform destroy
```

## Troubleshooting

**Can't connect to Proxmox?**
```bash
# Test connectivity
curl -k https://<proxmox-ip>:8006/api2/json
```

**Container not starting?**
```bash
# Check on Proxmox host
pct status 200
pct list
```

**Ansible fails?**
```bash
# Test SSH connection
ssh deploy@<minio-ip>

# Run Ansible manually
cd ansible
ansible-playbook -i inventory.yml minio-setup.yml \
  -e "minio_host=<minio-ip>" \
  -e "ansible_user=deploy" \
  --ask-become-pass
```

**MinIO not accessible?**
```bash
# Check if ports are listening
ssh deploy@<minio-ip> 'sudo netstat -tlnp | grep minio'

# Check firewall (if enabled)
ssh deploy@<minio-ip> 'sudo iptables -L -n'
```

## Next Steps

- ✅ Change default passwords
- ✅ Set up backups for /data/minio
- ✅ Configure SSL/TLS for production
- ✅ Create IAM policies for different projects
- ✅ Enable versioning on critical buckets

## Need Help?

1. Check the main README.md for detailed documentation
2. Review logs: `sudo journalctl -u minio -f`
3. Verify network configuration
4. Check Proxmox container status

---

For full documentation, see [README.md](README.md)
