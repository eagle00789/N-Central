# To enable debugging messages, remove the comment from the line below
# $DebugPreference = "continue"

# To enable writing of Latitude and Longitude back to N-Central, set value below to $true, otherwise to disable, set to $false
$WriteBack = $true

$CheckImportPSNCentral = Get-Module -ListAvailable -Name PS-NCentral
if (!$CheckImportPSNCentral) {
    Install-Module PS-NCentral -Scope CurrentUser
    Import-Module PS-NCentral
}
else {
    Import-Module PS-NCentral
}

$NCServer = 'https://yourncentralserver.domain.tld'
$JWTToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c' # fake JWT token

Write-Host -ForegroundColor Yellow "Connecting to NCentral"
$NCSession = New-NCentralConnection -ServerFQDN $NCServer -JWT $JWTToken
Write-Host -ForegroundColor Yellow "Getting Customers"
$Customers = Get-NCCustomerList -NcSession $NCSession

$CustomerArray = @()

foreach ($Customer in $Customers)
{
    Write-Progress -Activity "Processing Customer $($Customers.IndexOf($Customer)) of $($Customers.Count)" -Status "Progress:" -PercentComplete ($Customers.IndexOf($Customer)/$($Customers.Count)*100)
    $lat = 0
    $lon = 0
    $CustomerName = [System.Net.WebUtility]::HtmlEncode($Customer.customername)
    $CustomerStreet1Web = [System.Net.WebUtility]::HtmlEncode($Customer.street1)
    $CustomerCustomProperties = Get-NCCustomerPropertyList -CustomerIDs $Customer.customerid
    $CustomerActiveIssues = (Get-NCActiveIssuesList -CustomerID $Customer.customerid).count
    if (($CustomerStreet1Web -ne "") -and ($CustomerCustomProperties.Latitude -eq ""))
    {
        $OpenStreetMapUri = ("https://nominatim.openstreetmap.org/search?q={0}+{1}+{2}&format=xml" -f $CustomerStreet1Web,$Customer.city,$Customer.county)
        $OpenStreetMapResult = Invoke-WebRequest -uri $OpenStreetMapUri
        $OpenStreetMapResultXML = [xml]$OpenStreetMapResult
        write-debug $CustomerName
        write-debug $OpenStreetMapUri
        if ($OpenStreetMapResultXML.searchresults.place -is [System.Array])
        {
            write-debug "Array"
            $lat = $OpenStreetMapResultXML.searchresults.place[0].lat
            $lon = $OpenStreetMapResultXML.searchresults.place[0].lon
        }
        else
        {
            write-debug "NOT-Array"
            $lat = $OpenStreetMapResultXML.searchresults.place.lat
            $lon = $OpenStreetMapResultXML.searchresults.place.lon
        }
        if ($WriteBack)
        {
            Set-NCCustomerProperty -CustomerIDs $Customer.customerid -PropertyLabel Latitude -PropertyValue $lat
            Set-NCCustomerProperty -CustomerIDs $Customer.customerid -PropertyLabel Longitude -PropertyValue $lon
        }
        write-debug $lat
        write-debug $lon
        write-debug "--"
        $CustomerCustomProperties.Latitude = $lat
        $CustomerCustomProperties.Longitude = $lon
    }
    $item = [pscustomobject][ordered]@{
        CustomerID = $Customer.customerid
        CustomerParentID = $Customer.parentid
        CustomerName = $CustomerName
        CustomerStreet1 = $CustomerStreet1Web
        CustomerStreet2 = $Customer.street2
        CustomerZipCode = $Customer.postalcode
        CustomerCity = $Customer.city
        CustomerStateProvince = $Customer.stateprov
        CustomerCountry = $Customer.county
        CustomerLat = $CustomerCustomProperties.Latitude
        CustomerLon = $CustomerCustomProperties.Longitude
        CustomerActiveIssues = $CustomerActiveIssues
    }
    $CustomerArray += $item
}
Write-Progress -Activity "Processing Customer" -Completed

$PlotList = @()
foreach ($SingleCustomer in $CustomerArray)
{
    if ($SingleCustomer.CustomerLat)
    {
        $PlotProps=@{}
        $PlotProps.lon = $SingleCustomer.CustomerLon
        $PlotProps.lat = $SingleCustomer.CustomerLat
        $PlotProps.ActiveIssues = $SingleCustomer.CustomerActiveIssues
        if ($SingleCustomer.CustomerParentID -eq 50)
        {
            $PlotProps.Customer = $SingleCustomer.CustomerName
            $PlotProps.Location = ""
        }
        else
        {
            $PlotProps.Customer = ($CustomerArray | Where-Object -Property CustomerID -EQ $SingleCustomer.CustomerParentID).CustomerName
            $PlotProps.Location = $SingleCustomer.CustomerName
        }
        $PlotList += [PSCustomObject]$PlotProps
    }
}

$HTMLExport = @"
<!DOCTYPE html>
<html>
<head>
  <title>N-Central Customer Map</title>
  <style>
	*{
		margin: 0;
		padding: 0;
	}
	#map{
		width: 100%;
		height: 100vh;
	}
	.leaflet-popup-content {
		margin: 5px;
	}
	.card {
		/*width: 450px;*/
		display: flex;
		flex-direction: column;
		flex-wrap: nowrap;
		align-items: left;
	}
	.card img{
		display: block;
		margin-right: 10px;
		border-radius: 5px 0 0 5px;
		-moz-border-radius: 5px 0 0 5px;
		-webkit-border-radius: 5px 0 0 5px;
	}
  </style>
  <link rel='stylesheet' href='https://unpkg.com/leaflet@1.7.1/dist/leaflet.css'>
</head>
<body>
  <div id="map"></div>
  <script src='https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/leaflet.js'></script>
  <script>
	//Default View
	let mapOptions = {
		center:[50.9, 6.19275],
		zoom:7
	}
	let map = new L.map('map', mapOptions);
	let layer = new L.TileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png');
	map.addLayer(layer);
    // Put your point-definitions here
    let markers = $(ConvertTo-Json $PlotList -Compress);
    let popupOption = {
      "closeButton":false
    }
    markers.forEach(element => {
        new L.Marker([element.lat,element.lon]).addTo(map)
      .on("mouseover",event =>{
        if (element.ActiveIssues > 0)
        {
          event.target.bindPopup('<div class="card"><img src="https://www.freeiconspng.com/uploads/red-not-ok-icon-22.png" width="20" height="20" alt="Error">   <h1>'+element.Customer+'</h1><h2>'+element.Location+'</h2><h3>Issues: '+element.ActiveIssues+'</h3></div>',popupOption).openPopup();
        }
        else
        {
          event.target.bindPopup('<div class="card"><img src="https://www.freeiconspng.com/uploads/green-ok-icon-2.png" width="20" height="20" alt="Normal">   <h1>'+element.Customer+'</h1><h2>'+element.Location+'</h2><h3>Issues: '+element.ActiveIssues+'</h3></div>',popupOption).openPopup();
        }
      })
      .on("mouseout", event => {
        event.target.closePopup();
      })
    });
    </script>
  </body>
  </html>
"@

$HTMLExport | Out-File "OpenStreetMap Customers.html"
