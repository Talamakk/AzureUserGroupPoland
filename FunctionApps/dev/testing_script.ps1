<#
fn-bdAugDemo2025-gwc-dev: demo function

fn-bdAug2025-2-gwc-dev: test function

fn-bdAug2025-gwc-dev: function with Easy Auth enabled and no network access restrictions
allowed client: SPN-CLIENT-fn-bdAug2025-gwc-dev
#>

# Define a function to call the Function App
function Call-FunctionApp {
    param (
        [string]$apiUrl,
        [hashtable]$payload
    )

    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body ($payload | ConvertTo-Json) -ContentType "application/json"
    Write-Output $response
}

# Call publicly exposed function
$apiUrl = "https://fn-bdAugDemo2025-gwc-dev.azurewebsites.net/api/public_function?"
$payload = @{
    name = "Bartek"
}
Call-FunctionApp -apiUrl $apiUrl -payload $payload

# Call secure function (using function/host key)
$apiUrl = "https://fn-bdAugDemo2025-gwc-dev.azurewebsites.net/api/secure_function?"
$functionKey = ""
$payload = @{
    name = "Bartek"
}
Call-FunctionApp -apiUrl "${apiUrl}code=${functionKey}" -payload $payload

# Call secure function (using function/host key)
$apiUrl = "https://fn-bdAugDemo2025-gwc-dev.azurewebsites.net/api/secure_function2?"
$functionKey = ""
$payload = @{
    name = "Bartek"
}
Call-FunctionApp -apiUrl "${apiUrl}code=${functionKey}" -payload $payload

### Testing master key ###
$masterKey = ""
# Get host status
Invoke-RestMethod -Uri "https://fn-bdAugDemo2025-gwc-dev.azurewebsites.net/admin/host/status" `
    -Headers @{ "x-functions-key" = "" } `
    -Method Get

# List all functions
Invoke-RestMethod -Uri "https://fn-bdAugDemo2025-gwc-dev.azurewebsites.net/admin/functions" `
    -Headers @{ "x-functions-key" = "" } `
    -Method Get

# List all function keys
Invoke-RestMethod -Uri "https://fn-bdAugDemo2025-gwc-dev.azurewebsites.net/admin/functions/secure_function/keys" `
    -Headers @{ "x-functions-key" = "" } `
    -Method Get

# Create a new function key
# ...
# Delete a function key
# ...
#another admin custom-made function


### Testing whiteslisting approach ###

# Set network restrictions on the Function App!
$subscriptionId = ""
$resourceGroupName = "rg-bdAugDemo2025-gwc-dev"
$functionAppName = "fn-bdAugDemo2025-gwc-dev"

# Disconnect-AzAccount
# Connect-AzAccount -TenantId ""
# Set-AzContext -SubscriptionId $subscriptionId

$currentIp = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip

$functionApp = Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $functionAppName
$existingIpRestrictions = $functionApp.SiteConfig.IpSecurityRestrictions

$newIpRule = New-Object Microsoft.Azure.Management.WebSites.Models.IpSecurityRestriction
$newIpRule.IpAddress = "$currentIp/32"
$newIpRule.Action = "Allow"
$newIpRule.Tag = "Default"
$newIpRule.Priority = 101
$newIpRule.Name = "TemporaryWhitelist"

# Append the new IP rule to the existing IP restrictions
$updatedIpRestrictions = $existingIpRestrictions + $newIpRule

# Convert the array to a list of IpSecurityRestriction objects
$ipSecurityRestrictionsList = [System.Collections.Generic.List[Microsoft.Azure.Management.WebSites.Models.IpSecurityRestriction]]::new()
$updatedIpRestrictions | ForEach-Object { $ipSecurityRestrictionsList.Add($_) }

# Set the IP security restrictions
$functionApp.SiteConfig.IpSecurityRestrictions = $ipSecurityRestrictionsList

# Apply the updated configuration to the Function App
Set-AzWebApp -WebApp $functionApp
Write-Output "Added $currentIp to the whitelist."


$apiUrl = "https://fn-bdAugDemo2025-gwc-dev.azurewebsites.net/api/public_function?"
$payload = @{
    name = "Bartek"
}
Call-FunctionApp -apiUrl $apiUrl -payload $payload

# Remove the temporary IP rule
$functionApp.SiteConfig.IpSecurityRestrictions= $existingIpRestrictions
Set-AzWebApp -WebApp $functionApp
Write-Output "Removed $currentIp from the whitelist."

### Testing EntraID authentication ###

# Configure the Function App to use Easy Auth

# Call publicly exposed function - should get 401
$apiUrl = "https://fn-bdAugDemo2025-gwc-dev.azurewebsites.net/api/public_function?"
$payload = @{
    name = "Bartek"
}
Call-FunctionApp -apiUrl $apiUrl -payload $payload

# App: SPN-CLIENT-fn-bdAug2025-gwc-dev
$tenantId = ""  # Your Azure AD Tenant ID
$clientId = ""  # The Client App Registration ID (FunctionApp-Caller)
$clientSecret = ""  # Secret from "Certificates & Secrets"

# Login to Azure as the client app
Disconnect-AzAccount
$secureSecret = ConvertTo-SecureString $clientSecret -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($clientId, $secureSecret)
Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantId | Out-Null
#Get-AzContext

# Get the access token
$functionClientId = ""  # The Function App Registration ID
$token = (Get-AzAccessToken -ResourceUrl "api://$($functionClientId)").Token

$apiUrl = "https://fn-bdAugDemo2025-gwc-dev.azurewebsites.net/api/public_function?"
$payload = @{
    name = "Bartek"
}
$headers = @{ Authorization = "Bearer $token" }
$response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body ($payload | ConvertTo-Json) -Headers $headers -ContentType "application/json"
Write-Output $response