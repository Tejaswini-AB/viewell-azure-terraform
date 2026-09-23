#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# One-time bootstrap: creates an Azure AD App Registration + Service
# Principal, grants it Contributor on the subscription, and configures
# federated credentials so GitHub Actions can authenticate via OIDC —
# no client secret is ever generated or stored.
#
# Run this ONCE, manually, with an account that has permission to create
# app registrations and role assignments.
# ---------------------------------------------------------------------------
set -euo pipefail

APP_NAME="sp-viwell-github-actions"
GITHUB_ORG="<your-github-org>"      # e.g. "viwell"
GITHUB_REPO="<your-repo-name>"      # e.g. "azure-infra"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

echo "Creating app registration: $APP_NAME"
APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)

echo "Creating service principal for app: $APP_ID"
az ad sp create --id "$APP_ID" >/dev/null

echo "Granting Contributor on subscription $SUBSCRIPTION_ID"
az role assignment create \
  --assignee "$APP_ID" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID" >/dev/null

# Federated credential: allow the 'main' branch to authenticate (used for apply)
az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "github-main-branch",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'"$GITHUB_ORG"'/'"$GITHUB_REPO"':ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}' >/dev/null

# Federated credential: allow pull requests to authenticate (used for plan)
az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "github-pull-requests",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'"$GITHUB_ORG"'/'"$GITHUB_REPO"':pull_request",
  "audiences": ["api://AzureADTokenExchange"]
}' >/dev/null

# Federated credential: allow the 'production' GitHub Environment specifically
# (used for the production apply job, which requires manual approval)
az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "github-production-environment",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'"$GITHUB_ORG"'/'"$GITHUB_REPO"':environment:production",
  "audiences": ["api://AzureADTokenExchange"]
}' >/dev/null

echo ""
echo "Done. Add these as GitHub Actions repo VARIABLES (not secrets — none of"
echo "these values are secret when using OIDC):"
echo "  AZURE_CLIENT_ID       = $APP_ID"
echo "  AZURE_TENANT_ID        = $TENANT_ID"
echo "  AZURE_SUBSCRIPTION_ID = $SUBSCRIPTION_ID"
echo ""
echo "Also create a 'production' Environment in GitHub repo settings with a"
echo "required reviewer, so production apply needs manual approval."
