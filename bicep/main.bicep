//az group create --name PostgreSQLTest --location "East US"
//az deployment group create --resource-group PostgreSQLTest --template-file ./main.bicep

param location string = resourceGroup().location

var serverName = 'postgresqlserver'
var uniqueServerName = '${serverName}-'
var databaseCount = 200

resource postgreSQLServer 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
  name: uniqueString(uniqueServerName)
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'GP_Gen5_4'
  }
  properties: {
    version: '11'
    sslEnforcement: 'Enabled'
    minimalTlsVersion: 'TLS1_2'
    infrastructureEncryption: 'Enabled'
    publicNetworkAccess: 'Enabled'
    storageProfile: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
      storageMB: 640000
      storageAutogrow: 'Disabled'
    }
    createMode: 'Default'
    administratorLogin: 'psqladminun'
    administratorLoginPassword: 'H@Sh1CoR3!'
  }
  location: location
}

resource postgreSQLServerFirewallRules 'Microsoft.DBforPostgreSQL/servers/firewallRules@2017-12-01' = {
  name: '${postgreSQLServer.name}/ClientIP'
  properties: {
    startIpAddress: '40.112.0.0'
    endIpAddress: '40.112.255.255'
  }
}

@batchSize(20)
resource postgreDatabase 'Microsoft.DBforPostgreSQL/servers/databases@2017-12-01' = [for x in range(0, databaseCount): {
  name: '${postgreSQLServer.name}/database-${x}'
  properties: {
    charset: 'UTF8'
    collation: 'English_United States.1252'
  }
}]
