# CI/CD Integration with Terraform

This guide shows how to integrate the Terraform infrastructure with your CI/CD pipeline.

## GitHub Actions Integration

### 1. Create Terraform Workflow

Create `.github/workflows/terraform.yml`:

```yaml
name: Terraform Infrastructure Deployment

on:
  push:
    branches:
      - main
    paths:
      - 'infra/terraform/**'
  pull_request:
    branches:
      - main
    paths:
      - 'infra/terraform/**'
  workflow_dispatch:

env:
  TF_VERSION: '1.6.0'

jobs:
  terraform-plan:
    name: Terraform Plan
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./infra/terraform
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      - name: Setup gcloud
        uses: google-github-actions/setup-gcloud@v2

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Format Check
        run: terraform fmt -check -recursive

      - name: Terraform Plan
        run: terraform plan -no-color
        env:
          TF_VAR_gcp_project_id: ${{ secrets.GCP_PROJECT_ID }}

      - name: Comment PR with Plan
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const output = `#### Terraform Plan 📋
            \`\`\`
            ${{ steps.plan.outputs.stdout }}
            \`\`\`
            
            *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`, Workflow: \`${{ github.workflow }}\`*`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })

  terraform-apply:
    name: Terraform Apply
    runs-on: ubuntu-latest
    needs: terraform-plan
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: production
    defaults:
      run:
        working-directory: ./infra/terraform
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      - name: Setup gcloud
        uses: google-github-actions/setup-gcloud@v2

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve
        env:
          TF_VAR_gcp_project_id: ${{ secrets.GCP_PROJECT_ID }}

      - name: Get Terraform Outputs
        id: outputs
        run: |
          echo "aws_frontend_url=$(terraform output -raw aws_frontend_url)" >> $GITHUB_OUTPUT
          echo "aws_backend_url=$(terraform output -raw aws_backend_url)" >> $GITHUB_OUTPUT
          echo "gcp_frontend_url=$(terraform output -raw gcp_frontend_url)" >> $GITHUB_OUTPUT
          echo "gcp_backend_url=$(terraform output -raw gcp_backend_url)" >> $GITHUB_OUTPUT

      - name: Comment Deployment URLs
        uses: actions/github-script@v7
        with:
          script: |
            const output = `#### Deployment Successful! 🚀
            
            **AWS URLs:**
            - Frontend: ${{ steps.outputs.outputs.aws_frontend_url }}
            - Backend: ${{ steps.outputs.outputs.aws_backend_url }}
            
            **GCP URLs:**
            - Frontend: ${{ steps.outputs.outputs.gcp_frontend_url }}
            - Backend: ${{ steps.outputs.outputs.gcp_backend_url }}
            `;
            
            github.rest.repos.createCommitComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              commit_sha: context.sha,
              body: output
            })
```

### 2. Required GitHub Secrets

Add these secrets to your GitHub repository:

```
AWS_ACCESS_KEY_ID          # AWS access key
AWS_SECRET_ACCESS_KEY      # AWS secret key
GCP_CREDENTIALS            # GCP service account JSON
GCP_PROJECT_ID             # Your GCP project ID
```

#### Getting GCP Service Account Credentials

```bash
# Create service account
gcloud iam service-accounts create terraform-deploy \
  --display-name="Terraform Deployment"

# Grant required roles
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:terraform-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"

# Create and download key
gcloud iam service-accounts keys create key.json \
  --iam-account=terraform-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Copy the content of key.json to GitHub secret GCP_CREDENTIALS
cat key.json
```

## Combined Application + Infrastructure Workflow

### Full CI/CD Pipeline

```yaml
name: Full CI/CD Pipeline

on:
  push:
    branches: [develop, main]
  pull_request:
    branches: [main]

