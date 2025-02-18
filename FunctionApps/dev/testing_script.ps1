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