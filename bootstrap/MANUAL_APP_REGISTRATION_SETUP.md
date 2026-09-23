# Adding OIDC to Your Existing Service Principal

You already have an App Registration (currently using a client secret). To
switch to OIDC, you add federated credentials to that **same** App
Registration — you don't need to create a new one. Once federated
credentials are added, the client secret becomes unnecessary for GitHub
Actions (you can leave it in place for other uses, or delete it once OIDC
is confirmed working).

## 1. Add three federated credentials
In the Azure Portal: your App Registration → **Certificates & secrets** →
**Federated credentials** → **Add credential** → scenario "GitHub Actions
deploying Azure resources". Repeat three times with these exact values
(replace `<ORG>/<REPO>` with your actual GitHub org and repo name):

| Purpose | Issuer | Subject | Audience |
|---|---|---|---|
| Plan on pull requests | `https://token.actions.githubusercontent.com` | `repo:<ORG>/<REPO>:pull_request` | `api://AzureADTokenExchange` |
| Apply on merge to main | `https://token.actions.githubusercontent.com` | `repo:<ORG>/<REPO>:ref:refs/heads/main` | `api://AzureADTokenExchange` |
| Production apply (Environment-gated) | `https://token.actions.githubusercontent.com` | `repo:<ORG>/<REPO>:environment:production` | `api://AzureADTokenExchange` |
| Hub apply (Environment-gated) | `https://token.actions.githubusercontent.com` | `repo:<ORG>/<REPO>:environment:hub` | `api://AzureADTokenExchange` |

Equivalent via `az cli`, if you prefer:
```bash
APP_ID="<your-existing-client-id>"
ORG_REPO="<org>/<repo>"

az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "github-pull-requests",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'"$ORG_REPO"':pull_request",
  "audiences": ["api://AzureADTokenExchange"]
}'

az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "github-main-branch",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'"$ORG_REPO"':ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'

az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "github-production-environment",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'"$ORG_REPO"':environment:production",
  "audiences": ["api://AzureADTokenExchange"]
}'

az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "github-hub-environment",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'"$ORG_REPO"':environment:hub",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

These three subjects must match exactly what the workflows trigger on
(`pull_request`, `push` to `main`, and the `production` GitHub Environment).
If you rename the branch, change triggers, or rename the Environment, update
the subject to match — a mismatch fails with `AADSTS70021` at runtime.

## 2. Update GitHub repo settings
Settings → Secrets and variables → Actions.

**Variables** (not sensitive):
| Name | Value |
|---|---|
| `AZURE_CLIENT_ID` | your existing client ID |
| `AZURE_TENANT_ID` | your tenant ID |
| `AZURE_SUBSCRIPTION_ID` | your subscription ID |

You can now **remove** `AZURE_CLIENT_SECRET` from repo Secrets — it's no
longer read by either workflow. Leave the Postgres admin password secrets
as they are; those are unrelated to Azure auth.

## 3. Confirm role assignment still applies
The federated credential doesn't change permissions — the service
principal still needs Contributor (or your scoped-down role) on the
subscription, same as before. No action needed if that's already in place.

## 4. Once confirmed working
Consider deleting the client secret from the App Registration in Azure AD
(Certificates & secrets → Client secrets), since it's now an unused,
unnecessary standing credential.
