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
module serverfarm 'br/public:avm/res/web/serverfarm:0.4.1' = {
  name: '${uniqueString(deployment().name, location)}-ASP-01'
  params: {
    name: 'asp-${prefix}-${locationShort}-${environment}'
    location: location
    kind: 'linux'
    skuName: 'P1v3'
  }
}






// module site 'br/public:avm/res/web/site:<version>' = {
//   name: 'siteDeployment'
//   params: {
//     // Required parameters
//     kind: 'functionapp'
//     name: 'wsfamin001'
//     serverFarmResourceId: '<serverFarmResourceId>'
//   }
// }
