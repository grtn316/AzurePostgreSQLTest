# Testing parallelism with Azure PostreSQL

This repo is an example of how to use parallelism with ARM / Bicep. By default, ARM will attempt to parallelize the creation of every resource unless an implicit / explicit dependacy is found and then it will proceed to parallize the remaining items once the dependacies are worked through. Depending on the amount of resources being created, this may cause a failure due to API throttling or a race condition from resource creation being eventually consistent.

# Terraform

Terraform uses 10 concurrent operations by default, thus limiting the behavior found in ARM by default. To override this setting in terraform, simply configure the parallelism during an apply:

```
terraform apply -input=false -auto-approve -parallelism=10
```

## Testing

Run the following commands to test the Terraform example:
```bash
cd terraform

az login

terraform init 
terraform apply -input=false -auto-approve -parallelism=10

```

# ARM Templates

To configure parallelism in ARM, you must set this at the resouce level within a copy command. See `batchSize` below:

```json
{
      "copy": {
        "name": "postgreDatabase",
        "count": "[length(range(0, variables('databaseCount')))]",
        "mode": "serial",
        "batchSize": 20
      },
      "type": "Microsoft.DBForPostgreSQL/servers/databases",
      "apiVersion": "2017-12-01",
      "name": "[format('{0}/database-{1}', uniqueString(variables('uniqueServerName')), range(0, variables('databaseCount'))[copyIndex()])]",
      "properties": {
        "charset": "UTF8",
        "collation": "English_United States.1252"
      },
      "dependsOn": [
        "[resourceId('Microsoft.DBForPostgreSQL/servers', uniqueString(variables('uniqueServerName')))]"
      ]
    }
```

## Testing

Run the following commands to test the ARM Template example:
```bash
cd arm

az login

#Create Resource Group
az group create \
    --location "East US" \
    --name postgreSQLDeployment

#Create deployment
az deployment group create \
    --resource-group PostgreSQLTest \
    --template-file main.json
```

# Bicep

To configure parallelism in Bicep, you must set this at the resouce level using the `batchSize` decorator:

```BICEP
@batchSize(20)
resource postgreDatabase 'Microsoft.DBforPostgreSQL/servers/databases@2017-12-01' = [for x in range(0, databaseCount): {
  name: '${postgreSQLServer.name}/database-${x}'
  properties: {
    charset: 'UTF8'
    collation: 'English_United States.1252'
  }
}]
```

## Testing

Run the following commands to test the Bicep example:
```bash
cd bicep

az login

#Create Resource Group
az group create \
    --location "East US" \
    --name postgreSQLDeployment

#Create deployment
az deployment group create \
    --resource-group PostgreSQLTest \
    --template-file main.bicep
```