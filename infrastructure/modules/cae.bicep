@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param name string = 'cae-${uniqueString(resourceGroup().id)}'

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a logAnalytics workspace Id')
param logAnalyticsWorkspaceId string

@description('Provide a azureContainerRegistry Name')
param azureContainerRegistryName string
param acrPullDefinitionId string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
param uniqueSeed string = '${subscription().subscriptionId}-${resourceGroup().name}'
param uniqueSuffix string = uniqueString(uniqueSeed)
param storageAccountName string = 'st${replace(uniqueSuffix, '-', '')}'
param blobContainerName string = 'orders'
param managedIdentityName string = 'nodeapp-identity'

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspaceId, '2020-03-01-preview').customerId
        sharedKey: listKeys(logAnalyticsWorkspaceId, '2020-03-01-preview').primarySharedKey
      }
    }
  }
}

// Storage Account to act as state store
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
    name: storageAccountName
    location: location
    kind: 'StorageV2'
    sku: {
      name: 'Standard_LRS'
    }
  }

  resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
    parent: storageAccount
    name: 'default'
  }

  resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
    parent: blobService
    name: blobContainerName
  }

  resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
    name: managedIdentityName
    location: location
  }

  // Grant permissions for the container app to write to Azure Blob via Managed Identity
  @description('This is the built-in Storage Blob Data Contributor role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor')
  resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
    scope: storageAccount
    name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  }

  resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
    name: guid(resourceGroup().id, contributorRoleDefinition.id)
    properties: {
      roleDefinitionId: contributorRoleDefinition.id
      principalId: managedIdentity.properties.principalId
      principalType: 'ServicePrincipal'
    }
  }

  // roleDefinitionId is the ID found here for AcrPull: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull
  resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    name: guid(resourceGroup().id, azureContainerRegistryName, 'AcrPullTestUserAssigned')
    properties: {
      principalId: managedIdentity.properties.principalId
      principalType: 'ServicePrincipal'
      // acrPullDefinitionId has a value of 7f951dda-4ed3-4680-a7ca-43fe172d538d
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', acrPullDefinitionId)
    }
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
          value: managedIdentity.properties.clientId
        }
      ]
      scopes: [
        'app'
        'api'
      ]
    }
    dependsOn: [
      storageAccount
    ]
  }


  resource api 'Microsoft.App/containerApps@2022-03-01' = {
    name: 'api'
    location: location
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${managedIdentity.id}' : {}
      }
    }
    properties: {
      managedEnvironmentId: environment.id
      configuration: {
        ingress: {
          external: true
          targetPort: 80
        }
        // dapr: {
        //   enabled: true
        //   appId: 'api'
        //   appProtocol: 'http'
        //   appPort: 80
        // }
        registries: [
          {
            server: '${azureContainerRegistryName}.azurecr.io'
            identity: managedIdentity.id
          }
        ]
      }
      template: {
        containers: [
          {
            image: '${azureContainerRegistryName}.azurecr.io/api:latest'
            name: 'api'
            env: [
            ]
            resources: {
              cpu: json('0.5')
              memory: '1.0Gi'
            }
          }
        ]
        scale: {
          minReplicas: 0
          maxReplicas: 1
        }
      }
    }
    dependsOn: [
      daprComponent
    ]
  }

  resource app 'Microsoft.App/containerApps@2022-03-01' = {
    name: 'app'
    location: location
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${managedIdentity.id}' : {}
      }
    }
    properties: {
      managedEnvironmentId: environment.id
      configuration: {
        ingress: {
          external: true
          targetPort: 80
        }
        // dapr: {
        //   enabled: true
        //   appId: 'app'
        //   appProtocol: 'http'
        //   appPort: 80
        // }
        registries: [
          {
            server: '${azureContainerRegistryName}.azurecr.io'
            identity: managedIdentity.id
          }
        ]
      }
      template: {
        containers: [
          {
            image: '${azureContainerRegistryName}.azurecr.io/app:latest'
            name: 'app'
            env: [
              {
                name: 'API_BASE_URL'
                value: 'http://${api.properties.configuration.ingress.fqdn}'
              }
            ]
            resources: {
              cpu: json('0.5')
              memory: '1.0Gi'
            }
          }
        ]
        scale: {
          minReplicas: 0
          maxReplicas: 1
        }
      }
    }
    dependsOn: [
      daprComponent
    ]
  }

//   resource pythonapp 'Microsoft.App/containerApps@2022-03-01' = {
//     name: 'pythonapp'
//     location: location
//     properties: {
//       managedEnvironmentId: environment.id
//       configuration: {
//         dapr: {
//           enabled: true
//           appId: 'pythonapp'
//         }
//       }
//       template: {
//         containers: [
//           {
//             image: 'dapriosamples/hello-k8s-python:latest'
//             name: 'hello-k8s-python'
//             resources: {
//               cpu: json('0.5')
//               memory: '1.0Gi'
//             }
//           }
//         ]
//         scale: {
//           minReplicas: 1
//           maxReplicas: 1
//         }
//       }
//     }
//     dependsOn: [
//       nodeapp
//     ]
//   }
