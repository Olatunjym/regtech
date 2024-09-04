# RegTech Application Infrastructure as Code (IaC)

This repository contains the Terraform code for deploying a secure and scalable infrastructure for a fictional RegTech application using Google Cloud Platform (GCP).

## Prerequisites
Before deploying the infrastructure, ensure the following tools are installed:
- [Terraform](https://www.terraform.io/downloads.html)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)

You will also need to:
- Set up a GCP project and enable the Kubernetes Engine API, Compute Engine API, and IAM API.
- Create a service account with the necessary roles: Kubernetes Engine Admin, Storage Admin, and Compute Admin.
- Download the service account key in JSON format.

## Steps to Deploy

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd terraform


## CI/CD Pipeline

This repository uses GitHub Actions for continuous integration and deployment to a GKE cluster on GCP.

### Steps:
1. The pipeline is triggered on any push to the `main` branch.
2. The application is deployed to the GKE cluster using `kubectl`.
3. Automated tests are run after deployment.
4. If deployment fails, the pipeline rolls back to the previous stable version.

### Secrets:
- `GCP_PROJECT_ID`: Google Cloud project ID.
- `GCP_SERVICE_ACCOUNT_KEY`: Google Cloud service account key (JSON format).
- `GCP_ZONE`: GCP zone where the GKE cluster is deployed.
