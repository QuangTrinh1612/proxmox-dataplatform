#!/bin/bash
set -e

echo "=== MinIO Server Setup Script ==="

# Variables from Terraform
MINIO_ROOT_USER="${minio_root_user}"
MINIO_ROOT_PASSWORD="${minio_root_password}"
MINIO_API_PORT="${minio_api_port}"
MINIO_CONSOLE_PORT="${minio_console_port}"
MINIO_BUCKET="${minio_bucket_name}"

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
apt-get install -y wget curl

# Download and install MinIO
echo "Installing MinIO server..."
wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio
chmod +x /usr/local/bin/minio

# Download and install MinIO Client (mc)
echo "Installing MinIO client..."
wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc
chmod +x /usr/local/bin/mc

# Create MinIO user and group
echo "Creating MinIO user..."
useradd -r -s /sbin/nologin minio-user || true

# Create MinIO directories
echo "Creating MinIO directories..."
mkdir -p /data/minio
chown -R minio-user:minio-user /data/minio

# Create MinIO environment file
echo "Creating MinIO configuration..."
cat > /etc/default/minio << EOF
# MinIO configuration file
MINIO_ROOT_USER=$MINIO_ROOT_USER
MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD
MINIO_VOLUMES="/data/minio"
MINIO_OPTS="--console-address :$MINIO_CONSOLE_PORT --address :$MINIO_API_PORT"
EOF

# Create systemd service
echo "Creating MinIO systemd service..."
cat > /etc/systemd/system/minio.service << 'EOF'
[Unit]
Description=MinIO
Documentation=https://min.io/docs/minio/linux/index.html
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
WorkingDirectory=/usr/local

User=minio-user
Group=minio-user
ProtectProc=invisible

EnvironmentFile=/etc/default/minio
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

# MinIO RELEASE.2023-05-04T21-44-30Z adds support for Type=notify (https://www.freedesktop.org/software/systemd/man/systemd.service.html#Type=)
# This may improve systemd integration in future versions.
Type=notify

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

# Enable and start MinIO service
echo "Starting MinIO service..."
systemctl daemon-reload
systemctl enable minio.service
systemctl start minio.service

# Wait for MinIO to be ready
echo "Waiting for MinIO to be ready..."
sleep 10

# Configure mc client
echo "Configuring MinIO client..."
mc alias set local http://localhost:$MINIO_API_PORT $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD

# Create bucket for Terraform state
echo "Creating Terraform state bucket..."
mc mb local/$MINIO_BUCKET --ignore-existing

# Enable versioning on the bucket (recommended for state files)
echo "Enabling versioning on bucket..."
mc version enable local/$MINIO_BUCKET

# Set bucket policy to private
echo "Setting bucket policy..."
mc anonymous set none local/$MINIO_BUCKET

# Display MinIO status
echo "=== MinIO Setup Complete ==="
echo "MinIO API: http://$(hostname -I | awk '{print $1}'):$MINIO_API_PORT"
echo "MinIO Console: http://$(hostname -I | awk '{print $1}'):$MINIO_CONSOLE_PORT"
echo "Root User: $MINIO_ROOT_USER"
echo "Bucket: $MINIO_BUCKET"
echo "Service Status:"
systemctl status minio.service --no-pager

# Create a marker file to indicate setup is complete
touch /root/.minio-setup-complete