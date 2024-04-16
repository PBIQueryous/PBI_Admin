### get activity log
```powershell
#Input values before running the script:
$NbrDaysDaysToExtract = 7
$ExportFileLocation = 'C:\Users\pbiqu\Documents\_dump'
$ExportFileName = 'PBIActivityEvents'
#--------------------------------------------

#Start with yesterday for counting back to ensure full day results are obtained:
[datetime]$DayUTC = (([datetime]::Today.ToUniversalTime()).Date).AddDays(-1)

#Suffix for file name so we know when it was written:
[string]$DateTimeFileWrittenUTCLabel = ([datetime]::Now.ToUniversalTime()).ToString("yyyyMMddHHmm")

#Loop through each of the days to be extracted (<Initilize> ; <Condition> ; <Repeat>)
For($LoopNbr=0 ; $LoopNbr -lt $NbrDaysDaysToExtract ; $LoopNbr++)
{
    [datetime]$DateToExtractUTC=$DayUTC.AddDays(-$LoopNbr).ToString("yyyy-MM-dd")

[string]$DateToExtractLabel=$DateToExtractUTC.ToString("yyyy-MM-dd")
    
    #Create full file name:
    [string]$FullExportFileName = $ExportFileName + '-' + ($DateToExtractLabel -replace '-', '') + '-' + $DateTimeFileWrittenUTCLabel + '.json'

#Obtain activity events and store intermediary results:
    [psobject]$Events=Get-PowerBIActivityEvent -StartDateTime ($DateToExtractLabel+'T00:00:00.000') -EndDateTime ($DateToExtractLabel+'T23:59:59.999')

#Write one file per day:
    $Events | Out-File "$ExportFileLocation\$FullExportFileName"

Write-Verbose "File written: $FullExportFileName" -Verbose 
}
Write-Verbose "Extract of Power BI activity events is complete." -Verbose
```
