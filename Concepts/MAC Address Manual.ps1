while ($true) {

 $fullIP = Read-Host -Prompt "Enter a full IP address."

 #Write-Host $fullIP

ping $fullIP -n 1

$arpData = Get-NetNeighbor

$getMac = $arpData | Where-Object {$_.IPAddress -eq $fullIP}


Write-Host
Write-Warning $getMac.LinkLayerAddress

 } 