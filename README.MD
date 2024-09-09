
# RegTech Application: Scalable and Secure Infrastructure

This repository contains the code and instructions for deploying a secure, scalable, and compliant infrastructure for a fictional RegTech application. The infrastructure processes sensitive financial data and adheres to strict regulatory requirements (e.g., GDPR, PCI-DSS).

## Overview

This project involves:
- Infrastructure as Code (IaC) using Terraform (executed via CI/CD pipeline).
- Continuous Integration/Continuous Deployment (CI/CD) pipelines using GitHub Actions.
- Security and compliance measures to meet industry standards.
- Monitoring and logging using **Prometheus**, **Grafana**, and **Google Cloud Logging**.

---

## 1. Infrastructure as Code (IaC)

The infrastructure is provisioned using Terraform on Google Cloud Platform (GCP), and the deployment is automated through GitHub Actions. Kubernetes (GKE) is used as the orchestration platform.

### Steps to Deploy the Infrastructure

Deployment is fully automated through the CI/CD pipeline triggered by a push to the `main` branch.

1. **Pipeline Execution**:
   - GitHub Actions handles the deployment.
   - Terraform is run automatically within the pipeline to create GKE clusters, nodes, and associated resources.

2. **Connect to Your Kubernetes Cluster**:
   Before proceeding with any Kubernetes commands, make sure to connect to your GKE cluster:
   
   ```bash
   gcloud container clusters get-credentials youverify --region <REGION> --project <Proj_ID>
   ```

3. **GitHub Secrets Used**:
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

To ensure the infrastructure is secure and compliant with industry standards like GDPR and PCI-DSS, the following measures are in place:

### 3.1 Implementation of GDPR/PCI-DSS Compliance

1. **Data Encryption**:
   - Data is encrypted both in transit (via TLS) and at rest (using GCP’s Customer-Managed Encryption Keys).

2. **IAM Policies**:
   - Identity and Access Management (IAM) roles enforce least-privilege access to the resources, ensuring secure and compliant access control. For example, the service account managing the cluster needs proper role bindings:
   
   ```bash
   ACCOUNT=$(gcloud info --format='value(config.account)')
   kubectl create clusterrolebinding owner-cluster-admin-binding --clusterrole cluster-admin --user $ACCOUNT
   ```

   This command ensures the user has cluster-admin privileges to manage the GKE cluster securely.

3. **Logging and Auditing**:
   - Audit logs track actions taken by users on critical infrastructure resources, ensuring traceability. These logs are securely stored in **Google Cloud Logging**.

4. **Monitoring Compliance**:
   - **Prometheus and Alertmanager** are set up to monitor security breaches or GDPR/PCI-DSS compliance violations. Alerts are sent via **Alertmanager** to notify the team of any issues.

5. **Data Retention Policies**:
   - **Retention of Logs and Data**: Logs and data are retained according to compliance policies. Data that is no longer required is deleted in accordance with GDPR's "right to be forgotten."

---

## 4. Monitoring and Logging

The infrastructure is monitored using **Prometheus** and **Grafana**, with logs handled by **Google Cloud Logging**.

### Prometheus and Grafana Setup:

1. **Install NGINX Ingress Controller**:
   Before deploying the Ingress, install the NGINX Ingress controller on your GKE cluster:
   
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
   ```

2. **Create Monitoring Namespace**:
   You need to create the `monitoring` namespace to install Prometheus and Grafana.
   
   ```bash
   kubectl create namespace monitoring
   ```

3. **Install Prometheus Operator**:
   Install the Prometheus operator to manage the Prometheus setup on your cluster:

   ```bash
   helm install prometheus-operator prometheus-community/kube-prometheus-stack --namespace monitoring
   ```

4. **Apply Prometheus and Grafana Manifests**:
   Use the following command to apply the necessary manifests for Prometheus and Grafana:
   
   ```bash
   kubectl apply -f .
   ```

5. **Install kube-state-metrics**:
   Install `kube-state-metrics` to monitor Kubernetes resources:

   ```bash
   helm install kube-state-metrics prometheus-community/kube-state-metrics --namespace kube-system
   ```

6. **Install Node Exporter**:
   Install the Node Exporter to collect node-level metrics:

   ```bash
   helm install node-exporter prometheus-community/prometheus-node-exporter --namespace monitoring
   ```

7. **Verify Prometheus Installation**:
   - Ensure Prometheus and related components are running:
     ```bash
     kubectl get pods -n monitoring
     ```

8. **Access Grafana**:
   - Grafana will be accessible via the load balancer service. Check the external IP:
     ```bash
     kubectl get svc -n monitoring
     ```
   - Access Grafana using `http://<EXTERNAL-IP>:3000`. The default login credentials are:
     - **Username**: `admin`
     - **Password**: `admin` (You will be prompted to change it after the first login).

9. **Add Prometheus as Data Source**:
   - In the Grafana UI, go to **Configuration** > **Data Sources** > **Add Data Source** > **Prometheus**.
   - Set the URL to `http://prometheus-service:8080`.

10. **Import Dashboards**:
   - Import pre-built Grafana dashboards (e.g., **ID: 315** for Kubernetes Cluster Monitoring).

### Logging:

Logs are collected from Kubernetes workloads and infrastructure components using **Google Cloud Logging**.

- **Create a Cloud Storage Bucket** for logging:
  
  ```bash
  gsutil mb -l <bucket-region> gs://<bucket-name>
  ```

- **Create a Logging Sink** to export logs to the Cloud Storage bucket:
  
  ```bash
  gcloud logging sinks create gke-logs-sink storage.googleapis.com/<bucket-name>     --log-filter='resource.type="k8s_cluster"'     --project=<project-id>
  ```

---

## 5. DNS Configuration for Ingress and TLS

Once the Ingress and TLS secret are set up, you will need to configure DNS to point to the Ingress's external IP.

### Steps:

1. **Verify the Ingress External IP**:
   After the Ingress is successfully created and the NGINX Ingress controller is running, retrieve the external IP assigned to the Ingress:
   
   ```bash
   kubectl get ingress 
   ```

2. **Update DNS A Record**:
   In your DNS provider (e.g., Google Domains, GoDaddy, Cloudflare), create an A record pointing your domain (e.g., `regtech.testclik.net`) to the external IP address retrieved from the Ingress.

   - **DNS Name**: `regtech.testclik.net`
   - **Record Type**: `A` (Address record)
   - **IPv4 Address**: The external IP from the Ingress

3. **TLS Secret Setup**:
   Ensure that your `tls-secret` (the secret with the TLS certificate and key) is created in the same namespace as your Ingress resource. For example, if your Ingress is in the `default` namespace:

   ```bash
   kubectl create secret tls tls-secret --cert=path/to/tls.crt --key=path/to/tls.key --namespace default
   ```

4. **Ingress Resource with TLS**:
   Your Ingress resource should reference the TLS secret as follows:

   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: regtech-ingress
     annotations:
       kubernetes.io/ingress.class: "nginx"
       nginx.ingress.kubernetes.io/ssl-redirect: "true"
   spec:
     tls:
     - hosts:
         - regtech.testclik.net
       secretName: tls-secret
     rules:
     - host: regtech.testclik.net
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: regtech-app
               port:
                 number: 80
   ```

---
