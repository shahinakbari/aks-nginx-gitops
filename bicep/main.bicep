param location string = resourceGroup().location
param aksName string = 'dev-aks'
param acrName string = 'devacr${uniqueString(resourceGroup().id)}'
param k8sVersion string = '1.29.0'
param agentVMSize string = 'Standard_DS2'

@description('Create Azure Container Registry')
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

@description('Create Azure Kubernetes Service')
resource aks 'Microsoft.ContainerService/managedClusters@2023-01-01' = {
  name: aksName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'aksdemo'
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: 1
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]
    kubernetesVersion: k8sVersion
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
    }
  }
}

@description('Assign AcrPull role to AKS managed identity')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aks.id, 'acrpull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: aks.identity.principalId
  }
}
