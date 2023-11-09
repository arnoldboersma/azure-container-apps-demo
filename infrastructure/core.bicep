@description('Provide the default location for resources to .')
param location string = resourceGroup().location

var uniqueSeed = '${subscription().subscriptionId}-${resourceGroup().name}'
var uniqueSuffix = uniqueString(uniqueSeed)

module log './modules/log.bicep' = {
  name: '${deployment().name}-log'
  params: {
    location: location
    uniqueSuffix: uniqueSuffix
  }
}
module azureservices './modules/azure-services.bicep' = {
  name: '${deployment().name}-azureservices'
  params: {
    location: location
    uniqueSuffix: uniqueSuffix
  }
}

module aca './modules/cae.bicep' = {
  name: '${deployment().name}-cae'
  params: {
    location: location
    logAnalyticsWorkspaceId: log.outputs.id
    applicationInsightsConnectionString: log.outputs.connectionString
    uniqueSuffix: uniqueSuffix
  }
}

module daprcomponents './modules/dapr-components.bicep' = {
  name: '${deployment().name}-daprcomponents'
  params: {
    blobContainerName: azureservices.outputs.blobContainerName
    environmentName: aca.outputs.environmentName
    managedIdentityClientId: azureservices.outputs.managedIdentityClientId
    storageAccountName: azureservices.outputs.storageAccountName
  }
}

module acr './modules/acr.bicep' = {
  name: '${deployment().name}-acr'
  params: {
    location: location
    uniqueSuffix: uniqueSuffix
    managedIdentityPrincipalId: azureservices.outputs.managedIdentityPrincipalId
  }
}
