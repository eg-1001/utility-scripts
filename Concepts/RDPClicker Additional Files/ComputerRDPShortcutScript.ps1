<#
RDP Shortcut Updater Script v1 by Erik Gomez-Leon
Uses Desktop Central to copy these to workstations via a configuration.
Updates User Names and Computer Names accordingly from file .\SourceFiles\UserStations.csv

v1 - Initial version

#>

$excelImport = Import-Csv -Path .\SourceFiles\UserStations.csv -Header ComputerName, UserName, Domain

$excelImport | foreach {

$cPC = $_.ComputerName
$cUser = $_.UserName
$cDom = $_.Domain
<#
if (Test-Path .\Shortcuts\$cUser.rdp) {
    $RDPItem = Get-Content .\Shortcuts\$cUser.rdp
    $RDPItem[23] = "full address:s:$cPC"
    $RDPItem | Out-File -FilePath .\Shortcuts\$cUser.rdp
}
#>

#else {
    $RDPItem = Get-Content .\SourceFiles\Template.rdp
    $RDPItem[23] = $RDPItem[23].replace("COMPUTERNAME","$cPC")
    $RDPItem[48] = $RDPItem[48].replace("DOMAINUSER","$cDom\$cUser")
    $RDPItem | Out-File -FilePath .\Shortcuts\$cPC.rdp
#}


}

Write-Host "Script Complete!"

Sleep 5