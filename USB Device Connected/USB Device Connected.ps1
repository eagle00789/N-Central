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
    Check if a specified Hardware ID is connected to the server

.DESCRIPTION
    Check if a specified Hardware ID is connected to the server and report about the connection

.NOTES  
    Author     : Chris Simon
    Version    : 1.0.0.0 Initial Build
#>

###################################
#Region - Params used for debugging
###################################

$Debug = $False

#EndRegion

###################################
#Region - Main Script
###################################

if ($Debug)
{
    $Hardware_ID = "USB\VID_0B0E&PID_245E&REV_0187" #Jabra Link 370 as test
}

$Connected = $False
$USBs = Get-WmiObject Win32_USBControllerDevice | Foreach-Object { [Wmi]$_.Dependent }
foreach ($USB in $USBs)
{
    $HWID = $USB.HardwareID
    if ($HWID -like $Hardware_ID)
    {
        $Connected = $True
        break
    }
}
#EndRegion

###################################
#Region - Only Output if Debug is enabled
###################################

if ($Debug)
{
    Write-Host "Connected: $Connected" -ForegroundColor Yellow
}

#EndRegion