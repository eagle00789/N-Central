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
    Get Zendesk Status Page info

.DESCRIPTION
    Get Zendesk Status Page Information and transform data to N-Central.

.NOTES  
    Author     : Chris Simon
    Version    : 1.0.0.0 Initial Build
#>

###################################
#Region - Params used for debugging
###################################

#$StatusPageURL = "https://uptime.n-able.com/"

#EndRegion

###################################
#Region - Default Output Values where needed
###################################

$Description = " "
$Group = " "
$Name = " "
$Status = 0
$StatusURL = $StatusPageURL

#EndRegion

###################################
#Region - Get Data
###################################

$StatusJSON = Invoke-RestMethod -Method Get -Uri "$($StatusPageURL)/api/v1/public/dashboard/"

#EndRegion

###################################
#Region - Output data
###################################

$StatusObjects = $StatusJSON.objects
ForEach ($StatusObject in $StatusObjects)
{
    if ($StatusObject.status -ne 0)
    {
        $Description = $StatusObject.description
        $Group = $StatusObject.group
        $Name = $StatusObject.name
        $Status = $StatusObject.status
        break
    }
}

#EndRegion