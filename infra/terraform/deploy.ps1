# PowerShell Terraform Deployment Script
# This script helps deploy infrastructure to AWS and/or GCP

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('plan', 'apply', 'destroy', 'output')]
    [string]$Action = 'plan',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('all', 'aws', 'gcp')]
    [string]$Target = 'all'
)

$ErrorActionPreference = "Stop"

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "PG-AGI Infrastructure Deployment" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if Terraform is installed
try {
    $terraformVersion = terraform version
    Write-Info "Terraform version: $($terraformVersion[0])"
} catch {
    Write-ErrorMessage "Terraform is not installed. Please install it first."
    exit 1
}

# Navigate to terraform directory
Set-Location $PSScriptRoot

# Check if terraform.tfvars exists
if (-not (Test-Path "terraform.tfvars")) {
    Write-Warning "terraform.tfvars not found. Copying from example..."
    Copy-Item "terraform.tfvars.example" "terraform.tfvars"
    Write-Warning "Please edit terraform.tfvars with your configuration before proceeding."
    exit 1
}

Write-Info "Action: $Action"
Write-Info "Target: $Target"

# Initialize Terraform
Write-Info "Initializing Terraform..."
terraform init -upgrade

if ($LASTEXITCODE -ne 0) {
    Write-ErrorMessage "Terraform initialization failed!"
    exit 1
}

# Validate configuration
Write-Info "Validating Terraform configuration..."
terraform validate

if ($LASTEXITCODE -ne 0) {
    Write-ErrorMessage "Terraform validation failed!"
    exit 1
}

Write-Info "Validation successful!"

# Format check
Write-Info "Checking Terraform formatting..."
terraform fmt -check -recursive
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Some files need formatting. Run 'terraform fmt -recursive' to fix."
}

# Execute action based on user input
switch ($Action) {
    'plan' {
        Write-Info "Running Terraform plan..."
        if ($Target -eq 'all') {
            terraform plan -out=tfplan
        } elseif ($Target -eq 'aws') {
            terraform plan -target=module.aws_infrastructure -out=tfplan
        } elseif ($Target -eq 'gcp') {
            terraform plan -target=module.gcp_infrastructure -out=tfplan
        }
    }
    
    'apply' {
        Write-Info "Applying Terraform configuration..."
        if (Test-Path "tfplan") {
            terraform apply tfplan
            Remove-Item tfplan
        } else {
            if ($Target -eq 'all') {
                terraform apply
            } elseif ($Target -eq 'aws') {
                terraform apply -target=module.aws_infrastructure
            } elseif ($Target -eq 'gcp') {
                terraform apply -target=module.gcp_infrastructure
            }
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Info "Deployment completed successfully!"
            Write-Info "Getting outputs..."
            terraform output
        } else {
            Write-ErrorMessage "Deployment failed!"
            exit 1
        }
    }
    
    'destroy' {
        Write-Warning "This will destroy your infrastructure!"
        $confirm = Read-Host "Are you sure? (yes/no)"
        if ($confirm -eq 'yes') {
            if ($Target -eq 'all') {
                terraform destroy
            } elseif ($Target -eq 'aws') {
                terraform destroy -target=module.aws_infrastructure
            } elseif ($Target -eq 'gcp') {
                terraform destroy -target=module.gcp_infrastructure
            }
            Write-Info "Destruction completed!"
        } else {
            Write-Info "Destruction cancelled."
        }
    }
    
    'output' {
        Write-Info "Showing Terraform outputs..."
        terraform output
    }
}

Write-Info "Done!"
