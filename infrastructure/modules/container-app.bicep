@description('Provide a location for the registry.')
param location string = resourceGroup().location

@minLength(13)
@maxLength(13)
param uniqueSuffix string

@description('Provide a managedIdentityId')
param managedIdentityId string

@description('Provide a Managed Environment Id')
param managedEnvironmentId string

@description('Provide a azureContainerRegistry Name')
param azureContainerRegistryName string

param applicationInsightsConnectionString string

param external bool = false

@minLength(3)
@maxLength(20)
param appName string

@description('Container image tag, to deploy')
param image string



resource containerapp 'Microsoft.App/containerApps@2022-03-01' = {
  name: '${appName}-${uniqueSuffix}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: managedEnvironmentId
    configuration: {
      ingress: {
        external: external
        targetPort: 8080
      }
      dapr: {
        enabled: true
        appId: appName
        appProtocol: 'http'
        appPort: 8080
      }
      registries: [
        {
          server: '${azureContainerRegistryName}.azurecr.io'
          identity: managedIdentityId
        }
      ]
    }
    template: {
      containers: [
        {
          image: image
          name: appName
          env: [
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: applicationInsightsConnectionString
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
}
