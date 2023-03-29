Import-Module admpwd.ps




$host.ui.rawui.WindowTitle = "LAPS Password Reporter"
#v2 changes - multiuser handling, bug with disconnected user array size

#needs DC functionality
#$DCList | ft

$passwordList = @()

#<#
$DCList | foreach {

$tempList = @()

$currentObject = $_.resource_name

$currentPassword = (Get-AdmPwdPassword $currentObject).Password

$tempList += [pscustomobject] @{

a = $currentObject
b = $currentPassword

}

$passwordList += [pscustomobject] @{
"ComputerName" = $tempList.a
"events_Password" = $tempList.b

}
}

#>

if (!(Test-Path -Path "C:\TEMP")) {New-Item -Path "C:\" -Name "TEMP" -ItemType Directory}

$date1 = get-date -UFormat "%m%d%Y_%R"

$date2 = $date1.replace(":","")

$expPath = "C:\Temp\ExportEventsPwds_$date2.csv"

$passwordList | Export-CSV -Path $expPath -NoTypeInformation

Write-Host
Write-Host Saved CSV file export to $expPath