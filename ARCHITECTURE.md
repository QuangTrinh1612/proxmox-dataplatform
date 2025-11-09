# Architecture Overview

This document describes the architecture of the Proxmox Homelab infrastructure.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Proxmox Host                            │
│  ┌───────────────────────┐      ┌──────────────────────────┐   │
│  │   LXC Container       │      │      Virtual Machine      │   │
│  │   ┌───────────────┐   │      │   ┌──────────────────┐   │   │
│  │   │   MinIO       │   │      │   │   Dev Lab        │   │   │
│  │   │   Server      │   │      │   │   - Spark Master │   │   │
│  │   │               │   │      │   │   - Spark Worker │   │   │
│  │   │  :9000 (API)  │   │      │   │   - Dev Tools    │   │   │
│  │   │  :9001 (UI)   │   │      │   │   :8080 (Master) │   │   │
│  │   └───────────────┘   │      │   │   :8081 (Worker) │   │   │
│  │   192.168.1.200       │      │   │   :7077 (Spark)  │   │   │
│  └───────────────────────┘      │   └──────────────────┘   │   │
│                                  │   192.168.1.100          │   │
│                                  └──────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Network Bridge (vmbr0)                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
└──────────────────────────────┼──────────────────────────────────┘
                               │
                               │ Gateway: 192.168.1.1
                               │
                      ┌────────┴────────┐
                      │   Your Network   │
                      └─────────────────┘
```

## Infrastructure as Code

```
┌─────────────────────────────────────────────────────┐
│                  Developer Machine                   │
│                                                      │
│  ┌────────────────────┐  ┌────────────────────────┐ │
│  │     Terraform      │  │       Ansible          │ │
│  │                    │  │                        │ │
│  │  - VM Module       │  │  - Common Role         │ │
│  │  - LXC Module      │  │  - MinIO Role          │ │
│  │  - Network Module  │  │  - Spark Role          │ │
│  │  - Storage Module  │  │                        │ │
│  └─────────┬──────────┘  └─────────┬──────────────┘ │
│            │                       │                 │
│            │ Infrastructure        │ Configuration   │
│            │ Provisioning          │ Management      │
└────────────┼───────────────────────┼─────────────────┘
             │                       │
             ▼                       ▼
    ┌────────────────────────────────────────┐
    │         Proxmox VE API                 │
    │         (Port 8006)                    │
    └────────────────────────────────────────┘
                      │
                      ▼
          ┌───────────────────────┐
          │   Proxmox Resources   │
          │   - VMs               │
          │   - LXC Containers    │
          │   - Networks          │
          │   - Storage           │
          └───────────────────────┘
```

## Component Details

### MinIO Server (LXC Container)

**Purpose**: S3-compatible object storage server

**Specifications**:
- Container ID: 200
- OS: Ubuntu 22.04 LXC
- CPU: 2 cores
- Memory: 4 GB RAM
- Disk: 20 GB
- IP: 192.168.1.200

**Services**:
- MinIO Server (Port 9000) - S3 API
- MinIO Console (Port 9001) - Web UI

**Use Cases**:
- Data lake storage
- Backup storage
- Artifact repository
- ML model storage

### Dev Lab VM (Virtual Machine)

**Purpose**: Development and data processing environment

**Specifications**:
- VM ID: 100
- OS: Ubuntu 22.04 (Cloud-init)
- CPU: 4 cores
- Memory: 8 GB RAM
- Disk: 50 GB
- IP: 192.168.1.100

**Services**:
- Spark Master (Port 8080) - Web UI
- Spark Worker (Port 8081) - Web UI
- Spark Master (Port 7077) - Spark protocol

**Use Cases**:
- Data processing with Spark
- ETL workloads
- ML training
- Development and testing

## Network Architecture

### Network Configuration

```
Network: 192.168.1.0/24
Gateway: 192.168.1.1
DNS: 8.8.8.8

┌─────────────────────────────────────┐
│   Proxmox Bridge (vmbr0)            │
├─────────────────────────────────────┤
│  MinIO LXC      192.168.1.200/24    │
│  Dev Lab VM     192.168.1.100/24    │
└─────────────────────────────────────┘
```

### Port Matrix

| Service              | Host          | Port  | Protocol | Access     |
|---------------------|---------------|-------|----------|------------|
| MinIO API           | 192.168.1.200 | 9000  | HTTP     | Internal   |
| MinIO Console       | 192.168.1.200 | 9001  | HTTP     | Internal   |
| Spark Master UI     | 192.168.1.100 | 8080  | HTTP     | Internal   |
| Spark Worker UI     | 192.168.1.100 | 8081  | HTTP     | Internal   |
| Spark Master        | 192.168.1.100 | 7077  | TCP      | Internal   |
| SSH - MinIO         | 192.168.1.200 | 22    | TCP      | Admin      |
| SSH - Dev Lab       | 192.168.1.100 | 22    | TCP      | Admin      |

## Storage Architecture

### Storage Pools

```
Proxmox Storage
├── local (Directory)
│   └── ISO images, Container templates
├── local-lvm (LVM-Thin)
│   ├── VM Disks
│   └── Container Disks
└── backups (optional)
    └── Snapshots, Backups
