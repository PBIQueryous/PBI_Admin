# Powershell Cmdlets for PowerBI


## Connect
### connect to service

```powershell

Connect-PowerBIServiceAccount

```

## Get workspace meta
### all workspaces

```powershell
Get-PowerBIWorkspace
```

### workspaces assigned to me

```powershell
Get-PowerBIWorkspace -All
```

### all workspaces (organisation scope)

```powershell
Get-PowerBIWorkspace -Scope Organization -All | ConvertTo-Csv | Out-File c:\PowerBIWorkspaces.csv

Get-PowerBIWorkspace -Scope Organization -All | ConvertTo-Json | Out-File c:\PowerBIWorkspaces.json

# Get-PowerBIWorkspace -Scope Organization -All | ConvertTo-Json | Out-File c:\FolderName\FileName.json
```

### workspaces outputted to json file with datestamp
```powershell

$timesamp = (Get-Date).ToString("yyyy-MM-dd_HHmmss")
$namefolder = "C:\Users\imran.haq\Documents\PBI_Files\Admin\"
$namefile = "workspace_meta" + "_" + $timesamp
$extension = ".json" 
$filenamestring = $namefolder + $namefile + $extension
$Result = $filenamestring
Get-PowerBIWorkspace -Scope Organization -All | ConvertTo-Json | Out-File $Result

```


### get list of reports
```powershell

$timesamp = (Get-Date).ToString("yyyy-MM-dd_HHmmss")
$namefolder = "C:\Users\imran.haq\Documents\PBI_Files\Admin\"
$namefile = "workspace_reports_meta" + "_" + $timesamp
$extension = ".json" 
$filenamestring = $namefolder + $namefile + $extension
$Result = $filenamestring
Get-PowerBIReport | ConvertTo-Json | Out-File $Result

```

