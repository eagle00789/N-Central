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
    Get Statuspal Status Page info

.DESCRIPTION
    Get Statuspal Status Page Information and transform data to N-Central.

.NOTES  
    Author     : Chris Simon
    Version    : 1.0.0.0 Initial Build
#>

###################################
#Region - Params used for debugging
###################################

#$Subdomain = "ic-noc"

#EndRegion

###################################
#Region - Default Output Values where needed
###################################

$Name = ""
$IncidentStatus = 0
$IncidentURL = ""
$MaintenanceStatus = 0
$MaintenanceURL = ""

#EndRegion

###################################
#Region - Get Data
###################################

$BaseURL = "https://statuspal.io/api/v2/status_pages/$SubDomain/summary"
try {
    $Status = Invoke-WebRequest -Uri $BaseURL
    $StatusObject = ConvertFrom-Json $Status
    $Name = $StatusObject.status_page.name
    if ($StatusObject.incidents.Count -gt 0) {
        $Incidents = $StatusObject.incidents
        $Incidents = $Incidents | Sort-Object -Property starts_at
        switch ($Incidents[0].type) {
            "major" {
                $IncidentStatus = 2
                $IncidentURL = $Incidents[0].url
            }
            "minor" {
                $IncidentStatus = 1
                $IncidentURL = $Incidents[0].url
            }
            "scheduled" {
                $MaintenanceStatus = 1
                $MaintenanceURL = $Incidents[0].url
            }
            Default {
                $IncidentStatus = 0
                $MaintenanceStatus = 0
            }
        }
    }
}
catch {
    $IncidentStatus = 2
    $IncidentURL = $_.Exception.Message
}

