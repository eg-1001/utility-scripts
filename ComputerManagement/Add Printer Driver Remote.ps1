
param ($checkIP, $laserIP)


#$OldIP = "192.168.10.165"
#$NewIP = "192.168.5.17"

#<#
if ($laserIP -eq $null -AND $checkIP -eq $null) {
throw "OldIP and NewIP were not declared in the command line. Example Usage: .\Add DNA Printers.ps1 -checkIP 192.168.1.1 -LaserIP 192.168.1.2"
}

if ($checkIP -eq $null) {
throw "Check Printer IP was not declared in the command line. Example Usage: .\Add DNA Printers.ps1 -checkIP 192.168.1.1 -LaserIP 192.168.1.2"
}

if ($laserIP -eq $null) {
throw "Laser Printer IP was not declared in the command line. Example Usage: .\Add DNA Printers.ps1 -checkIP 192.168.1.1 -LaserIP 192.168.1.2"
}


$checkPrinterIP = $checkIP
$laserPrinterIP = $laserIP



$driverStatus = Get-PrinterDriver "HP Universal Printing PCL 6 (v6.7.0)" -ErrorAction SilentlyContinue

if ($driverStatus -eq $null) {
	Write-Host "Driver not installed, using source from Helike"
	pnputil.exe /a "\\SERVER\installs\HP\HP Universal Printing PCL 6 (v6.7.0)\hpcu225uDriver\*.inf"
	
	Add-PrinterDriver -Name "HP Universal Printing PCL 6 (v6.7.0)" -InfPath "C:\Windows\System32\DriverStore\FileRepository\hpcu225u.inf_amd64_1713f9ebc5a39f72\hpcu225u.inf"
	
	Write-Host "Driver should be installed by now."
}
else {
	Write-Host "HP PCL 6.7.0 driver is already installed."
}

$printerDriver = "HP Universal Printing PCL 6 (v6.7.0)"



$currentPrinterPorts = (Get-PrinterPort).Name
$currentPrinter = (Get-Printer).Name

Write-Host "Querying Printer Info..."

if (($currentPrinter -contains "Laser Printer"))
{
	Write-Host "Removing existing Laser Printer"
	Remove-Printer -Name "Laser Printer"	
}
if (($currentPrinterPorts -contains "$laserPrinterIP`_Laser")) 
{
		Write-Host "Removing existing Laser Printer Port/IP"
		Remove-PrinterPort -Name "$laserPrinterIP`_Laser"
}

Write-Host "Adding Laser Printer..."
Add-PrinterPort -Name "$laserPrinterIP`_Laser" -PortNumber 9100 -PrinterHostAddress $laserPrinterIP
Add-Printer -DriverName $printerDriver -Name "Laser Printer" -PortName "$laserPrinterIP`_Laser"
Write-Host "Laser Printer successfully added with IP $laserPrinterIP"


if (($currentPrinter -contains "Check Printer"))
{
	Write-Host "Removing existing Check Printer"
	Remove-Printer -Name "Check Printer"
}
if (($currentPrinterPorts -contains "$checkPrinterIP`_Check")) 
{
		Write-Host "Removing existing Check Printer Port/IP"
		Remove-PrinterPort -Name "$checkPrinterIP`_Check"
}

Write-Host "Adding Check Printer..."
Add-PrinterPort -Name "$checkPrinterIP`_Check" -PortNumber 9100 -PrinterHostAddress $checkPrinterIP
Add-Printer -DriverName $printerDriver -Name "Check Printer" -PortName "$checkPrinterIP`_Check"
Write-Host "Check Printer successfully added with IP $checkPrinterIP"

Write-Host "Script complete!" -ForegroundColor Yellow

Sleep 20