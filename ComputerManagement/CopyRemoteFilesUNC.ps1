#easy script for copying files to UNC paths
#enter a list of hosts into a file named "servernames.txt" and save it in the script's directory

$pcList = Get-Content .\servernames.txt
$copyFrom = Read-Host -Prompt "Enter a the full UNC path of the item to copy (without quotes)"
Write-Host "Enter a UNC share path to copy to, without the server name"
$copyTo = Read-Host -Prompt "Example: c$\users\public\desktop (without quotes)"


#Copy-Item -Path "\\SERVER\common\Erik\choice.cmd" -Destination "\\192.168.9.28\c$\Users\Public\Desktop" -Force

$pcList | foreach {
	$tempVar = $_
	Copy-Item -Path $copyFrom -Destination "\\$tempVar\$copyTo" -Force
	Write-Host $tempVar
}

Write-Host "Script executed succesfully."
PAUSE