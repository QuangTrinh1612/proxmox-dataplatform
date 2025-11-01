#!/bin/bash

# MinIO Health Check Script
# This script verifies the MinIO installation and configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
MINIO_IP="${1:-192.168.1.100}"
MINIO_API_PORT="${2:-9000}"
MINIO_CONSOLE_PORT="${3:-9001}"

echo "=========================================="
echo "MinIO Health Check"
echo "=========================================="
echo ""
echo "Target: $MINIO_IP"
echo ""

# Function to check if a service is reachable
check_service() {
    local host=$1
    local port=$2
    local service_name=$3
    
    if timeout 5 bash -c "cat < /dev/null > /dev/tcp/$host/$port" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $service_name is reachable on port $port"
        return 0
    else
        echo -e "${RED}✗${NC} $service_name is NOT reachable on port $port"
        return 1
    fi
}

# Function to check HTTP endpoint
check_http() {
    local url=$1
    local service_name=$2
    
    if curl -sf -o /dev/null "$url"; then
        echo -e "${GREEN}✓${NC} $service_name endpoint is responding"
        return 0
    else
        echo -e "${RED}✗${NC} $service_name endpoint is NOT responding"
        return 1
    fi
}

# Check network connectivity
echo "1. Network Connectivity"
echo "-------------------------"
if ping -c 1 -W 2 "$MINIO_IP" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Host $MINIO_IP is reachable"
else
    echo -e "${RED}✗${NC} Host $MINIO_IP is NOT reachable"
    echo ""
    echo "Please check:"
    echo "  - Is the container running?"
    echo "  - Is the IP address correct?"
    echo "  - Is there a network issue?"
    exit 1
fi
echo ""

# Check MinIO ports
echo "2. MinIO Services"
echo "-------------------------"
check_service "$MINIO_IP" "$MINIO_API_PORT" "MinIO API"
check_service "$MINIO_IP" "$MINIO_CONSOLE_PORT" "MinIO Console"
echo ""

# Check MinIO health endpoints
echo "3. MinIO Health Endpoints"
echo "-------------------------"
check_http "http://$MINIO_IP:$MINIO_API_PORT/minio/health/live" "MinIO Health (Live)"
check_http "http://$MINIO_IP:$MINIO_API_PORT/minio/health/ready" "MinIO Health (Ready)"
echo ""

# Check MinIO version
echo "4. MinIO Information"
echo "-------------------------"
if command -v mc >/dev/null 2>&1; then
    echo "Checking MinIO version..."
    VERSION=$(curl -s "http://$MINIO_IP:$MINIO_API_PORT" 2>/dev/null | grep -oP '(?<=Server: MinIO/)[^ ]+' || echo "Unable to determine")
    echo -e "${GREEN}✓${NC} MinIO Version: $VERSION"
else
    echo -e "${YELLOW}!${NC} MinIO Client (mc) not installed locally - skipping detailed checks"
fi
echo ""

# Check SSH access
echo "5. SSH Access"
echo "-------------------------"
read -p "Enter SSH username (default: deploy): " SSH_USER
SSH_USER=${SSH_USER:-deploy}

if ssh -o ConnectTimeout=5 -o BatchMode=yes "$SSH_USER@$MINIO_IP" "echo 'SSH connection successful'" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} SSH access is working"
    
    # Check MinIO service status
    echo ""
    echo "Checking MinIO service status on container..."
    ssh "$SSH_USER@$MINIO_IP" "sudo systemctl is-active minio" >/dev/null 2>&1 && \
        echo -e "${GREEN}✓${NC} MinIO service is active" || \
        echo -e "${RED}✗${NC} MinIO service is NOT active"
    
    # Check disk usage
    echo ""
    echo "Disk usage for /data/minio:"
    ssh "$SSH_USER@$MINIO_IP" "df -h /data/minio" 2>/dev/null || \
        echo -e "${YELLOW}!${NC} Unable to check disk usage"
else
    echo -e "${YELLOW}!${NC} SSH access check skipped (no passwordless SSH configured)"
fi
echo ""

# Summary
echo "=========================================="
echo "Health Check Summary"
echo "=========================================="
echo ""
echo "Console URL: http://$MINIO_IP:$MINIO_CONSOLE_PORT"
echo "API URL:     http://$MINIO_IP:$MINIO_API_PORT"
echo ""
echo "Next steps:"
echo "1. Access the Console URL in your browser"
echo "2. Login with your MinIO credentials"
echo "3. Create access keys for Terraform"
echo "4. Configure your Terraform backend"
echo ""
echo "For more information, see README.md"
echo ""
