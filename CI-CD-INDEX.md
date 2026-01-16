CI/CD Documentation Index and Navigation
==========================================

Quick Navigation
================

New to the project?
-------------------
Start with these in order:
1. [README.md](README.md) - Project overview and local development setup
2. [QUICKSTART.md](QUICKSTART.md) - Get running in 5 minutes
3. [START-HERE.md](START-HERE.md) - Engineer onboarding guide

Configuring your environment?
------------------------------
1. [SETUP-COMPLETE.md](SETUP-COMPLETE.md) - Step-by-step GitHub secrets and CI setup
2. [.github/SECRETS.md](.github/SECRETS.md) - Secrets reference

Need to understand the pipeline?
--------------------------------
1. [README-CICD.md](README-CICD.md) - CI/CD overview and details
2. [PIPELINE-STRUCTURE.md](PIPELINE-STRUCTURE.md) - Repository and workflow layout
3. [.github/PIPELINE.md](.github/PIPELINE.md) - Pipeline deep dive

Getting Started Guides
======================

Project Setup
-------------
- [README.md](README.md)
  - Project purpose and structure
  - Local development setup (Backend + Frontend)
  - Configuration instructions
  - Docker build examples

Quick Start (5 Minutes)
-----------------------
- [QUICKSTART.md](QUICKSTART.md)
  - Prerequisites checklist
  - Configure GitHub secrets
  - Run tests locally (optional)
  - Trigger CI and verify images

Engineer Onboarding
-------------------
- [START-HERE.md](START-HERE.md)
  - Audience: Engineers and DevOps practitioners
  - Workflow overview
  - Required secrets
  - File structure and navigation

Configuration and Deployment
=============================

Setup and Configuration
-----------------------
- [SETUP-COMPLETE.md](SETUP-COMPLETE.md)
  - Step 1: Create Docker Hub token
  - Step 2: Configure GitHub secrets
  - Step 3-4: Verify secrets and trigger CI
  - Step 5-7: Verify images, test results, optional deployment

Implementation Summary
----------------------
- [IMPLEMENTATION-COMPLETE.md](IMPLEMENTATION-COMPLETE.md)
  - What's been delivered
  - Key decisions and tradeoffs
  - Configuration requirements
  - Recommended reading

CI/CD Reference Documentation
==============================

Pipeline and Workflows
----------------------
- [README-CICD.md](README-CICD.md)
  - Purpose and pipeline summary
  - CI (develop) stages and triggers
  - Deployment workflows (disabled templates)
  - Configuration and secrets
  - Image naming and tagging
  - Testing coverage
  - Monitoring and troubleshooting

Pipeline Details
----------------
- [.github/PIPELINE.md](.github/PIPELINE.md)
  - CI pipeline stages and outputs
  - Deployment workflow information
  - Secrets summary
  - Caching and tagging strategy
  - Testing steps
  - Notes on enabling deployment

Workflow Reference
------------------
- [.github/WORKFLOW_REFERENCE.md](.github/WORKFLOW_REFERENCE.md)
  - ci-develop.yml workflow details
  - deploy-main.yml.disabled and cd-main.yml.disabled
  - Setup, caching, and tagging

Architecture Overview
---------------------
- [.github/ARCHITECTURE.md](.github/ARCHITECTURE.md)
  - Components overview
  - CI flow visualization
  - Deployment stance
  - Observability and validation

Quick Reference
---------------
- [.github/QUICK-REFERENCE.md](.github/QUICK-REFERENCE.md)
  - Branches summary
  - Secrets checklist
  - Image tag format
  - Local test commands

Secrets and Configuration
--------------------------
- [.github/SECRETS.md](.github/SECRETS.md)
  - Required secrets: DOCKERHUB_TOKEN
  - Optional secrets: DOCKERHUB_USERNAME
  - Configuration instructions
  - Security best practices

Troubleshooting
---------------
- [.github/TROUBLESHOOTING.md](.github/TROUBLESHOOTING.md)
  - CI npm install failures
  - Docker Hub push failures
  - Playwright E2E test issues
  - Disabled deployment workflows
  - Solutions and debugging steps

Repository Structure
====================

Repository Layout
-----------------
- [PIPELINE-STRUCTURE.md](PIPELINE-STRUCTURE.md)
  - Complete directory structure
  - Backend, frontend, .github directories
  - Infrastructure and Terraform layout
  - Key files and their purposes
  - Documentation map
  - CI/CD pipeline flow diagram

Application Structure
=====================

Backend
-------
- Framework: FastAPI
- Language: Python 3.12
- Tests: pytest
- Location: `backend/app/`
- Docker: Multi-stage build

