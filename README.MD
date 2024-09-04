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
