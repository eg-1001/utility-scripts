param ($FileName)


if ($FileName -eq $null) {
throw "FileName was not declared in the command line. Example Usage: .\FileProperties.ps1 -FileName path"
}

Get-ItemProperty $FileName | fl

#powershell.exe -command "Get-ItemProperty 'C:\Windows\Regedit.exe' | fl"

param ($FileName)


if ($FileName -eq $null) {
$FileName = 'C:\Windows\System32\cmd.exe'
#throw "FileName was not declared in the command line. Example Usage: .\FileProperties.ps1 -FileName path"
}

write-host "$FileName"

Get-ItemProperty $FileName | fl