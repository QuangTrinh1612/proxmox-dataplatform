#!/bin/bash
# MinIO on Proxmox - Quick Setup Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  MinIO on Proxmox - Infrastructure Setup      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 is not installed"
        return 1
    else
        print_success "$1 is installed"
        return 0
    fi
}

# Main script
print_header

# Check prerequisites
print_info "Checking prerequisites..."
echo ""

ALL_GOOD=true

if ! check_command terraform; then
    print_error "Please install Terraform: https://www.terraform.io/downloads"
    ALL_GOOD=false
fi

if ! check_command ansible; then
    print_error "Please install Ansible: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html"
    ALL_GOOD=false
fi

if ! check_command ssh-keygen; then
    print_error "Please install OpenSSH"
    ALL_GOOD=false
fi

echo ""

if [ "$ALL_GOOD" = false ]; then
    print_error "Please install missing prerequisites and run again"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_info "Creating terraform.tfvars from example..."
    if [ -f "terraform.tfvars.example" ]; then
        cp terraform.tfvars.example terraform.tfvars
        print_success "Created terraform.tfvars"
        echo ""
        print_info "Please edit terraform.tfvars with your Proxmox details before proceeding"
        echo ""
        read -p "Press Enter when you've edited terraform.tfvars..."
    else
        print_error "terraform.tfvars.example not found"
        exit 1
    fi
fi

# Check for SSH key
if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
    print_info "No SSH key found. Generating one..."
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
    print_success "SSH key generated"
else
    print_success "SSH key exists"
fi

echo ""
print_info "Your SSH public key:"
cat "$HOME/.ssh/id_rsa.pub"
echo ""
read -p "Add this key to terraform.tfvars ssh_public_keys if not already done. Press Enter to continue..."

# Create ansible directory if it doesn't exist
mkdir -p ansible

# Initialize Terraform
echo ""
print_info "Initializing Terraform..."
if terraform init; then
    print_success "Terraform initialized"
else
    print_error "Terraform initialization failed"
    exit 1
fi

# Validate Terraform
echo ""
print_info "Validating Terraform configuration..."
if terraform validate; then
    print_success "Terraform configuration is valid"
else
    print_error "Terraform validation failed"
    exit 1
fi

# Show plan
echo ""
print_info "Generating Terraform plan..."
terraform plan -out=tfplan

echo ""
print_info "Review the plan above"
read -p "Do you want to apply this configuration? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    print_info "Aborted by user"
    rm -f tfplan
    exit 0
fi

# Apply
echo ""
print_info "Applying Terraform configuration..."
if terraform apply tfplan; then
    print_success "Infrastructure deployed successfully!"
else
    print_error "Terraform apply failed"
    rm -f tfplan
    exit 1
fi

rm -f tfplan

# Get outputs
echo ""
MINIO_IP=$(terraform output -raw minio_ip_address 2>/dev/null | sed 's/\/24//')
MINIO_API=$(terraform output -raw minio_api_endpoint 2>/dev/null)
MINIO_CONSOLE=$(terraform output -raw minio_console_url 2>/dev/null)

# Print summary
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Deployment Successful! 🎉             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}MinIO Server Information:${NC}"
echo -e "  API Endpoint:  ${YELLOW}$MINIO_API${NC}"
echo -e "  Console URL:   ${YELLOW}$MINIO_CONSOLE${NC}"
echo ""
echo -e "${BLUE}Default Credentials:${NC}"
echo -e "  Username: ${YELLOW}minioadmin${NC}"
echo -e "  Password: ${YELLOW}minioadmin123${NC}"
echo ""
echo -e "${RED}⚠️  IMPORTANT: Change the default credentials in production!${NC}"
echo ""

# Install MinIO client
read -p "Do you want to install and configure MinIO client (mc)? (yes/no): " INSTALL_MC

if [ "$INSTALL_MC" = "yes" ]; then
    if ! command -v mc &> /dev/null; then
        print_info "Installing MinIO client..."
        wget -q https://dl.min.io/client/mc/release/linux-amd64/mc -O /tmp/mc
        chmod +x /tmp/mc
        sudo mv /tmp/mc /usr/local/bin/
        print_success "MinIO client installed"
    fi
    
    print_info "Configuring MinIO client..."
    mc alias set myminio "$MINIO_API" minioadmin minioadmin123 --insecure
    print_success "MinIO client configured"
    
    echo ""
    print_info "Testing connection..."
    mc ls myminio
    echo ""
fi

# Next steps
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Access console at: $MINIO_CONSOLE"
echo "  2. Change default credentials"
echo "  3. Configure Terraform backend in your projects"
echo "  4. See README.md for backend configuration examples"
echo ""
echo -e "${GREEN}Setup complete!${NC}"