Frontend
--------
- Framework: Next.js
- Language: JavaScript/TypeScript
- Tests: npm test, Playwright E2E
- Location: `frontend/`
- Docker: Multi-stage build

Infrastructure and Deployment
==============================

Deployment Guides
-----------------
- [infra/DEPLOYMENT-CHECKLIST.md](infra/DEPLOYMENT-CHECKLIST.md)
  - Pre-deployment verification
  - Requirements checklist
  - Environment validation steps

Cloud Deployment Templates
--------------------------
- [infra/aws-ecs-config.md](infra/aws-ecs-config.md)
  - AWS ECS task definitions
  - Service configuration
  - Load balancer setup

- [infra/k8s-deployment.md](infra/k8s-deployment.md)
  - Kubernetes deployment manifests
  - Service and ingress configuration

Terraform Infrastructure
------------------------
- [infra/terraform/README.md](infra/terraform/README.md)
  - Terraform project setup
  - Module structure
  - Configuration instructions

- [infra/terraform/INDEX.md](infra/terraform/INDEX.md)
  - Terraform modules overview
  - Module descriptions

- [infra/TERRAFORM-SETUP-COMPLETE.md](infra/TERRAFORM-SETUP-COMPLETE.md)
  - Terraform setup completion guide

- [infra/TERRAFORM-PROJECT-SUMMARY.md](infra/TERRAFORM-PROJECT-SUMMARY.md)
  - Project summary and overview

- [infra/VALIDATION-REPORT.md](infra/VALIDATION-REPORT.md)
  - Infrastructure validation results

Documentation Map by Use Case
=============================

For Local Development
---------------------
1. [README.md](README.md) - Setup instructions
2. [QUICKSTART.md](QUICKSTART.md) - Fast start
3. Run tests locally per instructions

For CI/CD Configuration
-----------------------
1. [SETUP-COMPLETE.md](SETUP-COMPLETE.md) - Step-by-step configuration
2. [.github/SECRETS.md](.github/SECRETS.md) - Secrets reference
3. [README-CICD.md](README-CICD.md) - Pipeline details

For Pipeline Understanding
---------------------------
1. [README-CICD.md](README-CICD.md) - Overview
2. [PIPELINE-STRUCTURE.md](PIPELINE-STRUCTURE.md) - Structure and flow
3. [.github/PIPELINE.md](.github/PIPELINE.md) - Deep dive
4. [.github/WORKFLOW_REFERENCE.md](.github/WORKFLOW_REFERENCE.md) - Specific workflows

For Troubleshooting
-------------------
1. [.github/TROUBLESHOOTING.md](.github/TROUBLESHOOTING.md) - Common issues
2. [README-CICD.md](README-CICD.md) - Monitoring section
3. GitHub Actions logs in Actions tab

For Deployment
---------------
1. [SETUP-COMPLETE.md](SETUP-COMPLETE.md) - Step 7: Enable workflows
2. [infra/DEPLOYMENT-CHECKLIST.md](infra/DEPLOYMENT-CHECKLIST.md) - Pre-deployment
3. Cloud-specific: [infra/aws-ecs-config.md](infra/aws-ecs-config.md) or [infra/k8s-deployment.md](infra/k8s-deployment.md)
4. Terraform: [infra/terraform/README.md](infra/terraform/README.md)

Key Files by Topic
==================

Secrets and Credentials
-----------------------
- [SETUP-COMPLETE.md](SETUP-COMPLETE.md) - Step 2: Configure
- [.github/SECRETS.md](.github/SECRETS.md) - Reference
- [README-CICD.md](README-CICD.md) - Configuration section

Docker Images
-------------
- [PIPELINE-STRUCTURE.md](PIPELINE-STRUCTURE.md) - Image tagging section
- [.github/QUICK-REFERENCE.md](.github/QUICK-REFERENCE.md) - Image tags reference
- [README-CICD.md](README-CICD.md) - Image naming section

Testing
-------
- [README.md](README.md) - Local test commands
- [README-CICD.md](README-CICD.md) - Testing coverage section
- [.github/TROUBLESHOOTING.md](.github/TROUBLESHOOTING.md) - Test failures

Branches and Git Workflow
-------------------------
- [START-HERE.md](START-HERE.md) - Branch summary
- [.github/QUICK-REFERENCE.md](.github/QUICK-REFERENCE.md) - Branches
- [README-CICD.md](README-CICD.md) - CI and deployment branches

Next Steps
==========

1. Choose your path above based on your role
2. Follow linked documents in order
3. Refer back to this index for cross-references
4. Bookmark key documents for quick access

Search Tips
===========

- Use GitHub's search (Ctrl+F) within documentation
- Navigate via cross-referenced links
- Refer to "Next Steps" sections in each document
