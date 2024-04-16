### get workspaces

```powershell
# Invoke the Power BI REST API and store the response
$response = Invoke-PowerBIRestMethod -Url 'groups' -Method Get

# Convert the response from JSON string to a PowerShell object
$jsonData = $response | ConvertFrom-Json

# Convert the PowerShell object back to a JSON string with pretty printing
$prettyJson = $jsonData | ConvertTo-Json -Depth 100

# Output the pretty JSON to the console
Write-Output $prettyJson

# Optionally, save the pretty JSON to a file
$prettyJson | Out-File "C:\Users\pbiqu\Documents\_dump\PrettyOutput.json"
```

### get apss
```powershell
# Invoke the Power BI REST API and store the response
$response = Invoke-PowerBIRestMethod -Url 'apps' -Method Get

# Convert the response from JSON string to a PowerShell object
$jsonData = $response | ConvertFrom-Json

# Convert the PowerShell object back to a JSON string with pretty printing
$prettyJson = $jsonData | ConvertTo-Json -Depth 100

# Output the pretty JSON to the console
Write-Output $prettyJson

# Optionally, save the pretty JSON to a file
$prettyJson | Out-File "C:\Users\pbiqu\Documents\_dump\PrettyOutput.json"
```
