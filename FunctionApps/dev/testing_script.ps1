function Call-FunctionApp {
    param (
        [string]$apiUrl,
        [hashtable]$payload
    )

    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body ($payload | ConvertTo-Json) -ContentType "application/json"
    return $response
}

# Call publicly exposed function
$apiUrl = "https://fn-bdaug2025-gwc-dev.azurewebsites.net/api/hello"
$payload = @{
    name = "xdbox"
}
$result = Call-FunctionApp -apiUrl $apiUrl -payload $payload
Write-Output "Function app response: $($result | ConvertTo-Json -Depth 10)"