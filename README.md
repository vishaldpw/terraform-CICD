# Terraform + Ansible CI/CD on AWS

End-to-end infrastructure automation powered by **Terraform**, **Ansible**, and **GitHub Actions**. Provision a VPC and EC2 fleet on AWS, configure Redis on tagged hosts, and tear everything down — all from the GitHub Actions UI.

---

## Overview

This repository delivers a fully automated pipeline that:

1. **Provisions** an AWS VPC and a set of EC2 instances using Terraform.
2. **Configures** Redis (and `cmatrix`) on every instance tagged `Name=redis` using Ansible.
3. **Destroys** all managed infrastructure on demand.

State is persisted to S3 with DynamoDB-backed locking, so the same workflow can be safely triggered from any environment.

---

## Architecture

```
                  ┌──────────────────────────────────────┐
                  │           GitHub Actions             │
                  │  (manual workflow_dispatch trigger)  │
                  └──────────────┬───────────────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        ▼                        ▼                        ▼
 ┌─────────────┐         ┌──────────────┐         ┌────────────────┐
 │  Terraform  │         │   Ansible    │         │   Terraform    │
 │    Apply    │         │  Configure   │         │    Destroy     │
 └──────┬──────┘         └──────┬───────┘         └────────┬───────┘
        │                       │                          │
        ▼                       ▼                          ▼
 ┌─────────────┐         ┌──────────────┐         ┌────────────────┐
 │ VPC + EC2s  │◄────────┤ Redis hosts  │         │ Resources gone │
 │  in AWS     │         │ (tag=redis)  │         │                │
 └─────────────┘         └──────────────┘         └────────────────┘
        │
        ▼
┌──────────────────────────────────────────┐
│ S3: terraform-statefile-2710             │
│ DynamoDB: tadak-table (state locking)    │
└──────────────────────────────────────────┘
```

---

## Repository Layout

| Path | Purpose |
|------|---------|
| [main.tf](main.tf) | Root module — composes VPC, security group, and EC2 instances. |
| [variables.tf](variables.tf) / [terraform.tfvars](terraform.tfvars) | Input variables and their values. |
| [backend.tf](backend.tf) | Remote state configuration (S3 + DynamoDB). |
| [provider.tf](provider.tf) | AWS provider configuration. |
| [modules/ec2/](modules/ec2/) | Reusable EC2 instance module. |
| [install_redis.yaml](install_redis.yaml) | Ansible playbook that installs Redis. |
| [.github/workflows/](.github/workflows/) | Three `workflow_dispatch` pipelines. |

---

## Workflows

All workflows are **manually triggered** from the *Actions* tab in GitHub.

### 1. Terraform Build — [apply-terraform.yaml](.github/workflows/apply-terraform.yaml)

Provisions the AWS infrastructure.

| Step | Description |
|------|-------------|
| Checkout | Pulls the repository. |
| Setup Terraform | Installs Terraform **1.5.6**. |
| Init | Initializes the S3 backend. |
| Plan | Renders the execution plan. |
| Apply | Applies changes with `-auto-approve`. |

### 2. Install Redis — [install-redis-on-ubuntu.yaml](.github/workflows/install-redis-on-ubuntu.yaml)

Configures Redis on every EC2 instance tagged `Name=redis`.

| Step | Description |
|------|-------------|
| Download tfstate | Fetches the latest state file from S3. |
| Parse hosts | Uses `jq` to extract `public_dns` of instances tagged `redis`. |
| Setup SSH | Loads the private key from `secrets.EC2_SSH_KEY`. |
| Build inventory | Generates an Ansible inventory under group `redis_hosts`. |
| Run playbook | Executes [install_redis.yaml](install_redis.yaml). |
| Cleanup | Wipes inventory, state file, and SSH key from the runner. |

### 3. Terraform Destroy — [Destroy-terraform.yaml](.github/workflows/Destroy-terraform.yaml)

Tears down all infrastructure managed by Terraform.

| Step | Description |
|------|-------------|
| Checkout | Pulls the repository. |
| Setup Terraform | Installs Terraform **1.5.6**. |
| Init | Initializes the S3 backend. |
| Destroy | Destroys resources with `-auto-approve`. |

---

## Provisioned Resources

The default `terraform apply` provisions:

- **1 VPC** (`10.0.0.0/16`) in `us-east-2a` with one public and one private subnet, NAT gateway enabled.
- **1 Security Group** allowing inbound SSH from anywhere (used by Ansible).
- **3 EC2 instances** (`t3.micro`, Ubuntu) — currently named:
  - `Pete` (app: `cg-airoli-old`)
  - `mike` (app: `cg-vikhroli-old`)
  - `redis` (app: `redis-cache`) — target of the Ansible playbook

---

## Required GitHub Secrets

| Secret | Used by | Purpose |
|--------|---------|---------|
| `AWS_ACCESS_KEY_ID` | All workflows | AWS authentication. |
| `AWS_SECRET_ACCESS_KEY` | All workflows | AWS authentication. |
| `EC2_SSH_KEY` | Redis workflow | Private key matching the `key-may-2025` keypair, used for SSH to EC2. |

---

## Running Locally

Export AWS credentials and ensure your Terraform CLI is on **1.5.6** to avoid state-file drift.

```sh
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

terraform init
terraform plan
terraform apply -auto-approve
```

To clean up:

```sh
terraform destroy -auto-approve
```

---

## State Management

| Setting | Value |
|---------|-------|
| Backend | S3 |
| Bucket | `terraform-statefile-2710` |
| Key | `development/backend.tf` |
| Lock Table | DynamoDB `tadak-table` |
| Region | `us-east-2` |

> The S3 object key uses a `.tf` suffix but stores tfstate JSON — the Redis workflow downloads and parses this object directly.

---

## Customizing the Deployment

| To change... | Edit |
|--------------|------|
| Region / CIDR / AMI / instance type / key name | [terraform.tfvars](terraform.tfvars) |
| Instance names, tags, or count | [main.tf](main.tf) |
| Packages installed by Ansible | [install_redis.yaml](install_redis.yaml) |
| Terraform CLI version | All three workflows under `.github/workflows/` |

---

## License

Internal automation project — add a license here if open-sourcing.
