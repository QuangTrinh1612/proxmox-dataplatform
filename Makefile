.PHONY: help init plan apply destroy ansible-setup ansible-check clean validate

# Default target
help:
	@echo "MinIO on Proxmox - Infrastructure Management"
	@echo ""
	@echo "Available targets:"
	@echo "  init           - Initialize Terraform"
	@echo "  validate       - Validate Terraform configuration"
	@echo "  plan           - Show Terraform execution plan"
	@echo "  apply          - Deploy MinIO infrastructure"
	@echo "  destroy        - Destroy MinIO infrastructure"
	@echo "  ansible-check  - Check Ansible connectivity"
	@echo "  ansible-setup  - Run Ansible playbook manually"
	@echo "  clean          - Clean Terraform files"
	@echo "  status         - Check MinIO service status"
	@echo ""

# Terraform operations
init:
	@echo "Initializing Terraform..."
	cd terraform && terraform init

validate:
	@echo "Validating Terraform configuration..."
	cd terraform && terraform validate

plan:
	@echo "Creating Terraform execution plan..."
	cd terraform && terraform plan

apply:
	@echo "Deploying MinIO infrastructure..."
	cd terraform && terraform apply

destroy:
	@echo "Destroying MinIO infrastructure..."
	cd terraform && terraform destroy

# Ansible operations
ansible-check:
	@echo "Checking Ansible connectivity..."
	cd ansible && ansible minio -i inventory.yml -m ping

ansible-setup:
	@echo "Running Ansible playbook..."
	@read -p "Enter MinIO IP address: " IP; \
	read -p "Enter sudo username: " USER; \
	cd ansible && ansible-playbook -i inventory.yml minio-setup.yml \
		-e "minio_host=$$IP" \
		-e "ansible_user=$$USER" \
		--ask-become-pass

# Utility operations
clean:
	@echo "Cleaning Terraform files..."
	cd terraform && rm -rf .terraform/ .terraform.lock.hcl terraform.tfstate*

status:
	@echo "Checking MinIO status..."
	@read -p "Enter MinIO IP address: " IP; \
	read -p "Enter sudo username: " USER; \
	ssh $$USER@$$IP "sudo systemctl status minio"

# Setup wizard
setup:
	@echo "=== MinIO Setup Wizard ==="
	@echo ""
	@if [ ! -f terraform/terraform.tfvars ]; then \
		echo "Creating terraform.tfvars from example..."; \
		cp terraform/terraform.tfvars.example terraform/terraform.tfvars; \
		echo "✓ Please edit terraform/terraform.tfvars with your values"; \
	else \
		echo "✓ terraform.tfvars already exists"; \
	fi
	@echo ""
	@echo "Next steps:"
	@echo "1. Edit terraform/terraform.tfvars"
	@echo "2. Edit ansible/group_vars/all.yml"
	@echo "3. Run: make init"
	@echo "4. Run: make plan"
	@echo "5. Run: make apply"
