# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Terraform + Ansible automation for AWS, driven by three manually-triggered GitHub Actions workflows. The Terraform layer provisions a VPC and EC2 instances; the Ansible layer installs Redis on instances tagged `Name=redis`.

## Commands

Local Terraform (requires `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` exported — the S3 backend cannot init without them):

```sh
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```

Region is supplied via [terraform.tfvars](terraform.tfvars) (`region = "us-east-2"`). Terraform CLI version pinned to **1.5.6** in all workflows — match this locally to avoid state-file version drift.

All three workflows are `workflow_dispatch` only (no push/PR triggers); run them from the GitHub Actions UI.

## Architecture

**State backend ([backend.tf](backend.tf))** — Remote state lives in S3 bucket `terraform-statefile-2710` under key `development/backend.tf`, with DynamoDB table `tadak-table` for locking, in `us-east-2`. The key path uses `.tf` as a suffix but the object is the tfstate JSON; the Redis workflow downloads this same S3 object and parses it as tfstate ([install-redis-on-ubuntu.yaml:29](.github/workflows/install-redis-on-ubuntu.yaml#L29)).

**Root module ([main.tf](main.tf))** — Composes the public `terraform-aws-modules/vpc/aws` module (NAT + VPN gateways enabled; AZs/CIDR/subnets come from variables) with two invocations of the local `./modules/ec2` module. Both EC2 instances currently land in `module.vpc.public_subnets[0]`. All AMI/instance-type/key-name/networking values are wired from [variables.tf](variables.tf) and set in [terraform.tfvars](terraform.tfvars).

**EC2 module ([modules/ec2/](modules/ec2/))** — Thin wrapper around `aws_instance` that takes `ami`, `instance_type`, `key_name`, `instance-name`, `app`, `subnet_id`. `associate_public_ip_address = true` is the only value hardcoded in the module. The `Name` tag comes from `instance-name`; the `application` tag comes from `app`.

**Redis workflow flow ([install-redis-on-ubuntu.yaml](.github/workflows/install-redis-on-ubuntu.yaml))** — Downloads tfstate from S3, uses `jq` to extract `public_dns` of every `aws_instance` whose `tags.Name == "redis"`, writes them into an Ansible inventory under group `redis_hosts`, loads the SSH key from `secrets.EC2_SSH_KEY`, and runs the playbook as user `ubuntu`. The playbook ([install_redis.yaml](install_redis.yaml)) targets host group `redis_hosts` — that group name is the contract between the workflow and the playbook.

## Gotchas

- **Filename mismatch:** [install-redis-on-ubuntu.yaml:73](.github/workflows/install-redis-on-ubuntu.yaml#L73) runs `ansible-playbook -i inventory.ini install_redis.yml`, but the file in the repo is `install_redis.yaml`. The Redis workflow will fail until one of them is renamed.
- **No instance is tagged `redis`:** [main.tf](main.tf) creates instances named `hema` and `rupa`. The Redis workflow's `jq` filter will return an empty host list against current state — add an instance with `instance-name = "redis"` (or change the filter) before expecting the playbook to do anything.
- **Single-AZ VPC:** [terraform.tfvars](terraform.tfvars) sets `azs = ["us-east-2a"]` with one public and one private subnet. Anything referencing `module.vpc.public_subnets[1]` will fail until tfvars is widened.
- **Region is partly hardcoded:** the S3 backend block ([backend.tf](backend.tf)) and `AWS_DEFAULT_REGION` in the Redis workflow ([install-redis-on-ubuntu.yaml:18](.github/workflows/install-redis-on-ubuntu.yaml#L18)) both bake in `us-east-2`. Terraform backend blocks do not accept variables, so this cannot be parameterized without a workflow-level `-backend-config` override. The `azs` in tfvars must also stay consistent with the backend region.

## Required secrets

GitHub repo secrets consumed by the workflows: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `EC2_SSH_KEY` (private key matching the hardcoded `key-may-2025` keypair).
