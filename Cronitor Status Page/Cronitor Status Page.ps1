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
    Get Cronitor Status Page info

.DESCRIPTION
    Get Cronitor Status Page Information and transform data to N-Central.

.NOTES  
    Author     : Chris Simon
    Version    : 1.0.0.0 Initial Build
    Version    : 1.0.0.1 Added Links to output when maintenance or Incident
#>

###################################
#Region - Params used for debugging
###################################

$StatusPageURL= "https://status.workspace365.net/"

#EndRegion

###################################
#Region - Default Output Values where needed
###################################

$MaintenanceScheduled = 0
$LinkToMaintenance = "."
$IncidentActive = 0
$LinkToIncident = "."

#EndRegion

###################################
#Region - Install & Import required Modules (only when required by settings)
###################################

$StatusJSON = Invoke-RestMethod -Method Get -Uri "$($StatusPageURL)"
$StatusJSON = ConvertFrom-Json $StatusJSON.html.body.script.'#text'
$Status = $StatusJSON.props.pageProps.data.status.state
$ScheduledMaintenances = $StatusJSON.props.pageProps.data.maintenance_windows
$MaintenanceID = ""
if ($ScheduledMaintenances.Count -ne 0)
{
    ForEach ($ScheduledMaintenance in $ScheduledMaintenances)
    {
        if ($MaintenanceID -eq "")
        {
            $MaintenanceID = $ScheduledMaintenance
        }
        else
        {
            if (($MaintenanceID.start).Date -ge ($ScheduledMaintenance.start).Date)
            {
                $MaintenanceID = $ScheduledMaintenance
            }
        }
    }
}

$Incidents = $StatusJSON.props.pageProps.data.incidents
$IncidentID = ""
if ($Incidents.Count -ne 0)
{
    ForEach ($Incident in $Incidents)
    {
        if ($IncidentID -eq "")
        {
            $IncidentID = $Incident
        }
        else
        {
            if (($IncidentID.started_at).Date -ge ($Incident.started_at).Date)
            {
                $IncidentID = $Incident
            }
        }
    }
}
#EndRegion

###################################
#Region - Output data
###################################

$PageName = $StatusJSON.props.pageProps.data.name
if ($MaintenanceID)
{
    $LinkToMaintenance = $StatusPageURL
    $MaintenanceScheduled = 1
}
if ($IncidentID)
{
    $LinkToIncident = $StatusPageURL
    $IncidentActive = 1
}

#EndRegion