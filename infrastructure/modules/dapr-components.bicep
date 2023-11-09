param environmentName string
param storageAccountName string
param blobContainerName string
param managedIdentityClientId string

resource environment 'Microsoft.App/managedEnvironments@2022-10-01' existing = {
  name: environmentName
}

// Dapr state store component
resource daprComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: 'statestore'
  parent: environment
  properties: {
    componentType: 'state.azure.blobstorage'
    version: 'v1'
    ignoreErrors: false
    initTimeout: '5s'
    metadata: [
      {
        name: 'accountName'
        value: storageAccountName
      }
      {
        name: 'containerName'
        value: blobContainerName
      }
      {
        name: 'azureClientId'
        value: managedIdentityClientId
      }
    ]
    scopes: []
  }
}
