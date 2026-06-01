# GKE on GCP — Terraform + Sysdig Proof of Concept

[![Docs](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://yassineteimi.github.io/gke-sysdig-poc/)
[![Deploy docs](https://github.com/yassineteimi/gke-sysdig-poc/actions/workflows/ci.yml/badge.svg)](https://github.com/yassineteimi/gke-sysdig-poc/actions/workflows/ci.yml)

A single `terraform apply` provisions a regional **Google Kubernetes Engine** cluster on GCP, deploys an 11-service microservices application onto it, and wires in **Sysdig** for runtime threat detection and image vulnerability scanning. Infrastructure, application, and security tooling are fully codified.

**📖 Full documentation:** **<https://yassineteimi.github.io/gke-sysdig-poc/>**

## Highlights

- **End-to-end IaC** — VPC, subnets, a VPC-native regional GKE cluster, a dedicated least-privilege node service account, cluster credentials, and the application are all provisioned from one Terraform root module using the official `terraform-google-modules`.
- **Security-first** — least-privilege node IAM, Sysdig runtime threat detection and CVE scanning, plus ready-to-enable Kubernetes NetworkPolicies and per-workload service accounts.
- **Realistic workload** — Google's *Online Boutique*: a polyglot, gRPC-based, 11-tier microservices app with a Redis cart, deployed via Kustomize.
- **Disposable** — `terraform apply` to build, `terraform destroy` to remove every resource and stop billing.

## Stack

| Layer | Choice |
| --- | --- |
| Cloud | Google Cloud Platform |
| Cluster | Regional GKE, one `e2-standard-4` node pool (3 nodes) |
| Networking | Custom VPC `10.50.0.0/16` with secondary ranges for Pods and Services |
| Provisioning | Terraform |
| Application | Online Boutique — 11 microservices + Redis (Kustomize) |
| Security & observability | Sysdig Secure (runtime detection + image vulnerability scanning) |

## Quickstart

```bash
git clone https://github.com/yassineteimi/gke-sysdig-poc.git
cd gke-sysdig-poc/terraform

# set project_id in terraform.tfvars, then supply the Sysdig token out of band
export TF_VAR_sysdig_secure_api_token="<your-sysdig-secure-api-token>"

terraform init
terraform apply
```

Full prerequisites, configuration, and teardown steps are in the [Deployment guide](https://yassineteimi.github.io/gke-sysdig-poc/deployment/).

## Documentation

| Page | Contents |
| --- | --- |
| [Overview](https://yassineteimi.github.io/gke-sysdig-poc/) | What the PoC is and what it demonstrates |
| [Architecture](https://yassineteimi.github.io/gke-sysdig-poc/architecture/) | Cluster, Terraform flow, and Sysdig integration (with diagrams) |
| [Deployment](https://yassineteimi.github.io/gke-sysdig-poc/deployment/) | Step-by-step provisioning and teardown |
| [Security & Observability](https://yassineteimi.github.io/gke-sysdig-poc/security/) | IAM, network policy, runtime threat detection, vulnerability scanning |

The documentation is built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) and deployed to GitHub Pages by [`.github/workflows/ci.yml`](.github/workflows/ci.yml) on every push to `main`.

## Credits & licensing

The application workload is built on Google Cloud Platform's [Online Boutique / `microservices-demo`](https://github.com/GoogleCloudPlatform/microservices-demo), licensed under Apache 2.0. The Terraform root module ([`terraform/`](terraform/)) and the Sysdig integration adapt that sample into a security-focused GKE proof of concept.
