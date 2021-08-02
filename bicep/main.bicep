//az group create --name PostgreSQLTest --location "East US"
//az deployment group create --resource-group PostgreSQLTest --template-file ./main.bicep

param location string = resourceGroup().location

var serverName = 'postgresqlserver'
//var uniqueServerName = '${serverName}-'
var serverCount = 100
//var databaseCount = 200

@batchSize(20)
resource postgreSQLServer 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = [for x in range(0, serverCount): {
  //name: uniqueString(uniqueServerName)
  name: '${serverName}-abc-${x}'
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
}]


resource postgreSQLServerFirewallRules1 'Microsoft.DBforPostgreSQL/servers/firewallRules@2017-12-01' = [for x in range(0, serverCount): {
  parent: postgreSQLServer[x]
  name: 'PublicIP'
  properties: {
    startIpAddress: '40.112.0.0'
    endIpAddress: '40.112.255.255'
  }
}]

resource postgreSQLServerFirewallRules2 'Microsoft.DBforPostgreSQL/servers/firewallRules@2017-12-01' = [for x in range(0, serverCount): {
  parent: postgreSQLServer[x]
  name: 'PrivateIP'
  properties: {
    startIpAddress: '10.0.0.4'
    endIpAddress: '10.0.0.100'
  }
}]


resource postgreDatabase1 'Microsoft.DBforPostgreSQL/servers/databases@2017-12-01' = [for x in range(0, serverCount): {
  parent: postgreSQLServer[x]
  name: 'database1'
  properties: {
    charset: 'UTF8'
    collation: 'English_United States.1252'
  }
}]

resource postgreDatabase2 'Microsoft.DBforPostgreSQL/servers/databases@2017-12-01' = [for x in range(0, serverCount): {
  parent: postgreSQLServer[x]
  name: 'database2'
  properties: {
    charset: 'UTF8'
    collation: 'English_United States.1252'
  }
}]

resource postgreDatabase3 'Microsoft.DBforPostgreSQL/servers/databases@2017-12-01' = [for x in range(0, serverCount): {
  parent: postgreSQLServer[x]
  name: 'database3'
  properties: {
    charset: 'UTF8'
    collation: 'English_United States.1252'
  }
}]
