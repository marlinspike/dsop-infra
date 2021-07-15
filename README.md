# Infra for RKE2 on Azure

This repository holds the infra files required for you to create rke 2 on azure and deploy it to your subscription. Certain core assets are installed using an Azure Blueprint (details below) in a hub-and-spoke architecture. 

At present, only the blueprint is installed. RKE2 details coming soon.  

# Requirements

- Terraform
- Azure subscription

# Getting started

## Installation of a Hub and its first Spoke locally
Clone this repo. Create a `terraform.tfvars` file based on `terraform.tfvars.sample` and change the values of the spoke_* variables to the values of the spoke you want. Ensure deploy_hub = true.  

After that execute `terraform init` followed by `terraform apply`.  

## Installation of another Spoke locally
Same as above, but set deploy_hub = false.

## Installing a Hub and its first Spoke using the pipeline
Run pipeline DSOP/dsop-infra with your desired hub prefix and spoke details. Ensure you set deploy_hub = true.

## Installing a new spoke using the pipeline
Run pipeline DSOP/dsop-infra with the correct hub prefix (dsop) and desired spoke details. Ensure you set deploy_hub = false, i.e. don't check the box.  

## Removing a spoke or hub
The steps are:
1. Run `terraform destroy` with the terraform.tfvars for the spoke
2. Delete the resource group (if removing a hub)
3. Delete the tfstate file in Azure blob storage

Remove spokes before removing the hub. If you don't run `terraform destroy`, some role assignments and role definitions will persist and may cause problems in the future if you try to re-create a hub/spoke with the same names. Delete them from the subscription/IAM pages.  

## If there's a network conflict
Each new spoke requires a vnet address space. If you select one that's already peered with the hub network, you'll get a message like this: "cannot be peered because address space of the first virtual network overlaps with address space of virtual network". Recovery requires deletion of the new tfstate file, the resource group, the role assignments and role definition. Moral of the story: carefully select the address space of the spoke vnet.

# Reference
The repo deploys this blueprint [Azure Security Benchmark Foundation](https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/azure-security-benchmark-foundation/)

The github source of the blueprint is [here](https://github.com/Azure/azure-blueprints/tree/master/samples/001-builtins/ASBF_Gov).


