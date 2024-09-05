
# RegTech Application: Scalable and Secure Infrastructure

This repository contains the code and instructions for deploying a secure, scalable, and compliant infrastructure for a fictional RegTech application. The infrastructure processes sensitive financial data and adheres to strict regulatory requirements (e.g., GDPR, PCI-DSS).

## Overview
This project involves:
- Infrastructure as Code (IaC) using Terraform (executed via CI/CD pipeline).
- Continuous Integration/Continuous Deployment (CI/CD) pipelines using GitHub Actions.
- Security and compliance measures to meet industry standards.
- Monitoring and logging using Prometheus, Grafana, and Google Cloud Logging.

---

## 1. Infrastructure as Code (IaC)

The infrastructure is provisioned using Terraform on Google Cloud Platform (GCP), and the deployment is automated through GitHub Actions. Kubernetes (GKE) is used as the orchestration platform.

### Steps to Deploy the Infrastructure

Deployment is fully automated through the CI/CD pipeline triggered by a push to the `main` branch.

1. **Pipeline Execution**:
   - GitHub Actions handles the deployment.
   - Terraform is run automatically within the pipeline to create GKE clusters, nodes, and associated resources.

2. **GitHub Secrets Used**:
   - `GCP_PROJECT_ID`: The Google Cloud Project ID (use your specific project ID here).
   - `GCP_SERVICE_ACCOUNT_KEY`: Service account key for authentication (replace with the appropriate key reference).
   - `GCP_ZONE`: The Google Cloud zone for deploying the resources.

---

## 2. CI/CD Pipeline

The CI/CD pipeline is triggered on each push to the `main` branch and automates the deployment of infrastructure and the application to GKE.

### Pipeline Process:

1. **Checkout Code**: The pipeline checks out the code from the repository.
2. **Google Cloud SDK Setup**: Google Cloud SDK is configured using the provided service account key.
3. **Terraform Initialization and Application**: Terraform is initialized and applied automatically to create/update the GKE infrastructure.
4. **Kubernetes Deployment**: The application is deployed to the GKE cluster using `kubectl apply`.
5. **Post-Deployment Tests**: Automated tests are run to verify successful deployment.
6. **Rollback on Failure**: Rollbacks are triggered automatically in case of any deployment failure.

---

## 3. Security and Compliance

We implement security best practices to ensure the infrastructure is compliant with GDPR and PCI-DSS standards.

### Key Security Measures:
- **IAM Policies**: Identity and Access Management (IAM) policies enforce least-privilege access.
  - Example: Viewer roles assigned to the service account using:
    ```bash
    gcloud projects add-iam-policy-binding <project-id> \
      --member="serviceAccount:<service-account-email>" \
      --role="roles/viewer"
    ```
    (Replace `<project-id>` and `<service-account-email>` with actual project details)
- **Encryption in Transit**: Data is encrypted using TLS for secure communication.
- **Encryption at Rest**: Google Cloud's Customer-Managed Encryption Keys (CMEK) are used to control encryption keys.
- **Audit Logs**: Google Cloud's audit logs track all access and actions on the infrastructure.

---

## 4. Monitoring and Logging

The infrastructure is monitored using **Prometheus** and **Grafana**, with logs handled by **Google Cloud Logging**.

### Monitoring:
- **Prometheus**: Collects metrics on CPU usage, memory, and network traffic from the GKE cluster. The default scrape interval is 15 seconds.
  - Example Prometheus configuration:
    ```yaml
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
        - role: node
    ```
- **Grafana**: Visualizes metrics from Prometheus. Pre-configured dashboards monitor the system health.

### Logging:
- Logs are collected from Kubernetes workloads and infrastructure components using **Google Cloud Logging**.
- **Create a Cloud Storage Bucket** for logging:
  ```bash
  gsutil mb -l <bucket-region> gs://<bucket-name>
  ```
- **Logging Sink**: A logging sink is set up to export logs to Cloud Storage for auditing.
  ```bash
  gcloud logging sinks create gke-logs-sink storage.googleapis.com/<bucket-name> \
    --log-filter='resource.type="k8s_cluster"' \
    --project=<project-id>
  ```

---

## 5. DNS Configuration for Ingress

Once the Ingress is set up, you will need to configure your DNS to point to the Ingress's external IP.

### Steps:
1. **Get the Ingress External IP**:
   Run the following command to get the external IP of the Ingress:
   ```bash
   kubectl get ingress <ingress-name>
   ```

2. **Add DNS Record**:
   In your DNS provider's dashboard (e.g., Google Domains, GoDaddy), create an `A` record pointing to the Ingress external IP.

   - **DNS Name**: The subdomain you want to use (e.g., `app.testclik.net`).
   - **Resource Record Type**: `A` (for an address record).
   - **IPv4 Address**: The external IP of the Ingress.

Once the DNS changes propagate, you will be able to access the application at `https://<your-domain>`.

---

## 6. TLS Secret Setup

To enforce HTTPS for your application, you need to set up a **TLS secret**.

### Steps to Create the TLS Secret:
1. If you have the TLS certificate and key files, run the following command to create the secret:
   ```bash
   kubectl create secret tls tls-secret --cert=path/to/tls.crt --key=path/to/tls.key
   ```

2. Reference this secret in your Ingress definition:
   ```yaml
   spec:
     tls:
     - hosts:
       - <your-domain>
       secretName: tls-secret
   ```

This will ensure that all traffic to your domain is encrypted with TLS.

---

## 7. Alerts and Monitoring Rules

**Prometheus Alertmanager** is configured to trigger alerts based on system metrics. For example, an alert for high CPU usage is defined as follows:

```yaml
groups:
  - name: kubernetes-alerts
    rules:
    - alert: HighCPUUsage
      expr: 100 * (1 - avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[5m]))) > 90
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected"
        description: "CPU usage is above 90% for more than 5 minutes."
```

Alerts notify the team via configured channels (e.g., Slack, email) when thresholds are exceeded.

---

## 8. Additional Information

- **Clean-up**: To destroy the infrastructure, trigger the following in the CI/CD pipeline:
  ```bash
  terraform destroy
  ```

- **Authentication**: Ensure that secrets like `GCP_SERVICE_ACCOUNT_KEY` are securely stored in GitHub Actions secrets.

---

## Key Decisions

1. **GKE as the Orchestration Platform**: GKE was selected for its scalability, security, and ease of integration with GCP’s security and compliance tools.
2. **Prometheus and Grafana**: These open-source tools were chosen for monitoring as they provide granular metrics and custom dashboards, with easy integration into Kubernetes clusters.
3. **GitHub Actions for CI/CD**: GitHub Actions was selected for its seamless integration with the repository, automation capabilities, and support for secure secret management.

---