```

### MinIO Storage Structure

```
MinIO Data Directory: /var/lib/minio
├── .minio.sys/         # System files
├── bucket1/            # User bucket
│   ├── object1
│   └── object2
└── bucket2/            # User bucket
```

## Deployment Flow

```
┌──────────────────────────────────────────────────┐
│ 1. Initialize                                    │
│    - Setup SSH keys                              │
│    - Configure terraform.tfvars                  │
│    - Install Ansible requirements                │
└────────────┬─────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────┐
│ 2. Terraform - Infrastructure Provisioning      │
│    - Create LXC container for MinIO             │
│    - Create VM for Dev Lab                      │
│    - Configure network                           │
│    - Configure storage                           │
│    - Generate Ansible inventory                  │
└────────────┬─────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────┐
│ 3. Wait for Initialization                       │
│    - VMs/Containers boot up                      │
│    - Network configuration applies               │
│    - SSH becomes available                       │
└────────────┬─────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────┐
│ 4. Ansible - Configuration Management            │
│    ├─ Common Role                                │
│    │  - System updates                           │
│    │  - Base packages                            │
│    │  - Security hardening                       │
│    ├─ MinIO Role                                 │
│    │  - Install MinIO binary                     │
│    │  - Configure service                        │
│    │  - Create buckets                           │
│    └─ Spark Role                                 │
│       - Install Java                             │
│       - Install Spark                            │
│       - Configure Master & Worker                │
│       - Start services                           │
└────────────┬─────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────┐
│ 5. Verification                                  │
│    - Test SSH connectivity                       │
│    - Check service status                        │
│    - Verify web UIs                              │
│    - Test basic functionality                    │
└──────────────────────────────────────────────────┘
```

## Terraform Module Structure

```
terraform/modules/
├── vm/
│   ├── main.tf         # VM resource definition
│   ├── variables.tf    # Input variables
│   └── outputs.tf      # Output values
├── lxc/
│   ├── main.tf         # LXC container definition
│   ├── variables.tf    # Input variables
│   └── outputs.tf      # Output values
├── network/
│   ├── main.tf         # Network configuration
│   ├── variables.tf    # Input variables
│   └── outputs.tf      # Output values
└── storage/
    ├── main.tf         # Storage configuration
    ├── variables.tf    # Input variables
    └── outputs.tf      # Output values
```

## Ansible Role Structure

```
ansible/roles/
├── common/             # Base system configuration
│   ├── tasks/
│   └── defaults/
├── minio/              # MinIO installation & config
│   ├── tasks/
│   ├── defaults/
│   ├── templates/
│   └── handlers/
└── spark/              # Spark installation & config
    ├── tasks/
    ├── defaults/
    ├── templates/
    └── handlers/
```

## Security Considerations

### Access Control

- **SSH Key Authentication**: Password authentication disabled
- **Proxmox API Token**: Limited scope, stored securely
- **MinIO Credentials**: Configurable, should be changed from defaults
- **Firewall**: Optional UFW configuration available

### Network Security

- **Internal Network**: Services accessible only from local network
- **No Public Exposure**: All services behind firewall
- **Encrypted Storage**: MinIO supports TLS (configure separately)

### Best Practices

1. Change default passwords immediately after deployment
2. Use Ansible Vault for sensitive variables
3. Implement backup strategy using snapshots
4. Regular security updates via automation
5. Monitor service logs for anomalies

## Scalability

### Horizontal Scaling

- **MinIO**: Can be deployed in distributed mode (4+ nodes)
- **Spark**: Add more worker VMs as needed
- **Network**: Support for VLANs and multiple bridges

### Vertical Scaling

- **CPU/Memory**: Easily adjustable in terraform.tfvars
- **Storage**: Expand disks or add new volumes
- **Templates**: Support for different VM/LXC sizes

## Monitoring & Logging

### Built-in Logging

- **systemd journals**: All services log to journald
- **MinIO**: Logs to /var/log/minio/
- **Spark**: Logs to /opt/spark/logs/

### Future Enhancements

- Prometheus metrics exporter
- Grafana dashboards
- Centralized log aggregation
- Alerting system

## Disaster Recovery

### Backup Strategy

```
┌─────────────────────────────────────┐
│ Snapshot Management                 │
├─────────────────────────────────────┤
│ - Pre-upgrade snapshots             │
│ - Scheduled daily snapshots         │
│ - Retention: 7 days                 │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│ Proxmox Backup Server (optional)    │
├─────────────────────────────────────┤
│ - Full VM/LXC backups               │
│ - Incremental backups               │
│ - Off-site replication              │
└─────────────────────────────────────┘
```

### Recovery Procedures

1. **Terraform State**: Backed up to remote backend
2. **Configuration**: Version controlled in Git
3. **Data**: MinIO data on separate volume (add manual backup)
4. **Snapshots**: Quick rollback via Proxmox

## Performance Tuning

### MinIO Optimization

- Increase memory for larger datasets
- Use SSD storage for better I/O
- Configure erasure coding for redundancy
- Enable caching for frequently accessed objects

### Spark Optimization

- Adjust executor memory based on workload
- Increase worker cores for parallel processing
- Configure shuffle partitions appropriately
- Use local SSD for shuffle data

---

For implementation details, see [SETUP.md](SETUP.md).
