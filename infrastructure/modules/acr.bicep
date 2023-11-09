@minLength(13)
@maxLength(13)
param uniqueSuffix string

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@description('Provide the name for the managed identity principalId')
param managedIdentityPrincipalId string

var acrName = 'acr${uniqueSuffix}'
var acrPullDefinitionId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
}

// roleDefinitionId is the ID found here for AcrPull: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, acrName, 'AcrPullTestUserAssigned')
  properties: {
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
    // acrPullDefinitionId has a value of 7f951dda-4ed3-4680-a7ca-43fe172d538d
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', acrPullDefinitionId)
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
output name string = acrResource.name
