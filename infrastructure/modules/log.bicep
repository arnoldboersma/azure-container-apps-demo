param location string

@minLength(13)
@maxLength(13)
param uniqueSuffix string

var name = 'log-${uniqueSuffix}'
var appiName = 'appi-${uniqueSuffix}'

resource logAnalyticsWorkspace'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: name
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appiName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

@description('Output the logAnalyticsWorkspace Id')
output id string = logAnalyticsWorkspace.id

@description('Output the applicationInsights connection string')
output connectionString string = applicationInsights.properties.ConnectionString
