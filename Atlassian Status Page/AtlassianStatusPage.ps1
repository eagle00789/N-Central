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
    Get Atlassian Status Page info

.DESCRIPTION
    Get Atlassian Status Page Information and transform data to N-Central.

.NOTES  
    Author     : Chris Simon
    Version    : 1.0.0.0 Initial Build
#>

###################################
#Region - Params used for debugging
###################################

#$StatusPageURL= "https://status.carbonite.com/"

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

$StatusJSON = Invoke-RestMethod -Method Get -Uri "$($StatusPageURL)/api/v2/summary.json"
$ScheduledMaintenances = $StatusJSON.scheduled_maintenances
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
            if (($MaintenanceID.scheduled_for).Date -ge ($ScheduledMaintenance.scheduled_for).Date)
            {
                $MaintenanceID = $ScheduledMaintenance
            }
        }
    }
}

$Incidents = $StatusJSON.incidents
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

$PageName = $StatusJSON.page.name
if ($MaintenanceID)
{
    $LinkToMaintenance = $MaintenanceID.shortlink
    $MaintenanceScheduled = 1
}
if ($IncidentID)
{
    $LinkToIncident = $IncidentID.shortlink
    $IncidentActive = 1
}

#EndRegion