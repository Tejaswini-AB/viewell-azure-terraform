# Viwell Azure Infrastructure — Terraform

## One-time setup (do these before the first pipeline run)

### 1. Create the remote state storage account
```bash
az login
bash bootstrap/create-state-storage.sh
```
Creates `rg-tfstate-uaenorth-01` / `sttfstateuaenorth01` / container `tfstate`,
with blob versioning and 30-day soft delete enabled.

### 2. Create the GitHub OIDC service principal
Edit `GITHUB_ORG` and `GITHUB_REPO` in the script first, then:
```bash
bash bootstrap/create-github-oidc-sp.sh
```
This creates an App Registration with **no client secret** — GitHub Actions
authenticates using short-lived OIDC tokens instead. It grants the SP
`Contributor` on the subscription; narrow this to specific resource groups
later if you want tighter scoping.

### 3. Configure GitHub repo settings
**Variables** (Settings → Secrets and variables → Actions → Variables — these
are not secret, since OIDC needs no client secret):
| Name | Value |
|---|---|
| `AZURE_CLIENT_ID` | from step 2 output |
| `AZURE_TENANT_ID` | from step 2 output |
| `AZURE_SUBSCRIPTION_ID` | from step 2 output |
| `STAGING_POSTGRES_PRIVATE_DNS_ZONE_ID` | your `privatelink.postgres.database.azure.com` zone ID |
| `PRODUCTION_POSTGRES_PRIVATE_DNS_ZONE_ID` | same, for prod |
| `STAGING_REDIS_PRIVATE_DNS_ZONE_IDS` | your `privatelink.redis.cache.windows.net` zone ID(s) |
| `PRODUCTION_REDIS_PRIVATE_DNS_ZONE_IDS` | same, for prod |

**Secrets** (same location, Secrets tab):
| Name | Value |
|---|---|
| `STAGING_POSTGRES_ADMIN_PASSWORD` | strong password, staging DB |
| `PRODUCTION_POSTGRES_ADMIN_PASSWORD` | strong password, prod DB |

**Environments** (Settings → Environments):
- Create `staging` — no protection rules needed, or a light one if you prefer.
- Create `production` — add **at least one required reviewer**. This is what
  makes `terraform apply` pause for manual approval on production changes.

## How the pipelines work

- **`.github/workflows/terraform-staging.yml`** — runs on GitHub-hosted
  `ubuntu-latest` runners. Pull requests touching `environments/staging/**`
  or `modules/**` get a `terraform plan` posted as a PR comment. Merging to
  `main` triggers `terraform apply` automatically (environment `staging`,
  no approval gate).
- **`.github/workflows/terraform-production.yml`** — same plan-on-PR flow,
  but the apply job runs under the `production` GitHub Environment, so it
  **pauses for manual approval** before touching production.
- Both use `permissions: id-token: write` and `ARM_USE_OIDC: "true"` — no
  client secret is stored or transmitted anywhere.

## Local development

```bash
cp backend-config.hcl.example backend-config.hcl   # gitignored, edit if needed
az login
cd environments/staging
terraform init -backend-config=../../backend-config.hcl
export TF_VAR_subscription_id="<sub-id>"
export TF_VAR_postgres_administrator_password="<local-secret>"
export TF_VAR_postgres_private_dns_zone_id="<zone-id>"
terraform plan
```
Local auth falls back to `az login` (Azure CLI auth) since `use_oidc = true`
only activates when the OIDC environment variables GitHub Actions sets are
present; locally, the provider uses your `az` session instead.

## Repo layout
```
modules/            # reusable resource modules
environments/
  hub/               # shared hub VNet
  staging/           # non-prod workloads
  production/        # prod workloads, zone-resilient
bootstrap/           # one-time az cli setup scripts (not run by CI)
.github/workflows/   # CI/CD pipelines
```
