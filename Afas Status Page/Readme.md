# Afas Status Page

This simple service will monitor https://afasstatus.nl for any service issues with the application Afas.
Afas doesn't use any public known status page providers but they coded their own status page.
The exact status page that is being read is https://afasstatus.nl/json.

A result of 1 means that there are no known issues.
A result of 2 or 3 means minor issue, warning or maintenance.
A result of 4 means an outage.