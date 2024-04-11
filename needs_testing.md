# ultimate powershell cmdlet

### script
```powershell

#
# list all workspaces, reports and dashboards across every workspace. Tie "current date" is added to each row...Power BI will then be able to tell thea "first date"
# that something appeared.
#


Write-Host "Starting script:" (Get-Date).ToString('MM/dd/yyyy hh:mm:ss tt')

# connect to PBI service using the service account
#$User = "*** PBI login USER ID ***"
#$PWord = ConvertTo-SecureString -String "*** Password for that user ***" -AsPlainText -Force
#$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord
#Connect-PowerBIServiceAccount -Credential $UserCredential

$logbase = "C:\Users\imran.haq\Documents\PBI_Files\Admin\pbi_backup_dumps\"

#################################
#         Capacities            #
#################################

# get capacities info
Write-Host "******* Exporting Capacities *****"
$url = "capacities"
$Capacities = (ConvertFrom-Json (Invoke-PowerBIRestMethod -Url $url -Method Get)).value


# export capacities
$logpath = $logbase + "capacities.csv"
$Capacities | select id, displayName, sku, state, region | Export-Csv -Path $logpath -NoTypeInformation

# export capacity admins
$logpath = $logbase + "capacity_admins.csv"
$capacity_admins = 
ForEach ($capacity in $Capacities)
    {
    ForEach ($admin in $capacity.admins)
        {
        [pscustomobject]@{
            CapacityID = $capacity.id
            CapacityName = $capacity.displayName
            AdminUser = $admin
            }
        }
    }
$capacity_admins | Export-Csv -Path $logpath -NoTypeInformation


#################################
#         Workspaces            #
#################################


#
# Scott notes:
#    Workspace type  "Workspace"       is new workspace experience
#                    "Group"           is old workspace experience
#                    "PersonalGroup"   is "My Workspace" for end users
#
#    State           "Active"
#                    "Removing"        these are already deleted...
#                    "Deleted"
#                    "Deprovisioning failed"
#
#
# Things blow up later (like listing datasets, datasources, etc.) if states other than "Active" are in the list...so I'm going to filter to active only...
# Also may remove personal workspaces for now just to improve speed...
#
#

Write-Host "******* Exporting Workspaces *****"
$Workspaces = Get-PowerBIWorkspace -Scope Organization -All | where state -eq "Active" | where type -ne "PersonalGroup"

# export workspaces
$logpath = $logbase + "workspaces.csv"
$Workspaces | select Id, Name, Type, State, IsReadOnly, IsOrphaned, CapacityId | Export-Csv -Path $logpath -NoTypeInformation


# export workspace users
$logpath = $logbase + "workspace_users.csv"
$workspace_users = 
ForEach ($workspace in $Workspaces)
    {
    ForEach ($user in $workspace.Users)
        {
        [pscustomobject]@{
            WorkspaceID = $workspace.id
            WorkspaceName = $workspace.Name
            AccessRight = $user.AccessRight
            User = $User.UserPrincipalName
            }
        }    
    }
$workspace_users | Export-Csv -Path $logpath -NoTypeInformation




#################################
#          Datasets             #
#################################

# Note - we can't just get all datasets - because the resulting dataset object doesn't tell which workspace it is in. So going to have to loop over each workspace
#        and grab just the datasets in it to make that link. Might dump ALL datasets into a separate test file to make sure we don't miss any...

Write-Host "******* Exporting Datasets ******"
$logpath = $logbase + "datasets.csv"
$Datasets =
ForEach ($workspace in $Workspaces)
    {
    ForEach ($dataset in (Get-PowerBIDataset -Scope Organization -WorkspaceId $workspace.Id))
        {
        [pscustomobject]@{
            WorkspaceID = $workspace.Id
            WorkspaceName = $workspace.Name
            DatasetID = $dataset.Id
            DatasetName = $dataset.Name
            DatasetAuthor = $dataset.ConfiguredBy
            IsRefreshable = $dataset.IsRefreshable
            IsOnPremGatewayRequired = $dataset.IsOnPremGatewayRequired
            }
        }
    }
$Datasets | Export-Csv -Path $logpath -NoTypeInformation



#################################
#         Datasources           #
#################################

# Loop over all datasets to get the associated datasources
# Scott ToDo - add try/catch blocks. Some datasources blow up with error "ConvertFrom-Json : Cannot bind argument to parameter 'InputObject' because it is null."
#              I believe this is because it is an invalid data source - for example reading text file that doesn't exist, etc.

Write-Host "******* Exporting Data Sources *****"
$logpath = $logbase + "datasources.csv"
$Datasources =
ForEach ($dataset in $Datasets)
    {
    $url = "groups/" + $dataset.WorkspaceID + "/datasets/" + $dataset.DatasetID + "/datasources"
    $sources = (ConvertFrom-Json (Invoke-PowerBIRestMethod -Url $url -Method Get)).value
    ForEach($datasource in $sources)
        {
        [pscustomobject]@{
            WorkspaceID = $dataset.WorkspaceID
            WorkspaceName = $dataset.WorkspaceName
            DatasetID = $dataset.DatasetID
            DatasetName = $dataset.DatasetName
            DataSourceID = $datasource.datasourceId
            DataSourceType = $datasource.datasourceType
            DataSourceConnection = $datasource.connectionDetails
            DataSourceGatewayID = $datasource.gatewayId
            }
        }
    }
$Datasources | Export-Csv -Path $logpath -NoTypeInformation


#################################
#         Dashboards            #
#################################

# Note - similar to datasets, we can't just grab dashboards - because the resulting object doesn't tell which workspace it is in. So going to have to loop over each workspace
#        and grab just the dashboards in it to make that link.

$logpath = $logbase + "dashboards.csv"
$Dashboards =
ForEach ($workspace in $Workspaces)
    {
    Write-Host "Writing dashboards...on workspace: " $workspace.Name
    ForEach ($dashboard in (Get-PowerBIDashboard -Scope Organization -WorkspaceId $workspace.Id))
        {
        [pscustomobject]@{
            WorkspaceID = $workspace.Id
            WorkspaceName = $workspace.Name
            DashboardID = $dashboard.Id
            DashboardName = $dashboard.Name
            }
        }
    }
$Dashboards | Export-Csv -Path $logpath -NoTypeInformation


#################################
#           Reports             #
#################################

# same as dashboards and datasets - loop over each workspace and list the reports in it.

$logpath = $logbase + "reports.csv"
$Reports =
ForEach ($workspace in $Workspaces)
    {
    Write-Host "Writing reports...on workspace: " $workspace.Name
    ForEach ($report in (Get-PowerBIReport -Scope Organization -WorkspaceId $workspace.Id))
        {
        [pscustomobject]@{
            WorkspaceID = $workspace.Id
            WorkspaceName = $workspace.Name
            ReportID = $report.Id
            ReportName = $report.Name
            ReportURL = $report.WebUrl
            ReportDatasetID = $report.DatasetId
            }
        }
    }
$Reports | Export-Csv -Path $logpath -NoTypeInformation



#################################
#           Apps                #
#################################
$url = "apps"
$Apps = (ConvertFrom-Json (Invoke-PowerBIRestMethod -Url $url -Method Get)).value

# export apps
$logpath = $logbase + "apps.csv"
$Apps | Export-Csv -Path $logpath -NoTypeInformation

# export app dashboards
$logpath = $logbase + "app_dashboards.csv"
$AppDashboards =
ForEach ($app in $Apps)
    {

    $url = "apps/" + $app.Id + "/dashboards"
    $app_dashboards = (ConvertFrom-Json (Invoke-PowerBIRestMethod -Url $url -Method Get)).value

    ForEach ($dashboard in $app_dashboards)
        {
        [pscustomobject]@{
            AppID = $app.Id
            AppName = $app.Name
            DashboardID = $dashboard.Id
            DashboardName = $dashboard.displayName
            IsReadOnly = $dashboard.isReadOnly
            }
        }
    }
$AppDashboards | Export-Csv -Path $logpath -NoTypeInformation


# export app reports
$logpath = $logbase + "app_reports.csv"
$AppReports =
ForEach ($app in $Apps)
    {
    $url = "apps/" + $app.Id + "/reports"
    $app_reports = (ConvertFrom-Json (Invoke-PowerBIRestMethod -Url $url -Method Get)).value

    ForEach ($report in $app_reports)
        {
        [pscustomobject]@{
            AppID = $app.Id
            AppName = $app.Name
            ReportID = $report.Id
            ReportName = $report.Name
            ReportURL = $report.webURL
            }
        }
    }
$AppReports | Export-Csv -Path $logpath -NoTypeInformation

Disconnect-PowerBIServiceAccount

Write-Host "Script complete:" (Get-Date).ToString('MM/dd/yyyy hh:mm:ss tt')

```
