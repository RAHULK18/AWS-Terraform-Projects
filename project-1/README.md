🏗️ Terraform AWS Multi-Tier VPC Infrastructure with S3 Backend Bootstrap

This project demonstrates a production-grade Terraform setup for provisioning a multi-tier AWS VPC environment, complete with public and private subnets, NAT gateways, and a remote S3 backend for state management.

It follows real-world DevOps best practices — modular design, environment separation, and backend bootstrapping — ideal for showcasing your Terraform skills in interviews or on GitHub.

📁 Project Structure
.
├── bootstraps/                 # Step 1 – Create backend (S3 bucket for Terraform state)
│   ├── main.tf
│   └── terraform.tfstate
├── dev/                        # Step 2 – Environment-specific config (uses S3 backend)
│   ├── main.tf
│   ├── terraform.tfvars
│   └── variables.tf
├── modules/                    # Reusable Terraform modules
│   └── vpc/
│       ├── main.tf
│       ├── outputs.tf
│       ├── variables.tf
│       └── versions.tf
└── README.md                   # Documentation (this file)

🚀 Overview
🔹 Step 1 – Bootstrap Backend (S3)

Before any Terraform project can store its state remotely, the backend (S3 bucket) must exist.
The bootstraps/ directory contains Terraform code that creates:

An S3 bucket for storing Terraform state

Versioning for state recovery

Server-side encryption (AES-256) for security

(Optional) DynamoDB table for state locking

Once created, all environments (dev/stage/prod) share this same backend.

🔹 Step 2 – Deploy the VPC Infrastructure

The dev/ directory uses the newly created backend to provision:

A custom VPC

Public and private subnets across multiple AZs

Internet Gateway for public subnets

NAT Gateway for private subnets

Route tables for proper traffic flow

Tagging for environment and cost tracking

⚙️ Prerequisites

Terraform v1.3 or newer (tested up to v1.13)

AWS CLI configured with at least one profile (e.g. terraform-project)

IAM permissions to create:

S3 buckets

VPC, Subnets, Route Tables

NAT/IGW

Elastic IPs

🧰 Setup Instructions
1️⃣ Bootstrap the Backend

Run this only once per AWS account/region:

cd bootstraps
export AWS_PROFILE=terraform-project
terraform init
terraform apply -auto-approve


✅ This creates the S3 bucket demo-2025-terraform-state for storing Terraform state files.

2️⃣ Initialize the Environment

Switch to your environment directory (dev in this example):

cd ../dev
export AWS_PROFILE=terraform-project
terraform init -reconfigure
terraform plan
terraform apply


✅ This provisions the entire AWS VPC stack using the remote backend created earlier.

🌐 AWS Architecture Diagram (Conceptual)
        +-------------------------------+
        |         AWS VPC (10.0.0.0/16) |
        |                               |
        |  +----------+   +-----------+ |
        |  | Public   |   | Public    | | → Internet Gateway
        |  | Subnet A |   | Subnet B  | |
        |  +----------+   +-----------+ |
        |       |               |       |
        |   NAT GW A       NAT GW B     |
        |       |               |       |
        |  +----------+   +-----------+ |
        |  | Private  |   | Private   | |
        |  | Subnet A |   | Subnet B  | |
        |  +----------+   +-----------+ |
        +-------------------------------+

🧩 Terraform Highlights
Feature	Description
Modular Design	VPC logic isolated in modules/vpc
Reusable Variables	Parameterized CIDRs, tags, NAT settings
Backend Separation	Bootstrap S3 backend before environment provisioning
Multi-AZ Deployment	Uses for_each loops for public & private subnets
Tagging	Automatic tagging for Environment & Project
Version Control Friendly	Includes .gitignore to protect state & secrets
🛡️ Security Best Practices

State files stored in S3 with versioning + encryption

Optional DynamoDB locking prevents concurrent state corruption

All credentials managed through AWS profiles or IAM roles

No sensitive .tfvars or .tfstate committed to Git

💬 Example Variables (dev/terraform.tfvars)
region  = "us-west-2"
profile = "terraform-project"

🧠 Learning / Interview Takeaways

Understand why backend bootstrapping is separate

Show how to structure modular, reusable IaC

Demonstrate multi-AZ, cost-optimized, and secure VPCs

Know how to explain backend migration and locking during interviews

🏁 Cleanup

To destroy all resources (VPC + subnets):

cd dev
terraform destroy -auto-approve


To remove the bootstrap backend (use cautiously):

cd ../bootstraps
terraform destroy -auto-approve
