# GitHub Actions Workflows

Automated infrastructure management using Terraform and Ansible for AWS provisioning, Redis installation, and resource cleanup.

## Workflows

### 1. Terraform Build
**Purpose:** Provision AWS infrastructure  
**Trigger:** Manual execution  
**Steps:**
- Checkout code
- Setup Terraform v1.5.6
- Init, plan, and apply configurations

**Requirements:** AWS credentials in GitHub Secrets

### 2. Redis Installation
**Purpose:** Install Redis on EC2 instances tagged `Name=redis`  
**Trigger:** Manual execution  
**Steps:**
- Download tfstate from S3
- Parse Redis hostnames
- Run Ansible playbook
- Cleanup temporary files

**Requirements:** AWS credentials and SSH key in GitHub Secrets

### 3. Terraform Destroy
**Purpose:** Remove all provisioned infrastructure  
**Trigger:** Manual execution  
**Steps:**
- Checkout code
- Setup Terraform v1.5.6
- Init and destroy resources

**Requirements:** AWS credentials in GitHub Secrets
