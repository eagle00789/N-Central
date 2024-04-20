$CheckImportPSNCentral = Get-Module -ListAvailable -Name PS-NCentral
if (!$CheckImportPSNCentral) {
    Install-Module PS-NCentral -Scope CurrentUser
    Import-Module PS-NCentral
}
else {
    Import-Module PS-NCentral
}

$NCServer = 'https://yourncentralserver.domain.tld'
$JWTToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c' #fake JWT Token

Write-Host -ForegroundColor Yellow "Connecting to NCentral"
$NCSession = New-NCentralConnection -ServerFQDN $NCServer -JWT $JWTToken
Write-Host -ForegroundColor Yellow "Getting Customers"
$Customers = Get-NCCustomerList -NcSession $NCSession

$CustomerArray = @()
$i = 1

foreach ($Customer in $Customers)
{
    Write-Progress -Activity "Processing Customer $i of $($Customers.Count)" -Status "Progress:" -PercentComplete ($i/$($Customers.Count)*100)
    $lat = 0
    $lon = 0
    $CustomerID = $Customer.customerid
    $CustomerName = [System.Net.WebUtility]::HtmlEncode($Customer.customername)
    $CustomerStreet1 = $Customer.street1
    $CustomerStreet2 = $Customer.street2
    $CustomerCity = $Customer.city
    $CustomerStateProvince = $Customer.stateprov
    $CustomerZipCode = $Customer.postalcode
    $CustomerCountry = $Customer.county
    $CustomerParentID = $Customer.parentid
    $CustomerStreet1Web = $CustomerStreet1.Replace(" ", "+")
    $CustomerCustomProperties = Get-NCCustomerPropertyList -CustomerIDs $CustomerID
    $CustomerLat = $CustomerCustomProperties.Latitude
    $CustomerLon = $CustomerCustomProperties.Longitude
    $CustomerActiveIssues = (Get-NCActiveIssuesList -CustomerID $CustomerID).count
    if (($CustomerStreet1Web -ne "") -and ($CustomerLat -eq ""))
    {
        $OpenStreetMapUri = "https://nominatim.openstreetmap.org/search?q=$CustomerStreet1Web+$CustomerCity+$CustomerCountry&format=xml"
        $OpenStreetMapResult = Invoke-WebRequest -uri $OpenStreetMapUri
        $OpenStreetMapResultXML = [xml]$OpenStreetMapResult
        $CustomerName
        $OpenStreetMapUri
        $Places = $OpenStreetMapResultXML.searchresults.place
        if ($OpenStreetMapResultXML.searchresults.place -is [System.Array])
        {
            write-host "Array"
            $lat = $OpenStreetMapResultXML.searchresults.place[0].lat
            $lon = $OpenStreetMapResultXML.searchresults.place[0].lon
            Set-NCCustomerProperty -CustomerIDs $CustomerID -PropertyLabel Latitude -PropertyValue $lat
            Set-NCCustomerProperty -CustomerIDs $CustomerID -PropertyLabel Longitude -PropertyValue $lon
        }
        else
        {
            write-host "NOT-Array"
            $lat = $OpenStreetMapResultXML.searchresults.place.lat
            $lon = $OpenStreetMapResultXML.searchresults.place.lon
            Set-NCCustomerProperty -CustomerIDs $CustomerID -PropertyLabel Latitude -PropertyValue $lat
            Set-NCCustomerProperty -CustomerIDs $CustomerID -PropertyLabel Longitude -PropertyValue $lon
        }
        $lat
        $lon
        write-host "--"
        $CustomerLat = $lat
        $CustomerLon = $lon
    }
    $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'CustomerID' -Value $CustomerID
    $item | Add-Member -type NoteProperty -Name 'CustomerParentID' -Value $CustomerParentID
    $item | Add-Member -type NoteProperty -Name 'CustomerName' -Value $CustomerName
    $item | Add-Member -type NoteProperty -Name 'CustomerStreet1' -Value $CustomerStreet1
    $item | Add-Member -type NoteProperty -Name 'CustomerStreet2' -Value $CustomerStreet2
    $item | Add-Member -type NoteProperty -Name 'CustomerZipCode' -Value $CustomerZipCode
    $item | Add-Member -type NoteProperty -Name 'CustomerCity' -Value $CustomerCity
    $item | Add-Member -type NoteProperty -Name 'CustomerStateProvince' -Value $CustomerStateProvince
    $item | Add-Member -type NoteProperty -Name 'CustomerCountry' -Value $CustomerCountry
    $item | Add-Member -type NoteProperty -Name 'CustomerLat' -Value $CustomerLat
    $item | Add-Member -type NoteProperty -Name 'CustomerLon' -Value $CustomerLon
    $item | Add-Member -type NoteProperty -Name 'CustomerActiveIssues' -Value $CustomerActiveIssues
    $CustomerArray += $item
    $i++
}
Write-Progress -Activity "Processing Customer" -Completed

$CustomerPlots = ""
foreach ($SingleCustomer in $CustomerArray)
{
    if (($SingleCustomer.CustomerLat -ne 0) -and ($SingleCustomer.CustomerLat -notlike ""))
    {
        if ($SingleCustomer.CustomerParentID -eq 50)
        {
            $CustomerPlots += "{'lon': " + $SingleCustomer.CustomerLon + ", 'lat': " + $SingleCustomer.CustomerLat + ",'Customer': '" + $SingleCustomer.CustomerName + "', 'Location':'" + $SingleCustomer.CustomerName + "','ActiveIssues':'" + $SingleCustomer.CustomerActiveIssues + "'},"
        }
        else
        {
            for($i=0;$i-le $CustomerArray.length-1;$i++)
            {
                if ($CustomerArray[$i].CustomerID -eq $SingleCustomer.CustomerParentID)
                {
                    $CustomerPlots += "{'lon': " + $SingleCustomer.CustomerLon + ", 'lat': " + $SingleCustomer.CustomerLat + ",'Customer': '" + $CustomerArray[$i].CustomerName + "', 'Location':'" + $CustomerArray[$i].CustomerName + " - " + $SingleCustomer.CustomerName.Replace("'","\'") + "','ActiveIssues':'" + $SingleCustomer.CustomerActiveIssues + "'},"
                }
            }
        }
    }
}

$HTMLExport = @"
<!DOCTYPE html>
<html>
<head>
  <title>Detron N-Central Customer Map</title>
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
    let markers = [
"@

$HTMLExport += $CustomerPlots.Substring(0,$CustomerPlots.Length-1)

$HTMLExport += @"
    ];
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
