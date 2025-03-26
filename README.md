# 🚀 AKS GitOps Deployment – Nginx on Azure Kubernetes Service

This project demonstrates how to deploy a simple Nginx web application on **Azure Kubernetes Service (AKS)** using **GitHub Actions** as a GitOps workflow.

---

## 🎯 Project Goals

- Provision an AKS cluster and Azure Container Registry (ACR) using Bicep
- Deploy Nginx on AKS using Kubernetes YAML manifests
- Automate deployment using GitHub Actions (CI/CD)
- Enable Azure Monitor for logs and metrics

---

## 🧱 Infrastructure – Bicep

Defined in `bicep/main.bicep`:

- AKS cluster with System-Assigned Identity
- Azure Container Registry (ACR)
- Role Assignment so AKS can pull images from ACR

### 🧪 Deploy Bicep Template

```bash
az group create --name aks-rg --location canadaeast

az deployment group create \
  --resource-group aks-rg \
  --template-file bicep/main.bicep
```

---

## 📦 Application Deployment – Nginx

Kubernetes manifest is defined in `manifests/nginx-deployment.yaml`:

```bash
kubectl apply -f manifests/nginx-deployment.yaml
```

This deploys a simple Nginx container and exposes it via a LoadBalancer service.

---

## 🔁 GitOps with GitHub Actions

GitHub Actions workflow is located in `.github/workflows/deploy-nginx.yml`.

On each push to the `main` branch that affects files in `manifests/`, the following happens:

- Authenticate to Azure
- Set AKS context
- Deploy the updated manifest using `kubectl apply`

### 🔐 Configure Secret in GitHub

Create a secret named `AZURE_CREDENTIALS` using the output of:

```bash
az ad sp create-for-rbac --name "github-aks-deployer" \
  --role contributor \
  --scopes /subscriptions/<sub-id>/resourceGroups/aks-rg \
  --sdk-auth
```

---

## 📊 Azure Monitor Integration

To enable logging and metrics:

```bash
az monitor log-analytics workspace create \
  --resource-group monitoring-rg \
  --workspace-name aks-logs

az aks enable-addons \
  --resource-group aks-rg \
  --name dev-aks \
  --addons monitoring \
  --workspace-resource-id <workspace-resource-id>
```

Then view metrics in Azure Portal > AKS Cluster > Insights.

---

## 🧹 Cleanup Resources

To avoid ongoing costs:

```bash
az group delete --name aks-rg --yes --no-wait
az group delete --name monitoring-rg --yes --no-wait
```

---

## 🙌 Author

Built with ❤️ by [Shahin Akbari](https://www.linkedin.com/in/shahinakbari)
