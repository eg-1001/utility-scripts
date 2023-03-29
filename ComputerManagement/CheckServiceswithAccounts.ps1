$fullServicesList = Get-WmiObject win32_service
$servicesList = $fullServicesList
$servicesList = $servicesList | ? {$_.StartName -ne "LOCALSYSTEM"}
$servicesList = $servicesList | ? {$_.StartName -notlike "NT AUTHORITY*"}
$servicesList = $servicesList | ? {$_.StartName -ne $null}
$servicesList = $servicesList | ? {$_.StartName -notlike "NT SERVICE*"}

cls

if ($servicesList -eq $null) {Write-Error "NO service accounts found"}


else {Write-Host "Service accounts found"

$servicesList | foreach {
Write-Host "Service name:"$_.Name
Write-Host "running as:"$_.StartName
Write-Host
}

} 

