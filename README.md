# *GitHub Actions Workflows*

This repository contains *workflows designed for infrastructure management* using *Terraform* and *Ansible*. Each workflow operates independently, focusing on *infrastructure provisioning*, *Redis installation* on targeted hosts, and *infrastructure decommissioning*. With *AWS credentials* and *SSH keys* secured in *GitHub Secrets*, these workflows enhance automation, simplify infrastructure management, and increase operational consistency.

---

## *Tools Used*

The following tools are utilized in the workflows to automate infrastructure provisioning, management, and decommissioning:

### *Terraform*

*Terraform* is an open-source infrastructure as code (IaC) tool that enables you to define and provision cloud infrastructure using a declarative configuration language. It is used in the workflows to automate the creation, modification, and teardown of cloud resources on platforms like *AWS*. With its built-in state management and powerful modules, *Terraform* ensures consistent and repeatable infrastructure setups.

### *Ansible*

*Ansible* is an open-source automation tool that simplifies the management of systems, applications, and IT infrastructure. It uses simple, human-readable YAML files (playbooks) to describe automation tasks. In these workflows, *Ansible* is used to install and configure *Redis* on *AWS EC2 instances*, using dynamic inventories to target specific hosts and ensuring the correct setup across multiple servers.

### *GitHub Actions*

*GitHub Actions* is a CI/CD and automation platform built into GitHub. It allows you to automate workflows and tasks based on events such as commits, pull requests, or manual triggers. In this repository, *GitHub Actions* is used to automate infrastructure provisioning with *Terraform*, configuration management with *Ansible*, and decommissioning of resources. It securely integrates with *GitHub Secrets* to handle sensitive data such as AWS credentials and SSH keys.

---

## *Workflows*

### *1. Terraform Build Workflow*

**Purpose**  
This workflow provisions infrastructure using *Terraform*, applying configurations defined in the repository. It is typically used to create or update cloud resources.

**Trigger**  

- *Manual Execution*: Triggered manually through the *GitHub Actions* interface.

**Key Steps**  

- **Checkout Code**: Checks out the repository code to access Terraform files.
- **Set up Terraform**: Configures the environment with *Terraform version 1.5.6*.
- **Terraform Init**: Initializes Terraform, setting up the backend. AWS credentials are securely passed as secrets.
- **Terraform Plan**: Runs `terraform plan` to preview infrastructure changes.
- **Terraform Apply**: Executes `terraform apply -auto-approve` to provision infrastructure as per the configurations.

**Environment Requirements**  

- *AWS credentials* (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) must be stored in *GitHub Secrets*.

---

### *2. Install Redis on Tagged Ubuntu Hosts*

**Purpose**  
This workflow installs *Redis* on *AWS EC2 instances* tagged with `Name=redis`, using *Ansible* to manage the installation on remote servers.

**Trigger**  

- *Manual Execution*: Triggered manually through the *GitHub Actions* interface.

**Key Steps**  

- **Checkout Repository**: Retrieves the repository code to access Ansible playbooks and scripts.
- **Set up AWS CLI**: Installs *AWS CLI* to retrieve the Terraform state file from S3.
- **Download tfstate file from S3**: Downloads the `terraform.tfstate` file to identify EC2 instances tagged as `redis`.
- **Set up Python and Install Dependencies**: Installs Python dependencies (`ansible`, `boto3`, `jq`) for AWS and Ansible operations.
- **Parse Hostnames from tfstate file**: Extracts hostnames of instances tagged as `redis` for Ansible targeting.
- **Set up SSH Key**: Configures the SSH key (from GitHub Secrets) to authenticate with remote instances.
- **Create Ansible Inventory**: Dynamically generates an Ansible inventory file with the Redis hostnames.
- **Run Ansible Playbook to Install Redis**: Executes the `install_redis.yml` playbook to install Redis on each target.
- **Cleanup**: Removes temporary files (inventory file, tfstate, SSH key) for security.

**Environment Requirements**  

- *AWS credentials* (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) and an *SSH key* (`EC2_SSH_KEY`) must be stored in *GitHub Secrets*.
- Hosts must allow SSH access with the *ubuntu* user.

---

### *3. Terraform Destroy Workflow*

**Purpose**  
This workflow decommissions infrastructure provisioned by *Terraform*, ensuring a clean teardown of cloud resources.

**Trigger**  

- *Manual Execution*: Triggered manually through the *GitHub Actions* interface.

**Key Steps**  

- **Checkout Code**: Checks out repository code for Terraform configurations.
- **Set up Terraform**: Configures the environment with *Terraform version 1.5.6*.
- **Terraform Init**: Initializes Terraform, preparing it for backend state management.
- **Terraform Destroy**: Runs `terraform destroy -auto-approve` to remove all resources, using AWS credentials.

**Environment Requirements**  

- *AWS credentials* (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) must be stored in *GitHub Secrets*.

---

Each workflow is crafted to *simplify infrastructure processes* and ensure a *secure, automated environment*.
