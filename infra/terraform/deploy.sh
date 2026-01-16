#!/bin/bash

# Terraform Deployment Script
# This script helps deploy infrastructure to AWS and/or GCP

set -e

echo "==================================="
echo "PG-AGI Infrastructure Deployment"
echo "==================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

print_info "Terraform version: $(terraform version | head -n 1)"

# Navigate to terraform directory
cd "$(dirname "$0")"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_warning "terraform.tfvars not found. Copying from example..."
    cp terraform.tfvars.example terraform.tfvars
    print_warning "Please edit terraform.tfvars with your configuration before proceeding."
    exit 1
fi

# Parse command line arguments
ACTION=${1:-plan}
TARGET=${2:-all}

print_info "Action: $ACTION"
print_info "Target: $TARGET"

# Initialize Terraform
print_info "Initializing Terraform..."
terraform init -upgrade

# Validate configuration
print_info "Validating Terraform configuration..."
terraform validate

if [ $? -ne 0 ]; then
    print_error "Terraform validation failed!"
    exit 1
fi

print_info "Validation successful!"

# Format check
print_info "Checking Terraform formatting..."
terraform fmt -check -recursive || print_warning "Some files need formatting. Run 'terraform fmt -recursive' to fix."

# Execute action based on user input
case $ACTION in
    plan)
        print_info "Running Terraform plan..."
        if [ "$TARGET" == "all" ]; then
            terraform plan -out=tfplan
        elif [ "$TARGET" == "aws" ]; then
            terraform plan -target=module.aws_infrastructure -out=tfplan
        elif [ "$TARGET" == "gcp" ]; then
            terraform plan -target=module.gcp_infrastructure -out=tfplan
        else
            print_error "Invalid target: $TARGET. Use 'all', 'aws', or 'gcp'"
            exit 1
        fi
        ;;
    
    apply)
        print_info "Applying Terraform configuration..."
        if [ -f "tfplan" ]; then
            terraform apply tfplan
            rm tfplan
        else
            if [ "$TARGET" == "all" ]; then
                terraform apply
            elif [ "$TARGET" == "aws" ]; then
                terraform apply -target=module.aws_infrastructure
            elif [ "$TARGET" == "gcp" ]; then
                terraform apply -target=module.gcp_infrastructure
            else
                print_error "Invalid target: $TARGET. Use 'all', 'aws', or 'gcp'"
                exit 1
            fi
        fi
        
        print_info "Deployment completed successfully!"
        print_info "Getting outputs..."
        terraform output
        ;;
    
    destroy)
        print_warning "This will destroy your infrastructure!"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" == "yes" ]; then
            if [ "$TARGET" == "all" ]; then
                terraform destroy
            elif [ "$TARGET" == "aws" ]; then
                terraform destroy -target=module.aws_infrastructure
            elif [ "$TARGET" == "gcp" ]; then
                terraform destroy -target=module.gcp_infrastructure
            else
                print_error "Invalid target: $TARGET. Use 'all', 'aws', or 'gcp'"
                exit 1
            fi
            print_info "Destruction completed!"
        else
            print_info "Destruction cancelled."
        fi
        ;;
    
    output)
        print_info "Showing Terraform outputs..."
        terraform output
        ;;
    
    *)
        print_error "Invalid action: $ACTION"
        echo "Usage: $0 {plan|apply|destroy|output} {all|aws|gcp}"
        echo ""
        echo "Examples:"
        echo "  $0 plan          - Plan deployment for all infrastructure"
        echo "  $0 plan aws      - Plan deployment for AWS only"
        echo "  $0 apply         - Apply infrastructure changes"
        echo "  $0 apply gcp     - Apply GCP infrastructure only"
        echo "  $0 destroy       - Destroy all infrastructure"
        echo "  $0 output        - Show output values"
        exit 1
        ;;
esac

print_info "Done!"
