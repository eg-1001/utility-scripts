#ACCU Printer Remap Script w/ command line parameter support and error handling

# Create OLD IP variable and assign to old IP string with wild cards
# Create New IP variable and assign to new IP string
param ($OldIP, $NewIP)


#$OldIP = "192.168.10.165"
#$NewIP = "192.168.5.17"

#<#
if ($OldIP -eq $null -AND $NewIP -eq $null) {
throw "OldIP and NewIP were not declared in the command line. Example Usage: .\PrinterRemapParameter.ps1 -OldIP 192.168.1.1 -NewIP 192.168.1.2"
}

if ($OldIP -eq $null) {
throw "OldIP was not declared in the command line. Example Usage: .\PrinterRemapParameter.ps1 -OldIP 192.168.1.1 -NewIP 192.168.1.2"
}

if ($NewIP -eq $null) {
throw "NewIP was not declared in the command line. Example Usage: .\PrinterRemapParameter.ps1 -OldIP 192.168.1.1 -NewIP 192.168.1.2"
}
##>

Write-Host "Replacing Printer Port $OldIP with Printer Port $NewIP, this may take a minute"
Write-Host

# Grab printer object that has OLD IP and assign to variable
$Printer = Get-Printer | Where-Object { $_.PortName -like "*$OldIP*" }

$PrinterPort = Get-PrinterPort -Name $Printer[0].PortName

$PrinterName = $Printer.Name

# Create new printer port with NEWIP

Add-PrinterPort -Name "IP_$NewIP" -PortNumber $PrinterPort.PortNumber -PrinterHostAddress $NewIP -SNMP $PrinterPort.SNMPIndex -SNMPCommunity $PrinterPort.SNMPCommunity

# Grab Printer that has OLD IP and assign to new port

$PrinterName | ForEach-Object {

Set-Printer -Name $_ -PortName "IP_$NewIP"

#Write-Host "Setting $_ to port name IP_$NewIP"
}

# Delete old port


Remove-PrinterPort -Name "*$OldIP*"



Write-Host "Printer Port replacement complete."
Write-Host

<#
$OpenDevPrint = read-host -Prompt "Would you like to open Devices and Printers? (y/n)"
if ($OpenDevPrint -eq "y") {
control printers
Write-Host
}
#>
