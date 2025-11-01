#!/bin/bash

# MinIO Management Script
# Common operations for managing MinIO on Proxmox

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
ANSIBLE_DIR="$SCRIPT_DIR/ansible"

# Functions
print_header() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local missing=0
    
    if command -v terraform >/dev/null 2>&1; then
        print_success "Terraform installed: $(terraform version -json | grep -o '"version":"[^"]*' | cut -d'"' -f4)"
    else
        print_error "Terraform not found"
        missing=1
    fi
    
    if command -v ansible >/dev/null 2>&1; then
        print_success "Ansible installed: $(ansible --version | head -n1 | cut -d' ' -f2)"
    else
        print_error "Ansible not found"
        missing=1
    fi
    
    if [ -f "$HOME/.ssh/id_rsa.pub" ] || [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
        print_success "SSH key found"
    else
        print_warning "No SSH key found in ~/.ssh/"
        echo "  Generate with: ssh-keygen -t ed25519"
    fi
    
    if [ $missing -eq 0 ]; then
        print_success "All prerequisites met!"
    else
        print_error "Please install missing prerequisites"
        exit 1
    fi
}

# Setup configuration
setup_config() {
    print_header "Setup Configuration"
    
    if [ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
        echo "Creating terraform.tfvars from example..."
        cp "$TERRAFORM_DIR/terraform.tfvars.example" "$TERRAFORM_DIR/terraform.tfvars"
        print_success "Created terraform.tfvars"
        print_warning "Please edit terraform/terraform.tfvars with your values"
        echo ""
        read -p "Open terraform.tfvars for editing? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ${EDITOR:-nano} "$TERRAFORM_DIR/terraform.tfvars"
        fi
    else
        print_success "terraform.tfvars already exists"
    fi
    
    echo ""
    print_warning "Don't forget to edit ansible/group_vars/all.yml"
    read -p "Open ansible/group_vars/all.yml for editing? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} "$ANSIBLE_DIR/group_vars/all.yml"
    fi
}

# Deploy infrastructure
deploy() {
    print_header "Deploying MinIO Infrastructure"
    
    cd "$TERRAFORM_DIR"
    
    if [ ! -d ".terraform" ]; then
        echo "Initializing Terraform..."
        terraform init
    fi
    
    echo ""
    echo "Running Terraform plan..."
    terraform plan -out=tfplan
    
    echo ""
    read -p "Apply this plan? (yes/no): " -r
    if [[ $REPLY == "yes" ]]; then
        terraform apply tfplan
        rm tfplan
        print_success "Deployment complete!"
    else
        rm tfplan
        print_warning "Deployment cancelled"
    fi
    
    cd "$SCRIPT_DIR"
}

# Check status
check_status() {
    print_header "Checking MinIO Status"
    
    if [ ! -f "$TERRAFORM_DIR/terraform.tfstate" ]; then
        print_error "No terraform.tfstate found. Have you deployed yet?"
        exit 1
    fi
    
    # Get MinIO IP from Terraform state
    cd "$TERRAFORM_DIR"
    MINIO_IP=$(terraform output -raw minio_ip_address 2>/dev/null || echo "")
    
    if [ -z "$MINIO_IP" ]; then
        print_error "Could not determine MinIO IP address"
        exit 1
    fi
    
    echo "MinIO IP: $MINIO_IP"
    
    # Run health check
    cd "$SCRIPT_DIR"
    if [ -f "check-minio.sh" ]; then
        bash check-minio.sh "$MINIO_IP"
    else
        # Basic checks
        if ping -c 1 -W 2 "$MINIO_IP" >/dev/null 2>&1; then
            print_success "Host is reachable"
        else
            print_error "Host is NOT reachable"
        fi
        
        if curl -sf -o /dev/null "http://$MINIO_IP:9000/minio/health/live"; then
            print_success "MinIO API is responding"
        else
            print_error "MinIO API is NOT responding"
        fi
    fi
}

# Destroy infrastructure
destroy() {
    print_header "Destroying MinIO Infrastructure"
    
    print_warning "This will delete the MinIO container and all data!"
    read -p "Are you sure? Type 'yes' to confirm: " -r
    
    if [[ $REPLY == "yes" ]]; then
        cd "$TERRAFORM_DIR"
        terraform destroy
        print_success "Infrastructure destroyed"
    else
        print_warning "Destruction cancelled"
    fi
    
    cd "$SCRIPT_DIR"
}

# Show info
show_info() {
    print_header "MinIO Information"
    
    if [ ! -f "$TERRAFORM_DIR/terraform.tfstate" ]; then
        print_error "No terraform.tfstate found. Have you deployed yet?"
        exit 1
    fi
    
    cd "$TERRAFORM_DIR"
    
    echo "Outputs:"
    terraform output
    
    cd "$SCRIPT_DIR"
}

# Generate backend config
generate_backend() {
    print_header "Generate Backend Configuration"
    
    if [ -f "generate-backend-config.sh" ]; then
        bash generate-backend-config.sh
    else
        print_error "generate-backend-config.sh not found"
    fi
}

# Show menu
show_menu() {
    print_header "MinIO Management Menu"
    echo "1. Check prerequisites"
    echo "2. Setup configuration"
    echo "3. Deploy MinIO"
    echo "4. Check status"
    echo "5. Show information"
    echo "6. Generate backend config"
    echo "7. Destroy infrastructure"
    echo "8. Exit"
    echo ""
    read -p "Select an option (1-8): " -r
    
    case $REPLY in
        1) check_prerequisites ;;
        2) setup_config ;;
        3) deploy ;;
        4) check_status ;;
        5) show_info ;;
        6) generate_backend ;;
        7) destroy ;;
        8) exit 0 ;;
        *) print_error "Invalid option" ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    show_menu
}

# Main
main() {
    if [ $# -eq 0 ]; then
        show_menu
    else
        case $1 in
            prereq|prerequisites)
                check_prerequisites
                ;;
            setup|config)
                setup_config
                ;;
            deploy|apply)
                deploy
                ;;
            status|check)
                check_status
                ;;
            info|show)
                show_info
                ;;
            backend)
                generate_backend
                ;;
            destroy)
                destroy
                ;;
            help|--help|-h)
                echo "Usage: $0 [command]"
                echo ""
                echo "Commands:"
                echo "  prereq      - Check prerequisites"
                echo "  setup       - Setup configuration files"
                echo "  deploy      - Deploy MinIO infrastructure"
                echo "  status      - Check MinIO status"
                echo "  info        - Show MinIO information"
                echo "  backend     - Generate backend configuration"
                echo "  destroy     - Destroy infrastructure"
                echo "  help        - Show this help"
                echo ""
                echo "Run without arguments for interactive menu"
                ;;
            *)
                print_error "Unknown command: $1"
                echo "Run '$0 help' for usage"
                exit 1
                ;;
        esac
    fi
}

main "$@"
