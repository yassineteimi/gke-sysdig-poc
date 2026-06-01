# Deployment

Bring the entire environment — cluster, application, and Sysdig integration — up with a single Terraform run, then tear it down just as cleanly.

## Prerequisites

- A **Google Cloud project** with [billing enabled](https://cloud.google.com/billing/docs/how-to/verify-billing-enabled).
- Local tooling: [`terraform`](https://developer.hashicorp.com/terraform/install) (≥ 1.5), [`gcloud`](https://cloud.google.com/sdk/docs/install), and `kubectl`.
- Authenticated application-default credentials:

    ```bash
    gcloud auth application-default login
    ```

- A **Sysdig Secure API token** for the `eu1` region (Sysdig Secure → *Settings → Sysdig Secure API*).

## 1. Clone and enter the Terraform directory

```bash
git clone https://github.com/yassineteimi/gke-sysdig-poc.git
cd gke-sysdig-poc/terraform
```

## 2. Set required variables

Open `terraform.tfvars` and set your project ID:

```hcl
project_id  = "your-gcp-project-id"
memorystore = false   # set true to provision Cloud Memorystore (Redis) instead of in-cluster Redis
```

Provide the Sysdig token **out of band** — it is a `sensitive` variable with no default, and must never be committed:

```bash
export TF_VAR_sysdig_secure_api_token="<your-sysdig-secure-api-token>"
```

!!! warning "Never hardcode secrets"
    `terraform.tfstate`, `*.tfvars`, and the Sysdig token are git-ignored. State files contain cluster credentials and certificates — keep them local or in a remote backend, never in the repo. The repo ships a placeholder `project_id`; substitute your own.

## 3. Initialize, review, apply

```bash
terraform init
terraform plan
terraform apply
```

Confirm with `yes` at the prompt. The apply provisions, in order: required GCP APIs → VPC and subnet → regional GKE cluster and node pool → cluster credentials → the `sysdigtest` namespace → the Online Boutique workload (via `kubectl apply -k ../kustomize/`) → a readiness wait for all Pods → the Sysdig integration.

!!! note "Timing"
    A full apply takes roughly **10 minutes**. Do not interrupt it — the Kustomize apply and the Pod-readiness wait run as the final provisioning steps.

## 4. Access the application

Once apply completes, find the frontend's external IP:

```bash
kubectl get service frontend-external -n sysdigtest | awk '{print $4}'
```

Open `http://EXTERNAL_IP` in a browser to reach the Online Boutique storefront.

## 5. Pull Sysdig vulnerability results (optional)

With the Sysdig token exported, query CVE summaries for the namespace and the frontend workload:

```bash
cd ../sysdig_api
export SYSDIG_SECURE_API_TOKEN="$TF_VAR_sysdig_secure_api_token"
./scanning_api.sh        # writes all_vulns.json and frontend_vulns.json
```

## 6. Tear down

```bash
cd ../terraform
terraform destroy
```

Confirm with `yes`. This removes the cluster, network, namespace, Sysdig integration, and (if enabled) the Memorystore instance — stopping all associated billing.

## Configuration reference

| Variable | Default | Purpose |
| --- | --- | --- |
| `project_id` | — (required) | Target GCP project |
| `region` | `europe-west9` | Region for the cluster and network |
| `zones` | `["europe-west9-a"]` | Zones for the regional node pool |
| `cluster_name` | `online-boutique` | GKE cluster name |
| `namespace` | `sysdigtest` | Namespace the application is deployed into |
| `memorystore` | — (required) | `true` uses Cloud Memorystore (Redis); `false` uses in-cluster Redis |
| `sysdig_secure_api_token` | — (required, sensitive) | Sysdig Secure API token; supply via `TF_VAR_sysdig_secure_api_token` |
| `filepath_manifest` | `../kustomize/` | Kustomize path applied to the cluster |
