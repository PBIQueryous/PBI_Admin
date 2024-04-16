### get all meta joined
```powershell
# Prepare the output directory and file path
$timestamp = (Get-Date).ToString("yyyy-MM-dd_HHmmss")
$namefolder = "...\FolderPath\"
$namefile = "workspace_reports_meta_" + $timestamp
$extension = ".json" 
$filenamestring = $namefolder + $namefile + $extension

# Check if the output directory exists, if not, create it
if (-Not (Test-Path -Path $namefolder)) {
    New-Item -ItemType Directory -Path $namefolder -Force
}

# Fetch all workspaces within the organization
$workspaces = Get-PowerBIWorkspace -Scope Organization -All

# Initialize a list to hold all data
$allData = @()

# Loop through each workspace
foreach ($workspace in $workspaces) {
    # Fetch datasets and reports for the current workspace
    $datasets = Get-PowerBIDataset -WorkspaceId $workspace.id
    $reports = Get-PowerBIReport -WorkspaceId $workspace.id

    # Build a custom object for each workspace
    $workspaceData = @{
        WorkspaceName = $workspace.name
        WorkspaceId   = $workspace.id
        Datasets      = @()
        Reports       = @()
    }

    foreach ($dataset in $datasets) {
        # Filter reports related to this dataset
        $relatedReports = $reports | Where-Object { $_.datasetId -eq $dataset.id }

        # Create dataset object including related reports
        $datasetData = @{
            DatasetName = $dataset.name
            DatasetId   = $dataset.id
            RelatedReports = @($relatedReports)
        }

        # Add to workspace data
        $workspaceData.Datasets += $datasetData
    }

    # Add standalone reports (not tied to any dataset)
    $standaloneReports = $reports | Where-Object { $_.datasetId -eq $null }
    foreach ($report in $standaloneReports) {
        $reportData = @{
            ReportName = $report.name
            ReportId   = $report.id
            IsStandalone = $true
        }
        $workspaceData.Reports += $reportData
    }

    # Add complete workspace data to all data
    $allData += $workspaceData
}

# Convert all data to JSON and save to the file
$allData | ConvertTo-Json -Depth 100 | Out-File -FilePath $filenamestring

# Output the path of the JSON file
Write-Host "Data saved to JSON file: $filenamestring"

```
