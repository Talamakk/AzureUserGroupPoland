targetScope = 'subscription'

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
@maxLength(15)
param prefix string

module resourceGroup01 'br/public:avm/res/resources/resource-group:0.4.0' = {
  name: '${uniqueString(deployment().name, location)}-RG-01'
  params: {
    // Required parameters
    name: 'rg-${prefix}-${locationShort}-${environment}'
    // Non-required parameters
    location: location
  }
}
