<#
RDP Shortcut Updater Script v1 by Erik Gomez-Leon
Uses Desktop Central to copy these to workstations via a configuration.
Updates User Names and Computer Names accordingly from file .\SourceFiles\UserStations.csv

v1 - Initial version

#>

$OrigItems = "SingleMon", "MultiMon", "GPN"
$origItems | foreach {

	$excelImport = Import-Csv -Path .\SourceFiles\UserStations.csv -Header ComputerName, UserName, Domain
	$currentCategory = $_

	$excelImport | foreach {

	$cPC = $_.ComputerName
	$cUser = $_.UserName
	$cDom = $_.Domain

	if (Test-Path .\Shortcuts\$cUser.rdp) {
		$RDPItem = Get-Content .\Shortcuts$currentCategory\$cUser.rdp
		$RDPItem[23] = "full address:s:$cPC"
		$RDPItem | Out-File -FilePath .\Shortcuts$currentCategory\$cUser.rdp
	}

	else {
		$RDPItem = Get-Content .\SourceFiles\Template$currentCategory.rdp
		$RDPItem[23] = $RDPItem[23].replace("COMPUTERNAME","$cPC")
		$RDPItem[48] = $RDPItem[48].replace("DOMAINUSER","$cDom\$cUser")
		$RDPItem | Out-File -FilePath .\Shortcuts$currentCategory\$cUser.rdp
	}


	}

}

Write-Host "Updates Complete!"

Sleep 5