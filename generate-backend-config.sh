#!/bin/bash

# Backend Configuration Generator
# This script helps generate Terraform backend configuration for MinIO

set -e

echo "=========================================="
echo "Terraform Backend Configuration Generator"
echo "=========================================="
echo ""

# Get MinIO details
read -p "MinIO IP address (e.g., 192.168.1.100): " MINIO_IP
read -p "MinIO API port [9000]: " MINIO_PORT
MINIO_PORT=${MINIO_PORT:-9000}

read -p "Bucket name [terraform-state]: " BUCKET_NAME
BUCKET_NAME=${BUCKET_NAME:-terraform-state}

read -p "State file path (e.g., project-name/terraform.tfstate): " STATE_PATH
read -p "AWS Region [us-east-1]: " REGION
REGION=${REGION:-us-east-1}

echo ""
echo "Access credentials (from MinIO Console):"
read -p "Access Key: " ACCESS_KEY
read -sp "Secret Key: " SECRET_KEY
echo ""

# Generate backend configuration file
BACKEND_FILE="backend-config.tf"
BACKEND_VARS_FILE="backend.tfvars"

cat > "$BACKEND_FILE" <<EOF
# Terraform Backend Configuration for MinIO
# Generated on $(date)

terraform {
  backend "s3" {
    endpoint                    = "http://${MINIO_IP}:${MINIO_PORT}"
    bucket                      = "${BUCKET_NAME}"
    key                         = "${STATE_PATH}"
    region                      = "${REGION}"
    
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
EOF

cat > "$BACKEND_VARS_FILE" <<EOF
# Terraform Backend Variables
# Generated on $(date)
# DO NOT COMMIT THIS FILE!

access_key = "${ACCESS_KEY}"
secret_key = "${SECRET_KEY}"
EOF

# Generate environment variable export script
ENV_FILE="backend.env"
cat > "$ENV_FILE" <<EOF
#!/bin/bash
# Terraform Backend Environment Variables
# Generated on $(date)
# Source this file: source backend.env

export AWS_ACCESS_KEY_ID="${ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${SECRET_KEY}"
export TF_VAR_access_key="${ACCESS_KEY}"
export TF_VAR_secret_key="${SECRET_KEY}"

echo "✓ Terraform backend credentials loaded"
echo "Run: terraform init"
EOF

chmod +x "$ENV_FILE"

# Generate .gitignore entry
if [ -f ".gitignore" ]; then
    if ! grep -q "backend.tfvars" .gitignore; then
        echo "backend.tfvars" >> .gitignore
        echo "backend.env" >> .gitignore
    fi
fi

echo ""
echo "=========================================="
echo "Files Generated"
echo "=========================================="
echo ""
echo "✓ $BACKEND_FILE - Backend configuration"
echo "✓ $BACKEND_VARS_FILE - Backend variables (KEEP SECURE!)"
echo "✓ $ENV_FILE - Environment variables script"
echo ""
echo "Usage Options:"
echo ""
echo "Option 1: Use environment variables"
echo "  source $ENV_FILE"
echo "  terraform init"
echo ""
echo "Option 2: Use backend config file"
echo "  terraform init -backend-config=$BACKEND_VARS_FILE"
echo ""
echo "Option 3: Use inline variables"
echo "  terraform init \\"
echo "    -backend-config=\"access_key=$ACCESS_KEY\" \\"
echo "    -backend-config=\"secret_key=$SECRET_KEY\""
echo ""
echo "⚠️  SECURITY WARNING:"
echo "  - DO NOT commit $BACKEND_VARS_FILE or $ENV_FILE"
echo "  - Store credentials securely (e.g., password manager)"
echo "  - Use environment variables in CI/CD pipelines"
echo ""

# Test connection
echo "Testing connection to MinIO..."
if curl -sf -o /dev/null "http://${MINIO_IP}:${MINIO_PORT}/minio/health/live"; then
    echo "✓ MinIO is reachable"
else
    echo "✗ Cannot reach MinIO - please verify the IP and port"
fi

echo ""
echo "Next steps:"
echo "1. Review the generated files"
echo "2. Choose an authentication method"
echo "3. Run: terraform init"
echo "4. Verify: terraform plan"
echo ""
