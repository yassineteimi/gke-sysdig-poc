# Security & Observability

Security in this PoC is layered: **identity** at the GCP/IAM boundary, **network segmentation** inside the cluster, and **Sysdig** for runtime threat detection and image vulnerability scanning. This page states what is enforced by default and what is available to switch on.

## IAM & workload identity

- **Dedicated node service account.** The GKE module is configured with `create_service_account = true`, so the cluster runs on its own service account rather than the project's default Compute SA. The node SA is bound only the **least-privilege roles** required to operate:

    | Role | Why |
    | --- | --- |
    | `roles/logging.logWriter` | Ship node and workload logs to Cloud Logging |
    | `roles/monitoring.metricWriter` | Emit metrics to Cloud Monitoring |
    | `roles/monitoring.viewer` | Read monitoring data |
    | `roles/stackdriver.resourceMetadata.writer` | Publish resource metadata for observability |

    This keeps the blast radius of a compromised node small — it cannot, for example, manage other project resources.

- **Per-workload Kubernetes service accounts — available, not enabled.** The [`service-accounts` Kustomize component](https://github.com/yassineteimi/gke-sysdig-poc/tree/main/kustomize/components/service-accounts) defines a dedicated `ServiceAccount` per microservice and patches each Deployment to use it, replacing the shared `default` SA. It ships **commented out** in `kustomize/kustomization.yaml`; enable it to give every service its own identity (and a foundation for GKE Workload Identity).

## Network policy

- **Default-deny segmentation — available, not enabled.** The [`network-policies` Kustomize component](https://github.com/yassineteimi/gke-sysdig-poc/tree/main/kustomize/components/network-policies) provides a `deny-all` baseline plus a tailored `NetworkPolicy` for each microservice, so a service can only receive traffic from the specific peers it needs (for example, only the frontend and checkout paths may reach `cartservice`/`redis`). Like the service-accounts component, it is **commented out by default** and enabled by uncommenting it in `kustomize/kustomization.yaml`.

!!! note "Enabling enforcement"
    Kubernetes `NetworkPolicy` objects are only enforced if the cluster runs a network-policy provider (e.g. GKE Dataplane V2 / Calico). Enable network-policy enforcement on the cluster before relying on these manifests.

## Runtime threat detection

Sysdig is provisioned via its **Terraform module** alongside the `sysdig` provider (Sysdig Secure SaaS, `eu1` region). The in-cluster Sysdig components observe syscall-level activity across the `sysdigtest` namespace and stream it to Sysdig Secure, where policies flag anomalous or malicious runtime behaviour — unexpected process execution, suspicious network connections, file integrity changes, and similar.

The Sysdig API token is treated as a secret throughout: it is a `sensitive` Terraform variable with **no default**, supplied at runtime via `TF_VAR_sysdig_secure_api_token`, and never committed.

## Vulnerability scanning

Sysdig scans the workload container images and exposes the results through the Sysdig Secure scanning API. The helper script [`sysdig_api/scanning_api.sh`](https://github.com/yassineteimi/gke-sysdig-poc/blob/main/sysdig_api/scanning_api.sh) retrieves CVE summaries, sorted by running-vulnerability severity:

- **Namespace-wide** — every image running in `sysdigtest` → `all_vulns.json`
- **Per-workload** — e.g. the `frontend` image → `frontend_vulns.json`

The script reads its token from the `SYSDIG_SECURE_API_TOKEN` environment variable and fails fast if it is unset, so credentials stay out of source control.

## Secret hygiene

The repository is configured so that sensitive material cannot be committed by accident:

- `*.tfstate*`, `*.tfvars`, kubeconfigs, private keys, `.env` files, and the Sysdig scan outputs are git-ignored.
- Terraform state — which contains the cluster endpoint, CA certificate, and access tokens — is flagged `sensitive` in [`output.tf`](https://github.com/yassineteimi/gke-sysdig-poc/blob/main/terraform/output.tf) and kept out of the repo.
- The committed `terraform.tfvars` carries only a placeholder `project_id`.

## Posture summary

| Control | Status |
| --- | --- |
| Dedicated least-privilege node service account | **Enforced by default** |
| Sysdig runtime threat detection | **Enforced** (provisioned via Terraform) |
| Sysdig image vulnerability scanning | **Enforced** (queryable via API) |
| Secret hygiene (git-ignore + sensitive outputs) | **Enforced by default** |
| Per-service network policies | Available — enable in Kustomize |
| Per-workload Kubernetes service accounts | Available — enable in Kustomize |
