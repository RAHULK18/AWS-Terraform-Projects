🌐 AWS Static Website Hosting with CloudFront (OAC) + S3

Terraform Project – Project-5

This project provisions a secure, scalable, and fully static website hosting architecture on AWS using S3 + CloudFront with Origin Access Control (OAC).
The entire infrastructure is deployed and managed using Terraform.

🚀 Architecture Overview
Key Components

Amazon S3 (Static Website Bucket)
Stores the website assets (index.html, error.html, images, CSS, etc.) but blocks all public access.

CloudFront Distribution (with OAC)
Delivers the website globally with low latency, HTTPS, caching, and DDoS protection (via AWS Shield Standard).

Origin Access Control (OAC)
Ensures only CloudFront can read objects from the S3 bucket — preventing direct public access.

Terraform
Automates provisioning of all resources, variables, and outputs.

📁 Project Structure
project-5/
├── error.html            # Custom error page
├── index.html            # Website home page
├── main.tf               # Core AWS resources (S3, CloudFront, OAC)
├── outputs.tf            # Useful outputs (CloudFront URL, S3 bucket, etc.)
├── providers.tf          # AWS provider configuration
├── rk-static.png         # Static asset (image used by website)
├── Terraform.code-workspace
├── terraform.tfstate*    # Terraform state files
└── variables.tf          # Input variables (bucket name, region, etc.)

🛠 Features Implemented

✔ Secure static hosting with S3 (private)
✔ CloudFront OAC for secure access to S3
✔ HTTPS-enabled content delivery
✔ Automatic invalidations & caching control
✔ Custom index and error pages
✔ Parameterized deployment with variables
✔ Terraform outputs for easy consumption

⚙️ How to Deploy
1️⃣ Initialize Terraform
terraform init

2️⃣ Validate configuration
terraform validate

3️⃣ Review plan
terraform plan

4️⃣ Deploy the infrastructure
terraform apply -auto-approve

🌍 Accessing Your Website

After deployment, Terraform will output:

CloudFront Domain Name
Example: d123abcd.cloudfront.net

Paste the URL in your browser — your static website is live globally 🎉

🧹 Clean Up Resources

To delete the stack:

terraform destroy
