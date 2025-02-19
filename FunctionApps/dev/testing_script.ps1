function Call-FunctionApp {
    param (
        [string]$apiUrl,
        [hashtable]$payload
    )

    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body ($payload | ConvertTo-Json) -ContentType "application/json"
    Write-Output $response
    # return $response
}

# Call publicly exposed function
$apiUrl = "https://fn-bdaug2025-gwc-dev.azurewebsites.net/api/public_function?"
$payload = @{
    name = "Bartek"
}
Call-FunctionApp -apiUrl $apiUrl -payload $payload

# Call secure function (using function key)
$apiUrl = "https://fn-bdaug2025-gwc-dev.azurewebsites.net/api//secure_function?"
$functionKey = ""
$hostKey = ""
$payload = @{
    name = "Bartek"
}
Call-FunctionApp -apiUrl "${apiUrl}code=${functionKey}" -payload $payload

# Call secure function (using host key)
$apiUrl = "https://fn-bdaug2025-gwc-dev.azurewebsites.net/api//secure_function2?"
$functionKey = ""
$hostKey = ""
$payload = @{
    name = "Bartek"
}
Call-FunctionApp -apiUrl "${apiUrl}code=${functionKey}" -payload $payload

### Testing master key ###
$masterKey = ""
# Get host status
Invoke-RestMethod -Uri "https://fn-bdaug2025-gwc-dev.azurewebsites.net/admin/host/status" `
    -Headers @{ "x-functions-key" = "" } `
    -Method Get

# List all functions
Invoke-RestMethod -Uri "https://fn-bdaug2025-gwc-dev.azurewebsites.net/admin/functions" `
    -Headers @{ "x-functions-key" = "" } `
    -Method Get

# List all function keys
Invoke-RestMethod -Uri "https://fn-bdaug2025-gwc-dev.azurewebsites.net/admin/functions/secure_function/keys" `
    -Headers @{ "x-functions-key" = "" } `
    -Method Get

# Create a new function key
...
# Delete a function key
...
#another admin custom-made function


### Testing whiteslisting approach ###
$subscriptionId = ""
$resourceGroupName = "rg-bdAug2025-gwc-dev"
$functionAppName = "fn-bdAug2025-gwc-dev"

$apiUrl = "https://fn-bdaug2025-gwc-dev.azurewebsites.net/api/public_function?"
$payload = @{
    name = "Bartek"
}

# Disconnect-AzAccount
# Connect-AzAccount

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
Write-Output "Added $publicIp to the whitelist."


Call-FunctionApp -apiUrl $apiUrl -payload $payload

# Remove the temporary IP rule
$functionApp.SiteConfig.IpSecurityRestrictions= $existingIpRestrictions
Set-AzWebApp -WebApp $functionApp
Write-Output "Removed $currentIp from the whitelist."