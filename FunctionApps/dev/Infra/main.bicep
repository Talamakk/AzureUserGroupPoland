targetScope = 'resourceGroup'

@description('Required - environment to deploy resource group to')
@allowed([
  'dev'
  'qa'
  'prd'
])
param environment string

@description('Required - location to deploy resource group to')
@allowed([
  'westeurope'
  'eastus'
  'germanywestcentral'
  'polandcentral'
])
param location string

@description('Required - short name for location')
@allowed([
  'weu'
  'eus'
  'gwc'
  'pl'
])
param locationShort string

@description('Required - project prefix')
@minLength(3)
@maxLength(10)
param prefix string

// ******* App Service Plan ******* //
module serverFarm 'br/public:avm/res/web/serverfarm:0.4.1' = {
  name: '${uniqueString(deployment().name, location)}-ASP-01'
  params: {
    name: 'asp-${prefix}-${locationShort}-${environment}'
    location: location
    kind: 'linux'
    skuName: 'P1v3'
  }
}

// ******* Storage Account ******* //
module storageAccount 'br/public:avm/res/storage/storage-account:0.17.0' = {
  name: '${uniqueString(deployment().name, location)}-SA-01'
  params: {
    name: 'sa${prefix}${locationShort}${environment}'
    location: location
    kind: 'BlobStorage'
    skuName: 'Standard_LRS'
  }
}

// ******* Function App ******* //
module site 'br/public:avm/res/web/site:0.13.2' = {
  name: '${uniqueString(deployment().name, location)}-FN-01'
  params: {
    // Required parameters
    kind: 'functionapp'
    name: 'fn-${prefix}-${locationShort}-${environment}'
    serverFarmResourceId: serverFarm.outputs.resourceId
    storageAccountResourceId: storageAccount.outputs.resourceId
  }
}
