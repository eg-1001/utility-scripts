#this script requires admin rights on remote machines

#$ShdName = "WS-1b5wth3"
#$ShdName = "WS-8FQ7PY2"
$ShdName = Read-Host -Prompt "Enter a computer name"
$ShdCreds = Get-Credential


    Start-Job -ScriptBlock {quser /server:$using:shdName} -Name GetQUserData -Credential $ShdCred | Out-Null
	#Get-Job
	$allSessions = Receive-Job GetQUserData -Wait
	#sleep 2
	Remove-Job *



#$allSessions

$userNames = @()
foreach ($session in $allSessions) {


$shiftRow = $false
#code for getting current username	
    $currSession = ($session -split ' +')[1]

#code for getting Session State
	$sessionStateF = ($session -split ' +')[3]
	if (!($sessionStateF -eq "Disc")) {
        $shiftRow = $true
		$sessionStateF = ($session -split ' +')[4]
	}

#code for getting session name, needed for checking if remote
$sessionName = ($session -split ' +')[2]
if ($sessionName -match "^\d+$") {
		$sessionNameT = "None"
		$sessionNameT = $sessionName
        $sessionLogon1 = ($session -split ' +')[5]
        $sessionLogon2 = ($session -split ' +')[6]
        $sessionLogon3 = ($session -split ' +')[7]

        $sessionTime = $sessionLogon2 + $sessionLogon3
        $sessionTime = $sessionTime.replace(" ","")
        $sessionIn = $sessionLogon1 + " " + $sessionTime
	}
	else {
		$sessionNameT = $sessionName
        $sessionLogon1 = ($session -split ' +')[6]
        $sessionLogon2 = ($session -split ' +')[7]
        $sessionLogon3 = ($session -split ' +')[8]

        $sessionTime = $sessionLogon2 + $sessionLogon3
        $sessionTime = $sessionTime.replace(" ","")
        $sessionIn = $sessionLogon1 + " " + $sessionTime
	}

    $loginLocation = "Disconnected" #default value
    if ($sessionName -eq "console") {$loginLocation = "Local"}
    if ($sessionName -like "*tcp*") {$loginLocation = "Remote"}

    if ($loginLocation -ne "Disconnected") {
        #$logonUIData = Get-Process -Name "logonui" -ComputerName $ShdName -ErrorAction SilentlyContinue
    #-ComputerName $using:ShdName 
        
        if (!($currSession -eq "USERNAME")) {
        Start-Job -ScriptBlock {Get-Process -Name "logonui" -ComputerName $using:ShdName -ErrorAction SilentlyContinue} -Name GetLogonUI -Credential $ShdCred | Out-Null
        #Get-Job
        $logonUIData = Receive-Job GetLogonUI -Wait
        #sleep 2
        Remove-Job *

        #get total processes of LogonUI.exe, one is used for each session that a lock screen is present on
        $logonUICount = $logonUIData.Length
        }
        else {$logonUICount = 0}

    
        #default variable, shouldn't be seen
        $lockStatus = "Unlocked"
    
        


        if (($loginLocation -eq "Local")) {
            
            if ($logonUICount -eq 1) {
                #Write-Host "Console screen is locked."
                $lockStatus = "Console (Locked)"
            }
            else {
                #Write-Host "Console screen is unlocked"
                $lockStatus = "Console"
            }

        }

        #code for checking remote lock status
        if (($loginLocation -eq "Remote")) {
            if ($logonUICount -ge 2) {
                #Write-Host "RDP session is locked."
                $lockStatus = "Remote (Locked)"
            }
            else {
                #Write-Host "RDP session is unlocked."
                $lockStatus = "Remote"
            }
        }


        #Write-Host "User's lock status is $lockStatus" -ForegroundColor Yellow
    }
    else {$LockStatus = "Disconnected"}








#code for getting Session ID
	$sessionID = ($session -split ' +')[2]
	if ($sessionID -match "^\d+$") {
		$sessionIDF = $sessionID
	}
	else {
		$sessionIDF = ($session -split ' +')[3]
	}


#code for getting current idle time
if (!($shiftRow)) {$sessionIdle = ($session -split ' +')[4]}
else {$sessionIdle = ($session -split ' +')[5]}
if (!($sessionIdle -match "^\d+$")) {$sessionIdle = 0}
#$shiftRow
#$sessionIdle

#add data to table if temp data is not the header row
	if (!($currSession -eq "USERNAME")) {
	$userNames += [pscustomobject] @{
	Username = $currSession
	State = $sessionStateF
	SessionID = $sessionIDF
    LoginLocation = $lockStatus
    LoginTime = $sessionIn
    IdleTime = (New-TimeSpan -Minutes $sessionIdle)
    SessionName = $sessionNameT
	}
	}

}

$activeUser = $userNames | Where-Object {$_.State -match "Active"}
$discUser = $userNames | Where-Object {$_.State -match "Disc"}

$activeTrue = $false
$warningSess = $false
$discTrue = $false



if (!($activeUser -eq $null)) {$activeTrue = $true}

if ($userNames -eq $null) {$warningSess = $true}

if (!($discUser -eq $null)) {$discTrue = $true}


#$allSessions

$userNames | ft
pause


<#
$usernames | foreach {
    
    if ($_.LoginLocation -ne "Disconnected") {
        $logonUIData = Get-Process -Name "logonui" -ComputerName $ShdName -ErrorAction SilentlyContinue
    
        #default variable, shouldn't be seen
        $lockStatus = "Unlocked"
    
        #get total processes of LogonUI.exe, one is used for each session that a lock screen is present on
        $logonUICount = $logonUIData.Length


        if (($_.LoginLocation -eq "Local")) {
            
            if ($logonUICount -eq 1) {
                Write-Host "Console screen is locked."
                $lockStatus = "Console (Locked)"
            }
            else {
                Write-Host "Console screen is unlocked"
                $lockStatus = "Console"
            }

        }

        #code for checking remote lock status
        if (($_.LoginLocation -eq "Remote")) {
            if ($logonUICount -ge 2) {
                Write-Host "RDP session is locked."
                $lockStatus = "Remote (Locked)"
            }
            else {
                Write-Host "RDP session is unlocked."
                $lockStatus = "Remote (Locked)"
            }
        }


        Write-Host "User's lock status is $lockStatus" -ForegroundColor Yellow
    }




}
    #>