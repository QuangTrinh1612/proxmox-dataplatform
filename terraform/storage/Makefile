.PHONY: help init plan apply destroy validate fmt clean test-ansible test-minio ssh logs

# Variables
MINIO_IP := $(shell terraform output -raw minio_ip_address 2>/dev/null || echo "192.168.1.200")
MINIO_USER := minioadmin
MINIO_PASS := minioadmin123

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform
	terraform init

validate: ## Validate Terraform configuration
	terraform validate

fmt: ## Format Terraform files
	terraform fmt -recursive

plan: ## Run Terraform plan
	terraform plan

apply: ## Apply Terraform configuration
	terraform apply

destroy: ## Destroy all resources
	terraform destroy

test-ansible: ## Test Ansible connectivity
	@echo "Testing Ansible connectivity to $(MINIO_IP)..."
	ansible all -i "$(MINIO_IP)," -u root -m ping

test-minio: ## Test MinIO connection
	@echo "Testing MinIO at $(MINIO_IP)..."
	@curl -s http://$(MINIO_IP):9000/minio/health/live || echo "MinIO API not responding"
	@echo ""
	@echo "MinIO Console: http://$(MINIO_IP):9001"

ssh: ## SSH into MinIO container
	ssh root@$(MINIO_IP)

logs: ## View MinIO logs
	ssh root@$(MINIO_IP) 'journalctl -u minio -f'

status: ## Show MinIO status
	@echo "Container Status:"
	@ssh root@$(MINIO_IP) 'systemctl status minio --no-pager' || echo "Cannot connect"

mc-install: ## Install MinIO client locally
	@if ! command -v mc &> /dev/null; then \
		echo "Installing MinIO client..."; \
		wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /tmp/mc; \
		chmod +x /tmp/mc; \
		sudo mv /tmp/mc /usr/local/bin/; \
		echo "MinIO client installed!"; \
	else \
		echo "MinIO client already installed"; \
	fi

mc-setup: mc-install ## Setup MinIO client alias
	mc alias set myminio http://$(MINIO_IP):9000 $(MINIO_USER) $(MINIO_PASS)
	@echo "MinIO client configured! Use: mc ls myminio"

bucket-list: ## List all buckets
	mc ls myminio/

backup: ## Backup Terraform state bucket
	@echo "Backing up terraform-state bucket..."
	@mkdir -p ./backup
	mc mirror --preserve myminio/terraform-state ./backup/terraform-state-$(shell date +%Y%m%d-%H%M%S)
	@echo "Backup complete!"

output: ## Show Terraform outputs
	terraform output

clean: ## Clean Terraform files
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

full-setup: init apply test-ansible test-minio mc-setup ## Complete setup from scratch
	@echo ""
	@echo "==================================="
	@echo "MinIO Setup Complete!"
	@echo "==================================="
	@echo "Console: http://$(MINIO_IP):9001"
	@echo "API: http://$(MINIO_IP):9000"
	@echo "Username: $(MINIO_USER)"
	@echo "Password: $(MINIO_PASS)"
	@echo ""
	@echo "Test with: mc ls myminio"