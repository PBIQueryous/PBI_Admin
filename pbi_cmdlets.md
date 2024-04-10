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
