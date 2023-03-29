
#Create a file named "MACAddresses.txt" to ping. 

$pcList = Get-Content .\MACAddresses.txt
$systemInfo = @()
$iterations = 0
$maxValue = $pcList.Count


$pcList | foreach {
	$tempVar = $_
	

$connectTest = Test-Connection $tempVar -count 1 -ErrorAction SilentlyContinue
#Write-Host "Retrying Connection"
$connectTest = Test-Connection $tempVar -count 1 -ErrorAction SilentlyContinue

if ($connectTest -eq $null) { 
	
	$systemInfo += [pscustomobject] @{
		IPAddress = $tempVar
		MAC_Address = "N/A"
		Reachable = $false
	}
	
}

else {
	
	$arpData = Get-NetNeighbor
	$getMac = $arpData | Where-Object {$_.IPAddress -eq $tempVar}
	
	#Write-Host $tempVar
	#Write-Warning $getMac.LinkLayerAddress
	#Write-Host
	#start "https://$tempVar"
	
	$systemInfo += [pscustomobject] @{
		IPAddress = $tempVar
		MAC_Address = $getMac.LinkLayerAddress
		Reachable = $true
	}

}


if ($iterations -lt 1) {Write-Progress -Id 1 -Activity "Connecting to Devices..." -PercentComplete (($iterations/$maxValue)*100)}
$iterations = $iterations + 1
if ($iterations -gt 1) {Write-Progress -Id 1 -Activity "Connecting to Devices..." -PercentComplete (($iterations/$maxValue)*100)}

 } 
 
$systemInfo | ft

$exportChoice = Read-Host -Prompt "Export this to CSV? (y/n)"

if (($exportChoice -eq "y") -OR ($exportChoice -eq "Y")) {
	
	$date1 = get-date -UFormat "%m%d%Y_%R"

	$date2 = $date1.replace(":","")

	$expPath = ".\MacAddressGetOutput_$date2.csv"

	$systemInfo | Export-CSV -Path $expPath -NoTypeInformation
	
	Write-Host
	Write-Host Saved CSV file export to $expPath
	
}

Write-Host "Script Complete!"
 
 PAUSE