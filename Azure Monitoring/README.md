# Azure Monitoring
The Azure Monitoring requires some setup in the tenant you would like to monitor.

Below you will find an explenation of the steps needed to set this up. You will only need to do this once for each tenant you would like to monitor.

1. Logon to https://portal.azure.com
2. Go to Microsoft Entra ID (formerly Azure Active Directory)
3. Go to App Registrations
4. Click on New Registration on the top of the screen

![Naamloos](https://github.com/eagle00789/N-Central/assets/643293/0f20591d-e464-4c68-9fea-0793fdbf4234)

5. Give the application a clear name. When you create the application for use with NCentral please always use the name NCentral Azure Monitoring. That way we always know why an application was registered.

![Naamloos-1](https://github.com/eagle00789/N-Central/assets/643293/adcd2870-a410-427a-b2a0-9418ae20fce9)

The rest of the form must be left as-is

6. The base app is now created.

![Naamloos](https://github.com/eagle00789/N-Central/assets/643293/5c34dac2-9d3b-47aa-aa64-baf5badd4597)

Unfortunatly, the app currently doesn’t have any permissions to do anything by default.

7. Go to API Permissions on the left side and click on Add Permission
8. When adding the permissions, choose Microsoft Graph and then choose Application permissions
9. Search for the listed API permissions below and add a checkmark next to it.
    
    Application.Read.All
    AuditLog.Read.All
    DeviceManagementConfiguration.Read.All
    DeviceManagementServiceConfig.Read.All
    Group.Read.All
    IdentityRiskEvent.Read.All
    IdentityRiskyUser.Read.All
    Policy.Read.ConditionalAccess
    Policy.Read.All
    ServiceHealth.Read.All
    ServiceMessage.Read.All

10. Click on Add permissions at the bottom right
11. Some tenants are locked down, so ask a global admin user for that tenant to grant the Admin Consent, or click the button yourself if you have the rights to do this.
12. After the admin consent has been given, this screen should look like this:

![Naamloos-1](https://github.com/eagle00789/N-Central/assets/643293/1d95321d-4204-4d0a-b8b8-198a1f0bd2ed)

13. Now go to Certificates & secrets
14. Open the computer that is going to monitor the Azure services.
15. On the server open the services list.
16. Check which user is set as Logon As for the service Automation Manager Agent

![Naamloos](https://github.com/eagle00789/N-Central/assets/643293/38df756b-f06d-4271-a6f0-5d76972ac985)

17. Open Powershell on the computer that is going to monitor the specified services as the specified user above and execute the code below.
If the user is listed as Local System (like the example above) then open Take Control, go to the System Shell tab and type powershell before executing the commands below:
```
$certname = "NCentral Azure Monitoring"
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256
Export-Certificate -Cert $cert -FilePath "C:\Temp\$certname.cer"
``` 
18. In the C:\Temp folder on the computer that you used to generate this certificate, is now a .cer-file with the name NCentral Azure Monitoring.cer present. Upload this file to the Certificates & Secrets in Azure.
19. Go back to Microsoft Entra ID
20. Choose Roles and administrators
21. Search for the role Global Reader and click on the name

![Naamloos-1](https://github.com/eagle00789/N-Central/assets/643293/b7dc85b6-0484-4063-ad58-47f3b2f2a3c6)

22. Click on Add assignments

![Naamloos](https://github.com/eagle00789/N-Central/assets/643293/9be55392-bfe1-431e-a992-dfc2080cce1f)

23. Seach for NCentral Azure Monitoring, click the checkmark in front of it and click Add

![Naamloos-1](https://github.com/eagle00789/N-Central/assets/643293/c2bfcbc7-1a24-495d-ab1d-ee9822e0f2fc)

24. Go to NCentral and make sure you are at the Managed Services level.
25. Search for the server that you are using to monitor the Azure services with, without going to customer or site level first:

![Naamloos](https://github.com/eagle00789/N-Central/assets/643293/727d6b01-e474-4b73-baac-350970d5c6fd)

26. In the example above, you can see that the server we are going to use, resides at the customer level, because no Site has been specified in this example.
27. In NCentral, now go to Administration > Customers (when the server resides at customer level) or go to the customer level and then go to Administration > Sites if the server resides at a site specific level.
28. Edit the Customer (or Site) and go to the tab Custom Properties. Here you can find 3 empty properties:

![Naamloos-1](https://github.com/eagle00789/N-Central/assets/643293/cd06771e-2754-47da-90f3-e83760ee2560)

29. Fill these properties as following:

    **Azure Certificate Thumbprint**: Go back to Azure and select the application **NCentral Azure Monitoring** and go to the option **Certificates & secrets**. There you will find the thumbprint. Just double click it, to select the entire Thumbprint (even though it isn’t completely visible, it will select the entire thumbprint) and copy it. Next past it in the **Azure Certificate Thumbprint** property in NCentral.

    **Azure Client ID**: Go back to Azure and go to the tab Overview of the application **NCentral Azure Monitoring**. At the top you will find the **Application (client) ID**. Move the mouse over the Application (client) ID to make a copy button visible. Click the copy button and paste the value in the **Azure Client ID** field in NCentral.

    **Azure Tenant ID**: Go back to Azure and go to the tab Overview of the application **NCentral Azure Monitoring**. At the top you will find the **Directory (tenant) ID**. Move the mouse over the **Directory (tenant) ID** to make a copy button visible. Click the copy button and paste the value in the **Azure Tenant ID** field in NCentral.

30. Hit Save at the bottom left to save the now filled custom properties
