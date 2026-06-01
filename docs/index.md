# GKE on GCP — Terraform + Sysdig Proof of Concept

A single `terraform apply` stands up a production-shaped **Google Kubernetes Engine** cluster on GCP, deploys an 11-service microservices application onto it, and wires in **Sysdig** for runtime threat detection and image vulnerability scanning. Infrastructure, application rollout, and security tooling are all codified — no console clicking.

## What this demonstrates

- **Infrastructure as Code, end to end** — VPC, subnets, a regional GKE cluster, a dedicated least-privilege node service account, cluster credentials, and the full application are provisioned from one Terraform root module.
- **Cloud-native security posture** — workload identity boundaries, optional Kubernetes NetworkPolicies, and Sysdig for runtime detection and CVE scanning, rather than security bolted on after the fact.
- **A realistic workload** — Google's *Online Boutique*, a polyglot, gRPC-based, 11-tier microservices app (plus a Redis cart), deployed via Kustomize into a dedicated namespace.
- **Repeatable and disposable** — the whole environment is created and torn down with `terraform apply` / `terraform destroy`, making it safe and cheap to run as a demo or a learning lab.

## At a glance

| Layer | Choice |
| --- | --- |
| Cloud | Google Cloud Platform |
| Cluster | Regional GKE, one `e2-standard-4` node pool (3 nodes) |
| Networking | Custom VPC `10.50.0.0/16`, secondary ranges for Pods and Services |
| Provisioning | Terraform (`terraform-google-modules` for project services, network, GKE) |
| Application | Online Boutique — 11 microservices + Redis, deployed with Kustomize |
| Security & observability | Sysdig Secure (runtime threat detection + image vulnerability scanning) |
| Optional add-on | Cloud Memorystore for Redis (feature-flagged) |

## How to read these docs

- **[Architecture](architecture.md)** — the cluster, the Terraform provisioning flow, and how Sysdig plugs in (with diagrams).
- **[Deployment](deployment.md)** — prerequisites and the exact steps to bring the environment up and tear it down.
- **[Security & Observability](security.md)** — IAM and node identity, network policy, runtime threat detection, and vulnerability scanning.

!!! note "Heritage & licensing"
    The application workload is built on Google Cloud Platform's [Online Boutique / `microservices-demo`](https://github.com/GoogleCloudPlatform/microservices-demo) (Apache 2.0). The Terraform root module and the Sysdig integration in this repository adapt that sample into a security-focused GKE proof of concept.
