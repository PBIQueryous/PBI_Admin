# Powershell Cmdlets for PowerBI


## Connect
### connect to service

```powershell

Connect-PowerBIServiceAccount

```
## Get PowerBI Access Token
### PowerBI Access Token
```powershell

Get-PowerBIAccessToken
```

## Export Current Portal Settings
### Admin Portal Settings
```powershell
Invoke-PowerBIRestMethod -Url https://api.fabric.microsoft.com/v1/admin/tenantsettings -Method GET | ConvertTo-Json | Out-File .\pbi_admin_portal_settings\admin_portal_snapshot.json 

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
# Get-PowerBIWorkspace -Scope Organization -All -Expand "reports" -Filter "isOnDedicatedCapacity eq true
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
Get-PowerBIReport -Scope Organization | ConvertTo-Json | Out-File $Result

```

### get list of datasets
```powershell

$timesamp = (Get-Date).ToString("yyyy-MM-dd_HHmmss")
$namefolder = "C:\Users\imran.haq\Documents\PBI_Files\Admin\"
$namefile = "workspace_datasets_meta" + "_" + $timesamp
$extension = ".json" 
$filenamestring = $namefolder + $namefile + $extension
$Result = $filenamestring
Get-PowerBIDataset -Scope Organization | ConvertTo-Json | Out-File $Result

```

### download all pbix files from all workspaces

```powershell
#Log in to Power BI Service
#Login-PowerBI  -Environment Public 	

#First, Collect all (or one) of the workspaces in a parameter called PBIWorkspace
$PBIWorkspace = Get-PowerBIWorkspace 							# Collect all workspaces you have access to
#$PBIWorkspace = Get-PowerBIWorkspace -Name 'My Workspace Name' 	# Use the -Name parameter to limit to one workspace

#Now collect todays date
$TodaysDate = Get-Date -Format "yyyyMMdd" 

#Almost finished: Build the outputpath. This Outputpath creates a news map, based on todays date
$OutPutPath = "C:\Users\pbiqu\Documents\_dump\" + $TodaysDate 

#Now loop through the workspaces, hence the ForEach
ForEach($Workspace in $PBIWorkspace)
{
	#For all workspaces there is a new Folder destination: Outputpath + Workspacename
	$Folder = $OutPutPath + "\" + $Workspace.name 
	#If the folder doens't exists, it will be created.
	If(!(Test-Path $Folder))
	{
		New-Item -ItemType Directory -Force -Path $Folder
	}
	#At this point, there is a folder structure with a folder for all your workspaces 
	
	
	#Collect all (or one) of the reports from one or all workspaces 
	$PBIReports = Get-PowerBIReport -WorkspaceId $Workspace.Id 						 # Collect all reports from the workspace we selected.
	#$PBIReports = Get-PowerBIReport -WorkspaceId $Workspace.Id -Name "My Report Name" # Use the -Name parameter to limit to one report
		
		#Now loop through these reports: 
		ForEach($Report in $PBIReports)
		{
			#Your PowerShell comandline will say Downloading Workspacename Reportname
			Write-Host "Downloading "$Workspace.name":" $Report.name 
			
			#The final collection including folder structure + file name is created.
			$OutputFile = $OutPutPath + "\" + $Workspace.name + "\" + $Report.name + ".pbix"
			
			# If the file exists, delete it first; otherwise, the Export-PowerBIReport will fail.
			 if (Test-Path $OutputFile)
				{
					Remove-Item $OutputFile
				}
			
			#The pbix is now really getting downloaded
			Export-PowerBIReport -WorkspaceId $Workspace.ID -Id $Report.ID -OutFile $OutputFile
		}
}
```


### download all pbix from single workspace (BKP prefix) and capture errors
```powershell

# Login to Power BI Service
# Login-PowerBI -Environment Public

# Collect specific workspaces
$dataset_workspace_name = '___prd_tpg_bi'
$report_workspace_name = 'Printed.com'
$PBIWorkspace = Get-PowerBIWorkspace -Name $report_workspace_name

# Collect today's date for folder naming
$TodaysDate = Get-Date -Format "yyyyMMdd"
$reports_folderpath = "pbi_backup_reports_cloud"
$datasets_folderpath = "pbi_backup_datasets_cloud"
$OutPutPath = "C:\Users\imran.haq\OneDrive - The Printed Group Ltd\PowerBI_Content\___Admin___\" + $reports_folderpath + "\" + $TodaysDate

# Prepare a CSV log file for errors
$ErrorLogPath = $OutPutPath + "\ExportErrors.csv"
if (!(Test-Path $ErrorLogPath)) {
    New-Item -ItemType File -Path $ErrorLogPath
    Add-Content -Path $ErrorLogPath -Value "WorkspaceName,ReportName,ErrorMessage"
}

# Process each workspace
ForEach ($Workspace in $PBIWorkspace) {
    $Folder = $OutPutPath + "\" + $Workspace.name
    If (!(Test-Path $Folder)) {
        New-Item -ItemType Directory -Force -Path $Folder
    }

    $PBIReports = Get-PowerBIReport -WorkspaceId $Workspace.Id
    ForEach ($Report in $PBIReports) {
        Write-Host "Downloading " $Workspace.name ":" $Report.name
        $OutputFile = $OutPutPath + "\" + $Workspace.name + "\" + "BKP_" + $Report.name + ".pbix"

        if (Test-Path $OutputFile) {
            Remove-Item $OutputFile
        }

        Try {
            Export-PowerBIReport -WorkspaceId $Workspace.ID -Id $Report.ID -OutFile $OutputFile -ErrorAction Stop
        } Catch {
            Write-Host "Failed to download report: " $Report.name -ForegroundColor Red
            $errorMessage = $_.Exception.Message
            Add-Content -Path $ErrorLogPath -Value "$($Workspace.name),$($Report.name),$errorMessage"
        }
    }
}

Write-Host "All done. Check $ErrorLogPath for any errors during export."

```