jobs:
  # Test stage
  test-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test Backend
        run: |
          cd backend
          pip install -r requirements.txt
          pytest

  test-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test Frontend
        run: |
          cd frontend
          npm install
          npm test

  # Build and push images
  build-and-push:
    needs: [test-backend, test-frontend]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # AWS ECR
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Login to AWS ECR
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push to ECR
        run: |
          # Backend
          docker build -t ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/pg-agi-backend:${{ github.sha }} ./backend
          docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/pg-agi-backend:${{ github.sha }}
          
          # Frontend
          docker build -t ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/pg-agi-frontend:${{ github.sha }} ./frontend
          docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/pg-agi-frontend:${{ github.sha }}

      # GCP GCR
      - name: Authenticate to GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      - name: Configure Docker for GCP
        run: gcloud auth configure-docker

      - name: Build and push to GCR
        run: |
          # Backend
          docker build -t gcr.io/${{ secrets.GCP_PROJECT_ID }}/pg-agi-backend:${{ github.sha }} ./backend
          docker push gcr.io/${{ secrets.GCP_PROJECT_ID }}/pg-agi-backend:${{ github.sha }}
          
          # Frontend
          docker build -t gcr.io/${{ secrets.GCP_PROJECT_ID }}/pg-agi-frontend:${{ github.sha }} ./frontend
          docker push gcr.io/${{ secrets.GCP_PROJECT_ID }}/pg-agi-frontend:${{ github.sha }}

  # Deploy infrastructure
  deploy-infrastructure:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    defaults:
      run:
        working-directory: ./infra/terraform
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: '1.6.0'

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Authenticate to GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      - name: Create terraform.tfvars
        run: |
          cat > terraform.tfvars <<EOF
          environment         = "production"
          project_name        = "pg-agi"
          deploy_to_aws       = true
          deploy_to_gcp       = true
          gcp_project_id      = "${{ secrets.GCP_PROJECT_ID }}"
          backend_image_aws   = "${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/pg-agi-backend:${{ github.sha }}"
          frontend_image_aws  = "${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/pg-agi-frontend:${{ github.sha }}"
          backend_image_gcp   = "gcr.io/${{ secrets.GCP_PROJECT_ID }}/pg-agi-backend:${{ github.sha }}"
          frontend_image_gcp  = "gcr.io/${{ secrets.GCP_PROJECT_ID }}/pg-agi-frontend:${{ github.sha }}"
          EOF

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve

      - name: Output URLs
        run: terraform output
```

## GitLab CI/CD Integration

### .gitlab-ci.yml

```yaml
stages:
  - validate
  - plan
  - apply

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/infra/terraform
  TF_VERSION: "1.6.0"

before_script:
  - cd ${TF_ROOT}
  - apk add --no-cache curl unzip
  - curl -o terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
  - unzip terraform.zip
  - mv terraform /usr/local/bin/
  - terraform --version

validate:
  stage: validate
  script:
    - terraform init
    - terraform validate
    - terraform fmt -check -recursive

plan:
  stage: plan
  script:
    - terraform init
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - ${TF_ROOT}/tfplan
    expire_in: 1 week
  only:
    - merge_requests
    - main

apply:
  stage: apply
  script:
    - terraform init
    - terraform apply -auto-approve tfplan
  dependencies:
    - plan
  only:
    - main
  when: manual
```

## Jenkins Integration

### Jenkinsfile

```groovy
pipeline {
    agent any
    
    environment {
        TF_VERSION = '1.6.0'
        AWS_REGION = 'us-east-1'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup Terraform') {
            steps {
                sh '''
                    wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
                    unzip -o terraform_${TF_VERSION}_linux_amd64.zip
                    sudo mv terraform /usr/local/bin/
                    terraform --version
                '''
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('infra/terraform') {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('infra/terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy infrastructure?', ok: 'Deploy'
                dir('infra/terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        
        stage('Output Results') {
            steps {
                dir('infra/terraform') {
                    sh 'terraform output'
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
```

## Best Practices for CI/CD

### 1. State Management

Use remote state backend:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "pg-agi/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### 2. Environment Separation

Create separate workspaces:

```bash
# Development
terraform workspace new dev
terraform workspace select dev

# Production
terraform workspace new prod
terraform workspace select prod
```

### 3. Secret Management

Never commit secrets to version control:
- Use GitHub Secrets
- Use AWS Secrets Manager
- Use GCP Secret Manager
- Use HashiCorp Vault

### 4. Plan Before Apply

Always run plan before apply in CI/CD:

```bash
terraform plan -out=tfplan
terraform show tfplan  # Review changes
terraform apply tfplan
```

### 5. Automated Testing

Use tools like:
- `terraform-compliance` for policy checks
- `tflint` for linting
- `checkov` for security scanning

```yaml
- name: Run TFLint
  run: |
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    tflint --init
    tflint

- name: Run Checkov
  run: |
    pip install checkov
    checkov -d infra/terraform
```

## Monitoring Deployments

### Add Slack Notifications

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: |
      Terraform deployment ${{ job.status }}
      AWS Frontend: ${{ steps.outputs.outputs.aws_frontend_url }}
      GCP Frontend: ${{ steps.outputs.outputs.gcp_frontend_url }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  if: always()
```

## Rollback Strategy

```bash
# Rollback to previous version
terraform state pull > backup.tfstate
terraform apply -target=module.aws_infrastructure \
  -var="backend_image_aws=<previous-image-tag>"
```

## References

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [GitHub Actions for Terraform](https://github.com/hashicorp/setup-terraform)
- [AWS ECS Deployment](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-types.html)
- [GCP Cloud Run Deployment](https://cloud.google.com/run/docs/deploying)
