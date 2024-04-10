# Concat strings

### contact strings for file name with datestamp

```powershell
$timesamp = (Get-Date).ToString("yyyy-MM-dd_HHmmss")
$namefolder = "C:\Users\imran.haq\Documents\PBI_Files\Admin\"
$namefile = "NewTestFile" + "_" + $timesamp
$extension = ".json" 
$filenamestring = $namefolder + $namefile + $extension
$Result = $filenamestring
$Result

# C:\Users\imran.haq\Documents\PBI_Files\Admin\NewTestFile_2024-04-10_204518.json

```
