@minLength(13)
@maxLength(13)
param uniqueSuffix string

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a logAnalytics workspace Id')
param logAnalyticsWorkspaceId string

@description('Provide the application insights connection string')
param applicationInsightsConnectionString string

var name = 'cae-${uniqueSuffix}'

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: name
  location: location
  properties: {
    daprAIConnectionString: applicationInsightsConnectionString
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspaceId, '2020-03-01-preview').customerId
        sharedKey: listKeys(logAnalyticsWorkspaceId, '2020-03-01-preview').primarySharedKey
      }
    }
  }
}

@description('Environment Name')
output environmentName string = environment.name

@description('Environment Id')
output environmentId string = environment.id

