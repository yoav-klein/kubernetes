
$Headers = @{
    "Content-Type" = "application/json"
}

$body = Get-Content review.json

$response = Invoke-RestMethod -Headers $Headers -Method POST http://localhost:8080/mutate -Body $body

$patch = $response.response.patch

$decodedBytes = [Convert]::FromBase64String($patch)

# Convert bytes to a string (assuming it's UTF-8 encoded)
$decodedString = [System.Text.Encoding]::UTF8.GetString($decodedBytes)

# Output the decoded string
$decodedString