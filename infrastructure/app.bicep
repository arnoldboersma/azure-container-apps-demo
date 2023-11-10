@description('Provide the default location for resources to .')
param location string = resourceGroup().location

var uniqueSeed = '${subscription().subscriptionId}-${resourceGroup().name}'
var uniqueSuffix = uniqueString(uniqueSeed)

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: 'appi-${uniqueSuffix}'
}

resource environment 'Microsoft.App/managedEnvironments@2022-10-01' existing = {
  name: 'cae-${uniqueSuffix}'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'mi-${uniqueSuffix}'
  location: location
}


module app './modules/container-app.bicep' = {
  name: '${deployment().name}-app'
  params: {
    location: location
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    appName: 'app'
    uniqueSuffix: uniqueSuffix
    azureContainerRegistryName: 'acr${uniqueSuffix}'
    image: 'acr${uniqueSuffix}.azurecr.io/app:latest'
    external: true
    managedEnvironmentId: environment.id
    managedIdentityId: managedIdentity.id
  }
}

module appblazor './modules/container-app.bicep' = {
  name: '${deployment().name}-appblazor'
  params: {
    location: location
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    appName: 'appblazor'
    uniqueSuffix: uniqueSuffix
    azureContainerRegistryName: 'acr${uniqueSuffix}'
    image: 'acr${uniqueSuffix}.azurecr.io/appblazor:latest'
    external: true
    managedEnvironmentId: environment.id
    managedIdentityId: managedIdentity.id
  }
}

module api './modules/container-app.bicep' = {
  name: '${deployment().name}-api'
  params: {
    location: location
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    appName: 'api'
    uniqueSuffix: uniqueSuffix
    azureContainerRegistryName: 'acr${uniqueSuffix}'
    image: 'acr${uniqueSuffix}.azurecr.io/api:latest'
    external: false
    managedEnvironmentId: environment.id
    managedIdentityId: managedIdentity.id
  }
}
