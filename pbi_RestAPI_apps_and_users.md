### get apps and users
```powershell
# Authenticate and get the access token header
$headers = Get-PowerBIAccessToken

# Get a list of all groups/apps
$groupUri = 'https://api.powerbi.com/v1.0/myorg/groups'
$groupsResponse = Invoke-RestMethod -Headers $headers -Uri $groupUri

# Prepare the output directory and file path
$outputFolderPath = "C:\Users\pbiqu\Documents\_dump\"
$dateString = Get-Date -Format "yyyyMMdd"
$jsonFilePath = $outputFolderPath + "admin_portal_snapshot_" + $dateString + ".json"

# Check if the output directory exists, if not, create it
if (-Not (Test-Path -Path $outputFolderPath)) {
    New-Item -ItemType Directory -Path $outputFolderPath -Force
}

# Initialize a list to hold all group and user data
$allGroupsUsers = @()

# Process each group to get its users
foreach ($group in $groupsResponse.value) {
    $apiUrl = "https://api.powerbi.com/v1.0/myorg/groups/$($group.id)/users"
    
    # Make the API call to get users for the current group
    $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
    
    # Collect group name and users data
    $groupUsers = @{
        GroupName = $group.name
        GroupId   = $group.id
        Users     = $response.value
    }

    # Add the group and its users to the list
    $allGroupsUsers += $groupUsers
}

# Convert all data to JSON and save to the file
$allGroupsUsers | ConvertTo-Json -Depth 100 | Out-File -FilePath $jsonFilePath

# Output the path of the JSON file
Write-Host "Data saved to JSON file: $jsonFilePath"


```
