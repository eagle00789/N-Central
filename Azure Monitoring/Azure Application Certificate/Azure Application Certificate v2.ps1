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
    Get the expiry date for an Azure Application Certificate

.DESCRIPTION
    Get the expiry date for an Azure Application Certificate to make sure it isn't expired

.NOTES  
    Author     : Chris Simon
    Version    : 1.0.0.0 Initial Build
    Version    : 1.0.0.1 Small Bugfix for multiple application certificates to only select the last
    Version    : 1.0.0.2 Small bugfix for when KeyCredentials is not used but PasswordCredentials is
    Version    : 2.0.0.0 Rewrite to use Microsoft Graph Certificate based logon
#>

###################################
#Region - Params used for debugging
###################################

<#Input Parameters:
    $TenantID = "<TenantID>"
    $ClientID = "<ClientID>"
    $CertificateThumbprint = "<CertificateThumbprint>"
    $ObjectID = "<ObjectID>"
#>
<#Output Parameters:
    $AppDisplayName #String
    $ClientKeyStartDate #DateTime
    $ClientKeyEndDate #DateTime
    $DaysRemaining #Integer
#>

#EndRegion

###################################
#Region - Default Return Value Set
###################################

$AppDisplayName = ""
$ClientSecretStartDate = ""
$ClientSecretEndDate = ""
$DaysRemaining = 0

#EndRegion

###################################
#Region - Internal Variables
###################################

$Now = Get-Date

#EndRegion

###################################
#Region - Check if parameters are set
###################################

if (($TenantID -match "<") -or ($ClientID -match "<") -or ($CertificateThumbprint -match "<") -or ($ObjectID -match "<"))
{
    $AppDisplayName = "Failure, not all parameters are filled in correctly"
    Exit
}

#EndRegion

###################################
#Region - Check if Powershell Module AzureAD is installed and error out if not.
###################################

If (Get-Module -ListAvailable -Name Microsoft.Graph.Applications)
{
    import-module Microsoft.Graph.Applications
}
else
{
    $AppDisplayName = "Please install the Microsoft.Graph.Applications Powershell module on the executing server"
    Exit
}

#EndRegion

###################################
#Region - Connect to AzureAD
###################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Connect-MgGraph -ClientId $ClientID -TenantId $TenantID -CertificateThumbprint $CertificateThumbprint -Environment Global | Out-Null

#EndRegion

###################################
#Region - Get App Certificate
###################################

$App = Get-MgApplicationById -Ids $ObjectID
$AppProperties = $App.AdditionalProperties
$ClientKey = $AppProperties.keyCredentials
if (-not $ClientKey)
{
    $ClientKey = $AppProperties.passwordCredentials
}

#EndRegion

###################################
#Region - Disconnect from AzureAD
###################################

Disconnect-MgGraph

#EndRegion

###################################
#Region - Set variables for returning to NCentral
###################################

ForEach ($Key in $ClientKey)
{
	$Date = [DateTime]$Key.endDateTime
	if ($Date.Subtract($Now).Days -ge 0)
	{
		$Index = $foreach.Current
		break
	}
}
if (-not $Index)
{
	$Index = $ClientKey[$ClientKey.Length-1]
}

$ClientKey = $Index

$AppDisplayName = $AppProperties.displayName.Trim()
$ClientKeyStartDate = [DateTime]$ClientKey.startDateTime
$ClientKeyEndDate = [DateTime]$ClientKey.endDateTime
$DaysRemaining = ($ClientKeyEndDate.Subtract($Now)).Days

#EndRegion