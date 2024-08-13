<#
DDDDDDDDDDDDD                                     tttt                                                                
D::::::::::::DDD                               ttt:::t                                                                
D:::::::::::::::DD                             t:::::t                                                                
DDD:::::DDDDD:::::D                            t:::::t                                                                
  D:::::D    D:::::D     eeeeeeeeeeee    ttttttt:::::ttttttt   rrrrr   rrrrrrrrr      ooooooooooo   nnnn  nnnnnnnn    
  D:::::D     D:::::D  ee::::::::::::ee  t:::::::::::::::::t   r::::rrr:::::::::r   oo:::::::::::oo n:::nn::::::::nn  
  D:::::D     D:::::D e::::::eeeee:::::eet:::::::::::::::::t   r:::::::::::::::::r o:::::::::::::::on::::::::::::::nn 
  D:::::D     D:::::De::::::e     e:::::etttttt:::::::tttttt   rr::::::rrrrr::::::ro:::::ooooo:::::onn:::::::::::::::n
  D:::::D     D:::::De:::::::eeeee::::::e      t:::::t          r:::::r     r:::::ro::::o     o::::o  n:::::nnnn:::::n
  D:::::D     D:::::De:::::::::::::::::e       t:::::t          r:::::r     rrrrrrro::::o     o::::o  n::::n    n::::n
  D:::::D     D:::::De::::::eeeeeeeeeee        t:::::t          r:::::r            o::::o     o::::o  n::::n    n::::n
  D:::::D    D:::::D e:::::::e                 t:::::t    ttttttr:::::r            o::::o     o::::o  n::::n    n::::n
DDD:::::DDDDD:::::D  e::::::::e                t::::::tttt:::::tr:::::r            o:::::ooooo:::::o  n::::n    n::::n
D:::::::::::::::DD    e::::::::eeeeeeee        tt::::::::::::::tr:::::r            o:::::::::::::::o  n::::n    n::::n
D::::::::::::DDD       ee:::::::::::::e          tt:::::::::::ttr:::::r             oo:::::::::::oo   n::::n    n::::n
DDDDDDDDDDDDD            eeeeeeeeeeeeee            ttttttttttt  rrrrrrr               ooooooooooo     nnnnnn    nnnnnn
#>

<#  
.SYNOPSIS  
    This wil connect to nCentral using a JWT and produce a nice Excel sheet with all current discovery jobs

.DESCRIPTION
    This wil connect to nCentral using a JWT and produce a nice Excel sheet with all current discovery jobs that are setup for our customers

.NOTES  
    Author     : Chris Simon
    Version    : 1.0.0.0 Initial Build
#>

###################################
#Region - Import required modules
###################################

# Import required Secrets module.
$CheckImportSecrets = Get-Module -ListAvailable -Name Secrets
if (!$CheckImportSecrets) {
    Import-Module .\Modules\Secrets\Secrets.psm1
}

# Import required PS-NCentral module.
$CheckImportPSNCentral = Get-Module -ListAvailable -Name PS-NCentral
if (!$CheckImportPSNCentral) {
    Install-Module PS-NCentral -Scope CurrentUser
    Import-Module PS-NCentral
}
else {
    Import-Module PS-NCentral
}

# Import required ImportExcel Module.
$CheckImportExcelModule = Get-Module -ListAvailable -Name ImportExcel
if (!$CheckImportExcelModule) {
    Install-Module ImportExcel -Scope CurrentUser
    Import-Module ImportExcel
}
else {
    Import-Module ImportExcel
}

#EndRegion

###################################
#Region - Import secrets used for N-Central connection.
###################################

$NCServer = Get-Secret -File ".\ExcludeFromGit\Secrets.json" -SecretVault "NCentral2" -SecretName "N-Central API Full Access" -SecretItem "URL"
$JWTToken = Get-Secret -File ".\ExcludeFromGit\Secrets.json" -SecretVault "NCentral2" -SecretName "N-Central API Full Access" -SecretItem "Password"

#EndRegion

###################################
#Region - The main script
###################################

Write-Host -ForegroundColor Yellow "Connecting to NCentral"
$NCSession = New-NCentralConnection -ServerFQDN $NCServer -JWT $JWTToken

$Jobs = Get-NCJobStatusList -CustomerID 50 | where-object -Property jobtype -Like "Asset Discovery Task"
$AssetScanJobs = @()

ForEach ($Job in $Jobs) {
    Write-Progress -Activity "Processing Job $($Jobs.IndexOf($Job)) of $($Jobs.Count)" -Status "Progress:" -PercentComplete ($Jobs.IndexOf($Job)/$($Jobs.Count)*100)
    $AssetScanJob = New-Object PSObject
    $AssetScanJob | Add-Member -type NoteProperty -Name 'Customer' -Value $Job.customername
    $AssetScanJob | Add-Member -type NoteProperty -Name 'Site' -Value $Job.sitename
    $AssetScanJob | Add-Member -type NoteProperty -Name 'Job Name' -Value $Job.jobname
    $AssetScanJob | Add-Member -type NoteProperty -Name 'Scheduled Time' -Value $Job.scheduledtime.DateTime
    $AssetScanJob | Add-Member -type NoteProperty -Name 'Job Target' -Value $Job.jobtarget
    $AssetScanJob | Add-Member -type NoteProperty -Name 'Last Completion Time' -Value $Job.lastcompletiontime.DateTime
    $AssetScanJob | Add-Member -type NoteProperty -Name 'Status' -Value $Job.status
    $AssetScanJobs += $AssetScanJob
}
Write-Progress -Activity "Processing Job" -Completed
$AssetScanJobs = $AssetScanJobs | Sort-Object -Property Customer, Site, 'Scheduled Time'

Export-Excel -Path ".\Exports\DiscoveryJobs.xlsx" -WorksheetName (Get-Date -Format "dd-MM-yyyy HH.mm") -InputObject $AssetScanJobs -AutoSize -AutoFilter -FreezeTopRow -NoNumberConversion * -TableStyle Medium10

#EndRegion