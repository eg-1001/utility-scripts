cls
$serverName = Read-Host -Prompt "Enter Server Name"

#connection validation
$invalidPC = $false  
$hasUser = $true  
$errorConnect = $null          
$connectTest = Test-Connection $serverName -count 1 -ErrorAction SilentlyContinue

#<#
                
 if ($connectTest -eq $null) { 
 $invalidPC = $true 
 $errorConnect = "Entered Server Name $serverName does not exist."
 }
 
 
 if ($invalidPC -eq $false) {
 $testSessions = quser /server:$serverName
	 if ($testSessions -eq $null) { 
	 $hasUser = $false
	 $errorConnect = "No users are logged in on $serverName`."
	 }
 }
 
                               
while (($invalidPC -eq $true) -OR ($hasUser -eq $false)) {


	cls
	Write-Host $errorConnect
	$serverName = read-host -Prompt "Please enter the Server Name to connect to"
	$connectTest = Test-Connection $serverName -count 1 -ErrorAction SilentlyContinue						
	
	if ($connectTest -eq $null) { 
		 $invalidPC = $true 
		 $errorConnect = "Entered Server Name $serverName does not exist."
	 }	
	 else {$invalidPC = $false}	
		
	if ($invalidPC -eq $false) {
 $testSessions = quser /server:$serverName
	 if ($testSessions -eq $null) { 
	 $hasUser = $false
	 $errorConnect = "No users are logged in on $serverName`."
	 }
 }
	
	
            }
# end connection validation


$allSessions = quser /server:$serverName
$userNames = @()
foreach ($session in $allSessions) {
$currSession = ($session -split ' +')[1]


$sessionStateF = ($session -split ' +')[3]
if (!($sessionStateF -eq "Disc")) {
$sessionStateF = ($session -split ' +')[4]
}


$sessionID = ($session -split ' +')[2]


if ($sessionID -match "^\d+$") {
$sessionIDF = $sessionID
}
else {
$sessionIDF = ($session -split ' +')[3]
}



if (!($currSession -eq "USERNAME")) {
$userNames += [pscustomobject] @{
Username = $currSession
State = $sessionStateF
ID = $sessionIDF
}
}

#Write-Host $session
#Write-Host $sessionStateF
#Write-Host $currSession

#$userNames
}



$userNames | ft



Write-Host "Select a user to disconnect from $serverName`:"
$userLogOff = Read-Host
#Write-Host "---------------"

$selectedUser = $userNames | Where-Object {$_.Username -eq $userLogOff}





if ($selectedUser.Username -eq $userLogOff) {$trueUser = $true}
else {$trueUser = $false}

while ($trueUser -eq $false) {
cls
$userNames | ft
Write-Host "$userLogOff does not exist on $serverName, enter a new username"
$userLogOff = Read-Host
$selectedUser = $userNames | Where-Object {$_.Username -eq $userLogOff}
#$selectedUser
#write-host $selectedUser.Name
if ($selectedUser.Username -eq $userLogOff) {$trueUser = $true}
else {$trueUser = $false}


}

$logOffID = $selectedUser.ID

logoff $logOffID /server:$serverName

Write-Host $userLogOff "has been logged off of $serverName"

pause