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

This service will monitor the expiry of a certificate or client secret App Registration in Azure.
To monitor the app, you need the Object ID of the app that has the certificate or client secret that you would like to monitor.

To get the Object ID, go to [Azure](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps) and click on the app with a Certificate or Secret, then click the copy button next to the Object ID and paste this in the Object ID field of this service.

For the other field you need to fill out, you need [this app](https://github.com/eagle00789/N-Central/blob/master/Azure%20Monitoring/README.md) setup in Azure for the customer