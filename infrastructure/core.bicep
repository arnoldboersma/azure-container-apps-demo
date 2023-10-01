@description('Provide the default location for resources to .')
param location string = resourceGroup().location

module acr './modules/acr.bicep' = {
  name: '${deployment().name}-acr'
  params: {
    location: location
  }
}

module log './modules/log.bicep' = {
  name: '${deployment().name}-log'
  params: {
    location: location
  }
}

module aca './modules/cae.bicep' = {
  name: '${deployment().name}-cae'
  params: {
    location: location
    logAnalyticsWorkspaceId: log.outputs.id
    azureContainerRegistryName: acr.outputs.name
  }
}
