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
    Get the Azure Automation Job Result

.DESCRIPTION
    Get the Azure Automation Job Result and process it to make it decent

.NOTES  
    Author     : Chris Simon
    Version    : 1.0.0.0 Initial Build
    Version    : 1.0.0.1 Small bugfix when job is still running
#>

###################################
#Region - Params used for debugging
###################################

<#Input Parameters:
    $TenantID = "<TenantID>"
    $ClientID = "<ClientID>"
    $CertificateThumbprint = "<CertificateThumbprint>"
    $ResourceGroupName = "<ResourcegroupName>"
    $AutomationAccountName = "<AutomationAccountName>"
    $RunbookName = "<RunbookName>"
#>
<#Output Parameters:
    $Status #String
    $LastRun #Date
    $RunTime #Integer (Minutes)
    $ErrorCount #Integer
#>

#EndRegion

###################################
#Region - Default Return Value Set
###################################

$Status = ""        #String
$LastRun = ""       #Date
$RunTime = 0       #Integer (Minutes)
$ErrorCount = 0    #Integer

#EndRegion

###################################
#Region - Check if parameters are set
###################################

if (($TenantID -match "<") -or ($ClientID -match "<") -or ($CertificateThumbprint -match "<") -or ($ResourceGroupName -match "<") -or ($AutomationAccountName -match "<") -or ($RunbookName -match "<"))
{
    $Status = "Failure, not all parameters are filled in correctly"
    Exit
}

#EndRegion

###################################
#Region - Check if Powershell Modules are installed and error out if not.
###################################

If (Get-Module -ListAvailable -Name AZ.Accounts)
{
    Import-Module AZ.Accounts
}
else
{
    $Status = "Please install the AZ.Accounts Powershell module on the executing server"
    Exit
}

If (Get-Module -ListAvailable -Name AZ.Automation)
{
    Import-Module AZ.Automation
}
else
{
    $Status = "Please install the AZ.Automation Powershell module on the executing server"
    Exit
}

#EndRegion

###################################
#Region - Connect to AzureAD
###################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Connect-AzAccount -ServicePrincipal -ApplicationId $ClientID -Tenant $TenantID -CertificateThumbprint $CertificateThumbprint

#EndRegion

###################################
#Region - Get Data from Automation Job
###################################

$Job = (Get-AzAutomationJob -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -RunbookName $RunbookName)[0]                           
$JobErrors = (Get-AzAutomationJobOutput -Id $Job.JobId -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -stream "Error")

#End Region

###################################
#Region - Disconnect from AzureAD
###################################

Disconnect-AzAccount

#EndRegion

###################################
#Region - Convert Data to N-Central
###################################

$Status = $Job.Status
$LastRun = $Job.StartTime.Date
if ($Status -eq "Running") {
    $RunTime = 0
    $Status += ", not Completed yet!"
}
else {
    $RunTime = [math]::Round(($Job.EndTime - $Job.StartTime).TotalMinutes)
}
$ErrorCount = $JobErrors.Count

#End Region