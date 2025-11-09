# Proxmox Homelab Infrastructure

Infrastructure as Code (IaC) project for deploying and managing a Proxmox homelab environment with MinIO object storage and Apache Spark using Terraform and Ansible.

[![Terraform](https://img.shields.io/badge/Terraform-≥1.5.0-844FBA?logo=terraform)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-≥2.15.0-EE0000?logo=ansible)](https://www.ansible.com/)
[![Proxmox](https://img.shields.io/badge/Proxmox-≥8.0-E57000?logo=proxmox)](https://www.proxmox.com/)

## 🎯 Overview

This project provides a complete, production-ready infrastructure solution for deploying:
- **MinIO Server**: S3-compatible object storage (LXC container)
- **Dev Lab VM**: Apache Spark cluster for data processing (Virtual Machine)

All managed through declarative Infrastructure as Code using Terraform and Ansible.

## ✨ Features

- 🏗️ **Modular Terraform Structure**: Reusable modules for VM, LXC, network, and storage
- 🔧 **Automated Configuration**: Ansible roles for complete service setup
- 📦 **One-Command Deployment**: Simple scripts for quick deployment
- 🔒 **Security First**: SSH key auth, firewall configs, security hardening
- 📊 **Production Ready**: Health checks, logging, monitoring support
- 🔄 **Easy Maintenance**: Snapshot management, updates, rollbacks
- 📝 **Comprehensive Docs**: Setup guides, architecture diagrams, examples

## 🚀 Quick Start

### Prerequisites

- Proxmox VE 8.0+
- Terraform ≥ 1.5.0
- Ansible ≥ 2.15.0
- SSH key pair

### 30-Second Deployment

```bash
# 1. Clone the repository
git clone <your-repo> proxmox-homelab
cd proxmox-homelab

# 2. Run quick start wizard
chmod +x scripts/*.sh
./scripts/quick-start.sh

# 3. Configure Proxmox credentials
cp terraform/environments/dev/terraform.tfvars.example terraform/environments/dev/terraform.tfvars
# Edit terraform.tfvars with your Proxmox details

# 4. Deploy everything
make deploy

# 5. Verify deployment
make verify
```

That's it! Your infrastructure is ready. 🎉

## 📁 Project Structure

```
proxmox-homelab/
├── terraform/
│   ├── modules/           # Reusable Terraform modules
│   │   ├── vm/           # Virtual Machine module
│   │   ├── lxc/          # LXC Container module
│   │   ├── network/      # Network configuration
│   │   └── storage/      # Storage configuration
│   └── environments/
│       └── dev/          # Development environment
├── ansible/
│   ├── roles/
│   │   ├── common/       # Base system setup
│   │   ├── minio/        # MinIO installation & config
│   │   └── spark/        # Spark installation & config
│   ├── playbooks/        # Ansible playbooks
│   └── inventory/        # Auto-generated inventories
├── scripts/
│   ├── quick-start.sh    # First-time setup wizard
│   ├── deploy.sh         # Main deployment script
│   ├── validate.sh       # Pre-deployment validation
│   ├── verify.sh         # Post-deployment verification
│   ├── snapshot.sh       # Snapshot management
│   └── status.sh         # Environment status
├── Makefile              # Task automation
├── SETUP.md              # Complete setup guide
├── ARCHITECTURE.md       # Architecture documentation
└── PROJECT_SUMMARY.md    # Project overview
```

## 🎨 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Proxmox Host                            │
│  ┌───────────────────────┐      ┌──────────────────────────┐   │
│  │   MinIO Server        │      │      Dev Lab VM          │   │
│  │   (LXC Container)     │      │   - Spark Master         │   │
│  │                       │      │   - Spark Worker         │   │
│  │   :9000 (API)         │      │   - Dev Tools            │   │
│  │   :9001 (Console)     │      │   :8080 (Master UI)      │   │
│  │   192.168.1.200       │      │   :8081 (Worker UI)      │   │
│  └───────────────────────┘      │   192.168.1.100          │   │
│                                  └──────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation.

## 📋 Deployed Components

### MinIO Server (LXC)
- **Container ID**: 200
- **Resources**: 2 CPU cores, 4 GB RAM, 20 GB disk
- **Services**: S3-compatible object storage
- **Ports**: 9000 (API), 9001 (Console)

### Dev Lab VM
- **VM ID**: 100
- **Resources**: 4 CPU cores, 8 GB RAM, 50 GB disk
- **Services**: Apache Spark (Master + Worker)
- **Ports**: 8080 (Master UI), 8081 (Worker UI), 7077 (Spark)

## 🛠️ Usage

### Makefile Commands

```bash
# Show all commands
make help

# Deployment
make deploy              # Full deployment
make deploy-infra        # Infrastructure only
make deploy-config       # Configuration only
make deploy-auto         # Auto-approve deployment

# Management
make validate            # Validate configuration
make verify              # Verify services
make status              # Show infrastructure status
make urls                # Display service URLs

# Access
make ssh-minio           # SSH to MinIO server
make ssh-devlab          # SSH to Dev Lab VM

# Monitoring
make logs-minio          # View MinIO logs
make logs-spark-master   # View Spark Master logs
make logs-spark-worker   # View Spark Worker logs

# Maintenance
make snapshot-create     # Create snapshot
make snapshot-list       # List snapshots
make destroy             # Destroy infrastructure
```

### Script Usage

```bash
# Deployment with options
./scripts/deploy.sh --help
./scripts/deploy.sh --auto-approve
./scripts/deploy.sh --skip-ansible
./scripts/deploy.sh --destroy

# Check environment status
./scripts/status.sh

# Create backups
./scripts/snapshot.sh --action create --name backup-$(date +%Y%m%d)

# Validation
./scripts/validate.sh
```

## 🌐 Access Services

After deployment:

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| MinIO Console | http://192.168.1.200:9001 | minioadmin / minioadmin |
| MinIO API | http://192.168.1.200:9000 | - |
| Spark Master UI | http://192.168.1.100:8080 | - |
| Spark Worker UI | http://192.168.1.100:8081 | - |

SSH Access:
```bash
ssh root@192.168.1.200  # MinIO
ssh root@192.168.1.100  # Dev Lab
```

## 💡 Examples

### MinIO Usage

#### Python Client
```python
from minio import Minio

client = Minio(
    "192.168.1.200:9000",
    access_key="minioadmin",
    secret_key="minioadmin",
    secure=False
)

# Create bucket
client.make_bucket("my-data")

# Upload file
client.fput_object("my-data", "file.csv", "/path/to/file.csv")
```

#### MinIO Client (mc)
```bash
ssh root@192.168.1.200

# Configure alias
mc alias set local http://localhost:9000 minioadmin minioadmin

# Create bucket
mc mb local/my-bucket

# Upload file
mc cp file.txt local/my-bucket/
```

### Spark Usage

#### Submit Job
```bash
ssh root@192.168.1.100

/opt/spark/bin/spark-submit \
  --master spark://192.168.1.100:7077 \
  --deploy-mode client \
  your_application.py
```

#### PySpark Shell
```bash
pyspark --master spark://192.168.1.100:7077
```

```python
# In PySpark shell
df = spark.range(1000)
df.count()
```

#### Connect Spark with MinIO
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("MinIO Integration") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://192.168.1.200:9000") \
    .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
    .config("spark.hadoop.fs.s3a.secret.key", "minioadmin") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .getOrCreate()

# Read from MinIO
df = spark.read.csv("s3a://my-bucket/data.csv")
df.show()
```

## 📚 Documentation

- **[SETUP.md](SETUP.md)**: Complete step-by-step setup guide with troubleshooting
- **[ARCHITECTURE.md](ARCHITECTURE.md)**: Detailed architecture and design documentation
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)**: Comprehensive project overview
- **[scripts/README.md](scripts/README.md)**: Script usage documentation

## 🔧 Configuration

### Terraform Variables

Key variables in `terraform/environments/dev/terraform.tfvars`:

```hcl
proxmox_api_url          = "https://proxmox-host:8006/api2/json"
proxmox_api_token_id     = "terraform@pve!terraform-token"
proxmox_api_token_secret = "your-secret-here"

minio_ip_address  = "192.168.1.200/24"
devlab_ip_address = "192.168.1.100/24"

minio_cpu_cores = 2
minio_memory    = 4096

devlab_cpu_cores = 4
devlab_memory    = 8192
```

### Ansible Customization

Customize roles in `ansible/roles/*/defaults/main.yml`:
- MinIO configuration (ports, credentials, buckets)
- Spark configuration (versions, resources, settings)
- Common system settings (packages, timezone, security)

## 🔒 Security

- ✅ SSH key authentication (password auth disabled)
- ✅ Proxmox API token with limited scope
- ✅ Customizable firewall rules (UFW)
- ✅ Security hardening in common role
- ✅ Ansible Vault support for secrets
- ⚠️ **Change default passwords immediately**

See `SETUP.md` for security best practices.

## 🐛 Troubleshooting

### Common Issues

**Cannot connect to Proxmox**
```bash
# Test connectivity
curl -k https://your-proxmox-host:8006
```

**VMs not reachable**
```bash
# Check status
./scripts/status.sh

# Verify Ansible inventory
cat ansible/inventory/dev.yml
```

**Services not starting**
```bash
# Check logs
make logs-minio
make logs-spark-master

# SSH and investigate
make ssh-minio
systemctl status minio
```

See [SETUP.md](SETUP.md) for comprehensive troubleshooting guide.

## 📊 Requirements

### Proxmox Host
- CPU: 6+ cores
- RAM: 16 GB+
- Storage: 100 GB+
- Network: Gigabit Ethernet

### Local Machine
- Terraform ≥ 1.5.0
- Ansible ≥ 2.15.0
- SSH client
- Basic shell tools (curl, wget, make)

## 🚀 Advanced Usage

### Multiple Environments

```bash
# Copy dev environment
cp -r terraform/environments/dev terraform/environments/prod

# Deploy to production
cd terraform/environments/prod
terraform init
terraform apply
```

### Custom Modules

Extend with your own modules:
```hcl
module "custom_service" {
  source = "../../modules/vm"
  
  vm_name = "custom-service"
  # ... other variables
}
```

### CI/CD Integration

```yaml
# .gitlab-ci.yml example
deploy:
  script:
    - terraform init
    - terraform apply -auto-approve
    - ansible-playbook -i inventory playbooks/site.yml
```

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

MIT License - See [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Terraform Proxmox Provider (bpg)](https://github.com/bpg/terraform-provider-proxmox)
- [Ansible](https://www.ansible.com/)
- [MinIO](https://min.io/)
- [Apache Spark](https://spark.apache.org/)

## 📞 Support

- 📖 Check [SETUP.md](SETUP.md) for detailed guides
- 🏗️ Review [ARCHITECTURE.md](ARCHITECTURE.md) for design
- 💬 Open an issue for bugs or questions
- 📧 Contact maintainers for support

---

**Status**: ✅ Production Ready | **Version**: 1.0.0

Made with ❤️ for the homelab community
