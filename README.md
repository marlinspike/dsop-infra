# Infra for RKE2 on Azure

This repository holds the infra files required for you to create rke 2 on azure and deploy it to your subscription.

# Requirements

- Terraform
- Azure subscription

# Getting started


Create a `terraform.tfvars` file based on `terraform.tfvars.sample` and change the values of the spoke_* variables to the value of the spoke you want.

If this is the first deployment of the hub and spoke network make sure you set deploy hub to true.

After that all you would need to do it is execute `terraform init` followed by `terraform apply`

# Reference

This repo deploy the blueprint [Azure Security Benchmark Foundation](https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/azure-security-benchmark-foundation/)


