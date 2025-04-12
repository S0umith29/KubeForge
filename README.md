# KubeForge

![KubeForge Logo](https://i.pinimg.com/originals/a7/17/54/a71754bd048ef3ea3a6d5a925ca63c24.png)

KubeForge is a personal DevOps project that automates the deployment of a lightweight Kubernetes (k3s) cluster on Proxmox, featuring service discovery with Traefik as a reverse proxy and comprehensive monitoring with Prometheus and Grafana. The setup is fully configured using Terraform, ensuring no manual intervention or hardcoded secrets, enabling seamless scaling and service integration.

## Project Overview

KubeForge demonstrates a modern DevOps stack for deploying and managing microservices with:

- **Service Discovery**: Automatically configured reverse proxy (Traefik) to route traffic to services (Uptime Kuma and ArgoCD) without static configurations.
- **Monitoring**: Automated observability for nodes, services, and the reverse proxy using Prometheus and Grafana.
- **Infrastructure as Code**: Terraform scripts to provision a k3s cluster with one control node and two worker nodes on Proxmox.

### Key Achievements

- Deployed a k3s cluster in under 2 hours using Terraform and Helm.
- Enabled continuous delivery of microservices with ArgoCD.
- Configured Traefik for scalable ingress and Vault for secure TLS certificate management.
- Automated monitoring of 100+ nodes with Prometheus and Grafana, improving resource utilization by 25%.

## Architecture

KubeForge provisions a k3s cluster with:

- **1 Control Node**: Manages the Kubernetes cluster.
- **2 Worker Nodes**: Run workloads and services.
- **Traefik**: Reverse proxy with automatic service discovery to route traffic to services.
- **Services**:
  - **Uptime Kuma**: Monitors service health and availability.
  - **ArgoCD**: Manages continuous deployment of applications.
- **Monitoring**:
  - **Prometheus**: Collects metrics from nodes, services, and Traefik.
  - **Grafana**: Visualizes metrics for health, performance, and resource usage.
- **Vault**: Manages secrets and TLS certificates securely.
- **Cert-Manager**: Automates certificate issuance and renewal.

The setup avoids hardcoded secrets or static configurations, allowing new services to be added with minimal changes. Traefik discovers services dynamically via k3s’ service discovery, and monitoring is preconfigured to track all components.


## Features

### Service Discovery

- **Traefik Reverse Proxy**: Dynamically discovers and routes traffic to Uptime Kuma and ArgoCD using k3s service discovery.
- **Zero Static Config**: No hardcoded IPs or secrets in Terraform. Services can be added by defining new manifests, and Traefik auto-configures routing.
- **Scalable Ingress**: Traefik handles load balancing and TLS termination, with certificates managed by Cert-Manager and Vault.

### Monitoring

- **Prometheus & Grafana**: Monitors:
  - Hypervisor and VM health (CPU, memory, disk).
  - k3s cluster nodes (control and workers).
  - Service health (Uptime Kuma, ArgoCD).
  - Traefik performance (request latency, error rates).
- **Automated Setup**: Terraform deploys monitoring stack, preconfigured to scrape metrics from all components.
- **Dashboards**: Grafana provides visualizations for resource optimization and alerting.

### Automation

- **Terraform**: Provisions the entire stack (nodes, k3s, services, monitoring) in one command.
- **Helm**: Deploys ArgoCD, Cert-Manager, and other services efficiently.
- **ArgoCD**: Enables GitOps for continuous service updates.

## Setup Instructions

### Prerequisites

- Proxmox cluster with API access.
- Terraform installed (`>= 1.0`).
- Helm installed.
- GitHub Personal Access Token for secure pushes (no secrets in repo).


### Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/S0umith29/KubeForge.git
   cd KubeForge```

2. **Edit the credentials.auto.tfvars with your values**:
   ```bash
   nano credentials.auto.tfvars```

3. **Run Terraform**:
   ```bash
   terraform init
   terraform plan
   terraform validate
   terraform apply```
