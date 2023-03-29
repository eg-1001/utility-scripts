[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12


#window name for easy identification
$scriptVer = "EC Lookupv10.3.3"
$host.ui.rawui.WindowTitle = $scriptVer

#local environment variables
$localPrintServer = "mimas"
$dcServerName = "jupiter.accu.hdq"
$dcServerPort = "8383"
$global:userDom = "accu"
$global:dcToken = $null
$global:userLoggedIn = $false

$scriptSettingsFolderName = "Endpoint Central PS Script"
$scriptSettingsFolder = "$env:LOCALAPPDATA\$scriptSettingsFolderName"
$scriptSettingsCFG = "$scriptSettingsFolder\settings.txt"

<#
SCRIPT USAGE NOTES
Update the local environment variables above
Run the script using a computer with the Desktop Central certificate installed (Any computer with an DCAgent installed will suffice)
To use the Shadow functionality, you must run the script itself as a domain user. Alternatively you need the appropriate permissions and account to shadow (this feature was removed?).

#>





<#
Changelog
v1.0.0 (08/13/2020) - Initial version, only supports computer lookup and asset URLs (28 lines of code!)
v1.1.0 (08/14/2020) - Moved json query code to within loop, fixes data not being up to date
v2.0.0 (08/17/2020) - Added link mode, url opener for config and patch pages, and user search features
v3.0.0 (10/14/2020) - Added url opener feature for user search mode, script will prompt if a link should open if only one user is returned
v4.0.0 (01/14/2021) - Added quser output to single user search
v5.0.0 (04/18/2021) - Removed Laptops from user based search and remote systems. 
							Added Connection test before quser. If remote system is present in search, a quser command will not run. 
							Fixed bugs, added new search option "quser", added short commands like "!c"
v6.0.0 (06/02/2021) - Major code overhaul, methods implemented to make edits much easier. 
							Added incomplete search for pc names and added autopref mode
v7.0.0 (06/02/2021) - Added Data category of search, supports IP and Notes
v8.0.0 (07/02/2021) - Stopped renaming the scripts to make file replacements easier
							Added Notes autoOpen function, coloring for computer status (doesn't work in ISE),
							Added Printer Lookup, login feature
							Addded function framework for RDP Shadowing feature and RDP
v9.0.0 (07/12/2021) - Redesigned the automatic preference mode; added shadowing, RDP, and DC management, pc selection when multiple are present (with a preference)
v9.0.1 (07/12/2021) - bugfixes related to pc selection code	
v9.0.2 (08/23/2021) - added patch management and config search links
v9.0.3 (12/16/2021) - some bugfixes, mainly the notes search AutoPref function working correctly, reimplemented dc link opener
v9.0.4 (10/29/2021) - bugfix for IE not configured error, implemented server name and server port variables into JSON request, tested obfuscated code feature (was removed later)
v9.1.0 (12/17/2021) - Added Two Factor Authentication to the script, this removes the baked in API key
v9.1.1 (12/20/2021) - Added user validation checks to the script to prevent accidential lockouts, added a message to inform that the password is invalid
v9.1.2 (12/20/2021) - Fixed random statement in the query that says "False", fixed bug with api queries when running the script directly from Powershell.
v9.2.0 (12/23/2021) - Added export mode, made change to PC selection code 
v9.2.1 (12/30/2021) - Fixed selection code when a user is involved, added Location property to results 
v10.0.0 (12/31/2021) - Bumped major version number up, added code for reading and writing to configs, added more comments,  changed shadowing code slightly
v10.0.1 (12/31/2021) - Bugfix to support DC URLs in version 10.1.2137.9
v10.0.2 (03/17/2022) - Added ComputerID data to search options
v10.1.0 (04/15/2022) - Added new QUser code for looking up data, left old function when credentials are not provided. 
							There is a bug that breaks this new functionality, but only if ran from the network. 
							Any account used on this script must have permissions to read the executing directory. 
							Added recursive data to user data lookup. 
v10.2.0 (11/23/2022) - Renamed script to EndpointCentralLookup, changed dcpref command name to managepref. 
							Properly added requireShadowConsent which can be enabled with shadowConsent command
							Added debug option for json data, added ability to toggle quser, removed standalone quser mode
v10.3.0 (01/26/2023) - Fixed shadowconsent feature being broken, added user notification when shadowing ends (only applies if consent mode is active). 
							Added restart option, added apikey option, allowed saving api key to file 
v10.3.1 (01/26/2023) - Updated a few API URLs for new version of API, added MAC Address column for table options
v10.3.2 (01/27/2023) - Added printer URL opening function, supports multiple printer objects. 
							Might have fixed an issue where the all printers command returns no data the first time it runs. 
							Updated Changelog data above
v10.3.3 (02/02/2023) - Added proper EC API version 1.4 support.
		
TODO:  
	1. Add MAC Address searching (needs parsing for instances where multiple MAC addresses are present
	2. add autocopy to clipboard for computer name, ip address, or mac address
			Set-Clipboard -Value "This is a test string"       
#>

# WIP code for script settings
#create default script settings file

#create config path if it doesn't exist
if (!(Test-Path $scriptSettingsFolder)) {New-Item "$env:LOCALAPPDATA" -ItemType Directory -Name $scriptSettingsFolderName}

#create config if it doesn't exist
if (!(Test-Path $scriptSettingsCFG)) 
	{
		$defaultTableOrder = "tableOrder:ComputerName, LoggedOnUsers, CurrentOwner, IPAddress, Notes, ComputerLocation, OSVersion, ComputerStatus, ComputerID, MacAddress"
		$defaultLastMode = "lastMode:computer"
		$defaultLastPref = "lastPref:none"
		$defaultQuserEnabled = "quserEnabled:y"
		$defaultshdConsent = "shdRequireConsent:n"
		$defaultapiKey = "apiKey:none"
		
		Out-File -FilePath $scriptSettingsCFG -InputObject "Optional items for the table's order: ComputerName, ComputerID, LoggedOnUsers, CurrentOwner, IPAddress, Notes, Location, OSVersion, ComputerStatus, MacAddress" -Append
		Out-File -FilePath $scriptSettingsCFG -InputObject $defaultTableOrder -Append
		Out-File -FilePath $scriptSettingsCFG -InputObject $defaultLastMode -Append
		Out-File -FilePath $scriptSettingsCFG -InputObject $defaultLastPref -Append
		Out-File -FilePath $scriptSettingsCFG -InputObject $defaultQUserEnabled -Append
		Out-File -FilePath $scriptSettingsCFG -InputObject $defaultShdConsent -Append
		Out-File -FilePath $scriptSettingsCFG -InputObject $defaultapiKey -Append
		
	}

#read settings file
$settingsFileContent = Get-Content -Path $scriptSettingsCFG


$setMode = ($settingsFileContent | Select-String "lastMode") -replace "lastMode:",""
$autoMode = ($settingsFileContent | Select-String "lastPref") -replace "lastPref:",""
$global:quserEnabled = ($settingsFileContent | Select-String "quserEnabled") -replace "quserEnabled:",""

#creates ShdConsent property if missing
$shdProperty = ((($settingsFileContent | Select-String "shdRequireConsent").LineNumber)-1)
#Write-Host "Current value of shdproperty is" $shdProperty

if ($shdProperty -eq -1) {
	$global:shadowRequireConsent = "y"
	#Write-Host "Shadowconsent should be yes and appended" -ForegroundColor Gray
	Out-File -FilePath $scriptSettingsCFG -InputObject "shdRequireConsent:y" -Append	
}
else {
	$global:shadowRequireConsent = ($settingsFileContent | Select-String "shdRequireConsent") -replace "shdRequireConsent:",""
}

#create API key property if not present
$checkAPIKey = ((($settingsFileContent | Select-String "apiKey").LineNumber)-1)
if ($checkAPIKey -eq -1) {
	$global:savedAPIKey = "none"
	#Write-Host "Shadowconsent should be yes and appended" -ForegroundColor Gray
	Out-File -FilePath $scriptSettingsCFG -InputObject "apiKey:none" -Append	
}
else {
$global:savedAPIKey = ($settingsFileContent | Select-String "apiKey") -replace "apiKey:",""
}

if ($global:savedAPIKey -ne $null) {
	
	$global:dcToken = $global:savedAPIKey

}

$global:shadowWait = "true"




#add settings validation, otherwise reset the line used







#GLOBAL VARIABLES
#$setMode = "computer" #default global variable
#$autoMode = "none"
$enterItem = "none" #default global variable

$runCommand = $false
$exportDir = $env:USERPROFILE + "\desktop"
$debugVar = $false
$forceRestart = $false

#Authentication related variables

$userAuthenticated = $false
$authInfo = $null
$userName = $null
$userPass = $null
$otpNum = $null
$uuID = $null
$retrieve2 = $null
$retrieve1 = $null
$fullJsonIn = $null




#credentials have to be passed up from the below methods
[pscredential]$shadowCreds = $null

function StartShadowMSTSC {

Param    (
         
         [Parameter(Mandatory=$true, Position=0)]
         [PSCredential] $ShdCred, 
		 [Parameter(Mandatory=$true, Position=1)]
         [string] $ShdName
    )

#temp variable that is required
#this variable actually does nothing at the moment
$noDomain = $false 






	if ($shdCred -eq $null) {
		
		$allSessions = quser /server:$ShdName

	}
	else {
	
	
	
	Start-Job -ScriptBlock {quser /server:$using:ShdName} -Name GetShdQUserData -Credential $shdCred | Out-Null
	#Get-Job
	$allSessions = Receive-Job GetShdQUserData -Wait
	#sleep 2
	Remove-Job *

	}


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

}

$activeUser = $userNames | Where-Object {$_.State -match "Active"}
$discUser = $userNames | Where-Object {$_.State -match "Disc"}

$activeTrue = $false
$warningSess = $false
$discTrue = $false



if (!($activeUser -eq $null)) {$activeTrue = $true}

if ($userNames -eq $null) {$warningSess = $true}

if (!($discUser -eq $null)) {$discTrue = $true}



<# List of username output data

Write-Host $userNames
Write-Host "active:" $activeTrue
Write-Host "warning:" $warningSess
Write-Host "disconnected:" $discTrue
#>


$SessID = $activeUser.ID
$SessUserName = $activeUser.Username        
    




				if ($activeTrue -eq $true)
				
				{
					
					
					
				
						$uName = $userNameTextBox.Text
						
						
						if ($global:shadowRequireConsent -eq "n") {$cmdArgs = "/shadow:$SessId /v:$pcName /noconsentprompt /control"}
						else {$cmdArgs = "/shadow:$SessId /v:$pcName /control"}
						
						
					   
						
						if ($noDomain -eq $true) {
							[Console.Window]::ShowWindow($consolePtr, 1)
						cls
						Write-Host "Enter the user's password"
						runas /netonly /user:$uName "mstsc.exe $cmdArgs"
						[Console.Window]::ShowWindow($consolePtr, 0)
						}
						else {
						     #implement shadow wait for user assistance
							 if ($global:shadowWait -eq "true") 
							 {
								Write-Host "Script is paused while shadowing is active." -ForegroundColor Magenta
								$shdWindow = Start-Process mstsc.exe -WorkingDirectory "C:\Windows\System32" -ArgumentList $cmdArgs -Credential $shdCred -PassThru
								$shdWindow.WaitForExit()
								$shadowerName = $shdCred.UserName
								Start-Process msg.exe -WorkingDirectory "C:\Windows\System32" -ArgumentList "$SessID /server:$pcName /TIME:15 Remote Desktop Shadowing by $shadowerName has ended." -Credential $shdCred
							 }
							 
							 else 
							 {Start-Process mstsc.exe -WorkingDirectory "C:\Windows\System32" -ArgumentList $cmdArgs -Credential $shdCred}
							 
							 
						}


				}










}


function InputRDPCredential {

$testDomain = ([ADSI]"").distinguishedName
$testUser = whoami
if ($testDomain -eq $null) {
	Write-Host "Script failed to authenticate using account $testUser."
	return
}

#testing credential block
 $shadowCredT2 = Get-Credential #Read credentials
 $username = $shadowCredT2.username
 $password = $shadowCredT2.GetNetworkCredential().password
 # Get current domain using logged-on user's credentials
 $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
 $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)


if ($domain.name -eq $null)
{
 write-host "Authentication failed - please verify your username and password."
 $shadowCredT2 = $null
 return #terminate the script.
}
else
{
 write-host "Successfully authenticated with domain."
}
#end credential test block




	

	
		
		#testing credential block
		
		
		
		#end credential test block
		
		
		
	
	
	
return $shadowCredT2

}


#used for the custom print server data search
#this could be improved!
function PrinterSearch {
    
    Write-Host "Query returned from server $localPrintServer"
    $networkPrinters = (Get-Printer -ComputerName $localPrintServer) | Where-Object {$_.Shared -like $true}
    #$networkPrinters
    if ($enterItem -eq "") {
            Write-Host "No search query was provided!" -ForegroundColor Gray
            return
    }
    if ($enterItem -eq "all") {
        Write-Host "Returning output of all printers..." -ForegroundColor Gray
		sleep 3
        $networkPrinters
		
		if (($autoMode -like "inv") -OR ($autoMode -like "patch") -OR ($autoMode -like "config"))
		{
			
# function to save you from opening a LOT of URLs
		Write-Host "Open all printer URLs in browser? (y/n)" -ForegroundColor Yellow
		$inputOpenAll = Read-Host
		if (($inputOpenAll -eq "y") -OR ($inputOpenAll -eq "yes")) {}
		else {return}

#
			
			$networkPrinters | foreach {
				$printPortName = get-Printer -ComputerName $localPrintServer -Name $_.Name
				$printPortIP = (Get-PrinterPort -ComputerName mimas -Name $printPortName.PortName).PrinterHostAddress
				start "http://$printPortIP"
				#Write-Host $printPortIP -ForegroundColor Magenta
			}
			
		}
		
        return
    }


    $usefulPrinterData = ($networkPrinters | Where-Object {$_.Name -like "*$enterItem*"})
    #$usefulPrinterData
    $usefulPrinterData | fl
	
			if (($autoMode -like "inv") -OR ($autoMode -like "patch") -OR ($autoMode -like "config"))
		{
			
			$usefulPrinterData | foreach {
				$printPortName = get-Printer -ComputerName $localPrintServer -Name $_.Name
				$printPortIP = (Get-PrinterPort -ComputerName mimas -Name $printPortName.PortName).PrinterHostAddress
				start "http://$printPortIP"
				#Write-Host $printPortIP -ForegroundColor Magenta
			}
			
		}
    <#
    Working Code with odd behavior, turned off for now.
    $usefulPrinterData | select Name, @{N='IPAddress'; E={(Get-PrinterPort -ComputerName $localPrintServer -Name $_.PortName).PrinterHostAddress}}, Location, Comment
    #>
 
 



    

}

#used for opening the DC computer management functionality URLs like command prompt
function OpenDCManageLink {
	
	Param    (
         
         [Parameter(Mandatory=$true, Position=0)]
         [string] $ResourceID
    )
	
	Write-Host "Sub-Items: taskmgr, services, cmd, registry, fileman, eventvwr, " -ForegroundColor Gray
	Write-Host "devmgr, netshares, printers, groups, software, users" -ForegroundColor Gray
	$selectSubItem = Read-Host -Prompt "Select a management option:"
	$noMatches = $true
	
		if ($selectSubItem -like "taskmgr") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/task-manager"
			$noMatches = $false
		}
		if ($selectSubItem -like "services") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/services"
			$noMatches = $false
		}
		if ($selectSubItem -like "cmd") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/command-prompt"
			$noMatches = $false
		}
		if ($selectSubItem -like "registry") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/registry"
			$noMatches = $false
		}
		if ($selectSubItem -like "fileman") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/file-manager"
			$noMatches = $false
		}
		if ($selectSubItem -like "eventvwr") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/event-viewer"
			$noMatches = $false
		}
		if ($selectSubItem -like "devmgr") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/device-manager"
			$noMatches = $false
		}
		if ($selectSubItem -like "netshares") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/shares"
			$noMatches = $false
		}
		if ($selectSubItem -like "printers") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/printers"
			$noMatches = $false
		}
		if ($selectSubItem -like "groups") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/groups"
			$noMatches = $false
		}
		if ($selectSubItem -like "software") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/software"
			$noMatches = $false
		}
		if ($selectSubItem -like "users") {
			start "https://$dcServerName`:$dcServerPort/webclient#/uems/tools/system-manager/$pcID/users"
			$noMatches = $false
		}
		
		if ($noMatches) {
		Write-Host "Canceling DCManage function"
		return
		}
	
	
}

#used for automatic link opening
function OpenDCIDLink {
	
	Param    (
         
         [Parameter(Mandatory=$true, Position=0)]
         [string] $DCtempID,
		 [Parameter(Mandatory=$true, Position=1)]
         [string] $DCtempName
    )
	
	
	
	if ($autoMode -like "inv") {start "https://$dcServerName`:$dcServerPort/webclient#/uems/inventory/computers/$DCtempID/summary"}
	if ($automode -like "patch") {start "https://$dcServerName`:$dcServerPort/webclient#/uems/patch-mgmt/systems/$DCtempID/system-summary"}
	if ($autoMode -like "config") {start "https://$dcServerName`:$dcServerPort/webclient#/uems/reports/configuration/reports/8113/computer-details/$DCtempID`?resourceName=$pcName"}
                
	
	
}


#returns two custom table outputs, can also export a CSV if the "export" flag is enabled
function ShowDataTable {

Param    (
         
         [Parameter(Mandatory=$true, Position=0)]
         [Object[]] $inputTableOut
    )
	
	
#Rewrites the columns to use new names. Utilizes calculated properties. 
    $rewrittenTable = $inputTableOut | select @{N='ComputerName'; E={$_.resource_name}}, @{N='LoggedOnUsers'; E={$_.agent_logged_on_users}}, `
             @{N='CurrentOwner'; E={$_.owner}},`
              @{N='IPAddress'; E={$_.ip_address}}, @{N='Notes'; E={$_.description}}, @{N='ComputerLocation'; E={$_.location}}, `
               @{N='OSVersion'; E={$_.service_pack}}, @{N='ComputerStatus'; E={$_.computer_live_status}}, @{N='ComputerID'; E={$_.resource_id}}, `
				@{N='MacAddress'; E={$_.mac_address}}




#reads latest data for table sort
$currentSettings = Get-Content -Path $scriptSettingsCFG
$setOrder = ($currentSettings | Select-String "tableOrder") -replace "tableOrder:",""
	
#splits the list from the settings
$newOrder = $setOrder -split ", "
$statusColor = @{
						 Label = "ComputerStatus"
						 Expression =
						 {
							$colorChanged = $false
							if ("Offline" -eq $_.ComputerStatus)
							 {
									$color = "31" #green
									$colorChanged = $true
							 }
							if ("Online" -eq $_.ComputerStatus)
							  {
									$color = "32" #green
									$colorChanged = $true
							  }
							if (!($colorChanged))
							 {
									$color = "0" #white
							 }
							$e = [char]27
							"$e[${color}m$($_.ComputerStatus)${e}[0m"
						 }
					 }
#get the line number of ComputerStatus
$computerStatusNum = (($newOrder | Select-String "ComputerStatus").LineNumber)

#replaces the existing text ComputerStatus if it exists with a calculated property
$colorList = @()
$num = 1
$newOrder | foreach {
if ($num -eq $computerStatusNum) {$colorList += $statusColor}
else {$colorList += $_}

$num++
}



	#table with no calculated properties
	$noColorTable = $rewrittenTable | select $newOrder



	#display table with colored ComputerStatus
	$rewrittenTable | Format-Table $colorList
					
    
    

#export code if enabled via a flag
    if ($autoMode -eq "export") {
        
		
        if (!(Test-Path -Path $exportDir)) {Write-Host "A folder named Desktop does not exist in your user folder!" -ForegroundColor Red}

        $date1 = get-date -UFormat "%m%d%Y_%R%S"
        $date2 = $date1.replace(":","")
        $expPath = $exportDir + "\DCLookup_Export_$date2.csv"

        
		$noColorTable | Export-CSV -Path $expPath -NoTypeInformation
        Write-Host "Exported a CSV file to $expPath"
		Write-Host
    }
    


    

}

#shows the help dialog
function ShowHelp {
Write-Host "Computer Commands: 'computer'" -ForegroundColor Gray
Write-Host "User Commands: 'fulluser' 'username'" -ForegroundColor Gray
Write-Host "Data Commands: 'ip' 'notes' 'osver'" -ForegroundColor Gray
Write-Host "Automatic Preference (only one can be enabled): 'autopref' 'managepref' 'shadowpref' 'rdppref'" -ForegroundColor Gray
Write-Host "Toggles (multiple can be enabled): 'quser' 'shadowconsent'" -ForegroundColor Gray
Write-Host "Other Commands: 'apikey' 'settings' 'exit' 'help' 'login' 'printer' 'cls'" -ForegroundColor Gray
}

function QueryUserData {
	
		Param    (
         
         [Parameter(Mandatory=$true, Position=0)]
         [string] $QueryServer
		 
    )
	
	#lots of code for doing a quser lookup. 
	
	
	
	if ($shadowCreds -eq $null) {
		
		quser.exe /server:$QueryServer
		
	}
	else {
	
	
	
	Start-Job -ScriptBlock {quser /server:$using:QueryServer} -Name GetQUserData -Credential $shadowCreds | Out-Null
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
			
			#scriptblock code Get-Process -Name "logonui" -ComputerName $using:QueryServer -ErrorAction SilentlyContinue
			
        Start-Job -ScriptBlock {Get-Process -Name "logonui" -ComputerName $using:QueryServer -ErrorAction SilentlyContinue} -Name GetLogonUI -Credential $shadowCreds | Out-Null
        #Get-Job
        $logonUIData = Receive-Job GetLogonUI -Wait
        #sleep 2
        Remove-Job *
        #get total processes of LogonUI.exe, one is used for each session that a lock screen is present on
		
		$totalProcesses = $logonUIData.ProcessName
		$logonUICount = $totalProcesses.Count
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
	ComputerName = $QueryServer
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
	

	
	
	
	
	
	
	}
	
	
}



#runs the query to the desktop central server
function StartQuery {



$fullURI = "https://$dcServerName`:$dcServerPort/api/1.4/som/computers?pagelimit=300"
$servicePoint3 = [System.Net.ServicePointManager]::FindServicePoint($fullURI)
    $urlSOM = @{
   
   
        ContentType = 'application/json'
        URI = $fullURI
        Method = 'GET'
       Headers = @{'Authorization'=$global:dcToken
      ; "Accept"= "application/json"}
    }
    
    $jsonContent = $null
    $global:fullJsonIn = $null
    
          
    $jsonContent = Invoke-WebRequest @urlSOM -UseBasicParsing
	
	if ($global:debugVar) {Write-Host $jsonContent}

    $jsonResponse = ($jsonContent.Content | ConvertFrom-Json)
			

	$errorCheck = $jsonResponse -like "*10002*"
	if ($errorCheck -eq $true) {$global:forceRestart = $true}
	
    $almostJson = $jsonResponse.message_response
    $global:fullJsonIn = $almostJson.computers

    $servicePoint3.CloseConnectionGroup($fullURI)


    }

#runs short functions related to modes/preferences
function SetDCMode {

Param    (
         
         [Parameter(Mandatory=$true, Position=0)]
         [string] $currentLinkMode
    )


    if (($currentLinkMode -eq "username") -OR ($currentLinkMode -eq "fulluser")) {Write-Host "Enter a username or command"}
    else {Write-Host "Enter a computer name or command"}
    $usedCommand = $false
    $autoPref = $autoMode
	$autoChanged = $false
    
    $userInput = Read-Host
    

    if ($userInput -eq "exit") {
        Write-Host "Exiting Program" -ForegroundColor Yellow
        exit
    }

    if ($userInput -eq "cls") {
        cls
        $usedCommand = $true
    }

    <#if (($userInput -eq "patch") -OR ($userInput -eq "!p")) {
        $usedCommand = $true
         $currentLinkMode = "patch"
    }
	#>
    if (($userInput -eq "computer") -OR ($userInput -eq "!c")) {
        $usedCommand = $true
         $currentLinkMode = "computer"
    }
    if (($userInput -eq "osver") -OR ($userInput -eq "!o")) {
        $usedCommand = $true
         $currentLinkMode = "osver"
    }
    <#if (($userInput -eq "config") -OR ($userInput -eq "configuration") -OR ($userInput -eq "!c")) {
        $usedCommand = $true
         $currentLinkMode = "configuration"
    }
	#>
	
	
    if (($userInput -eq "username") -OR ($userInput -eq "!u")) {
        $usedCommand = $true
         $currentLinkMode = "username"
    }
    if (($userInput -eq "fulluser") -OR ($userInput -eq "!f")) {
        $usedCommand = $true
         $currentLinkMode = "fulluser"
    }
    if (($userInput -eq "quser") -OR ($userInput -eq "!q")) {
        $usedCommand = $true
         
		 
		if ($global:quserEnabled -eq "y") {
        $global:quserEnabled = "n"
        Write-Host "quser disabled." -ForegroundColor Gray
        }
        else {
        $global:quserEnabled = "y"
        Write-Host "quser enabled." -ForegroundColor Gray
        }

        #Write-Host "value of quser is $global:quserEnabled"
        
		 
		 
		 
    }
    if (($userInput -eq "printer")  -OR ($userInput -eq "!p")) {
        $usedCommand = $true
         $currentLinkMode = "printer"
    }
    
	#<#
	if (($userInput -eq "restart")) {
        	#invoke TwoFactorLogin outside function
			$global:forceRestart = $true
			$usedCommand = $true
			Write-Host "Restarting Script..."
			sleep 2
			cls
    }
#>
	
	
	<# no longer needed as it is part of shadowing #>
	if (($userInput -eq "login") -OR ($userInput -eq "!l")) {
        $usedCommand = $true
         $shadowCredT1 = InputRDPCredential

         
    }
	
	
		if ($userInput -eq "debug") {
        $usedCommand = $true
        
        if ($global:debugVar -eq $true) {
        $global:debugVar = $false
        
        }
        else {
        $global:debugVar = $true
        
        }

        Write-Host "Debug value is currently $global:debugVar" -ForegroundColor Gray
    
    }
	
	
	
	if ($userInput -eq "shadowconsent") {
        $usedCommand = $true
        
        if ($global:shadowRequireConsent -eq "y") {
        $global:shadowRequireConsent = "n"
        Write-Host "ShadowConsent requirement disabled." -ForegroundColor Gray
        }
        else {
        $global:shadowRequireConsent = "y"
        Write-Host "ShadowConsent requirement enabled." -ForegroundColor Gray
        }

        
    
    }
	
	
	if (($userInput -eq "apikey") -OR ($userInput -eq "api")) {
        $usedCommand = $true
        #Add API storage function
		Write-Host "Choose an API key option: " -ForegroundColor Cyan
		Write-Host "view, clear, save, cancel" -ForegroundColor Cyan
		$shortOption = Read-Host
		$noMatches = $true
		
		if (($shortOption -eq "view") -OR ($shortOption -eq "v")) {
			Write-Host "Config file API key: "$global:savedAPIKey
			Write-Host "API key in memory: "$global:dcToken
			$noMatches = $false
			}
		if (($shortOption -eq "clear") -OR ($shortOption -eq "c")) {
			$global:savedAPIKey = "none"
			Write-Host "API key cleared" -ForegroundColor Gray
			$noMatches = $false
		}
		if (($shortOption -eq "save") -OR ($shortOption -eq "s")) {
			$global:savedAPIKey = $global:dcToken
			Write-Host "Current API key saved" -ForegroundColor Gray
			$noMatches = $false
		}		
		
		

		if ($noMatches) {
		Write-Host "Canceling apikey function"
		#return
		}
        
    
    }	
	
	

	
	

    if (($userInput -eq "rdppref") -OR ($userInput -eq "!r")) {
        $usedCommand = $true
        
        if ($autoPref -eq "rdppref") {
        $autoPref = "none"
        
        }
        else {
        $autoPref = "rdppref"
        
        }

        
        $autoChanged = $true
    }


    if (($userInput -eq "export") -OR ($userInput -eq "!e")) {
        $usedCommand = $true
        
        if ($autoPref -eq "export") {
        $autoPref = "none"
        
        }
        else {
        $autoPref = "export"
        
        }

        
        $autoChanged = $true
    }



    if (($userInput -eq "managepref") -OR ($userInput -eq "!m")) {
        $usedCommand = $true
        
        if ($autoPref -eq "managepref") {
        $autoPref = "none"
        
        }
        else {
        $autoPref = "managepref"
        
        }

        $autoChanged = $true
    }

    if (($userInput -eq "shadowpref") -OR ($userInput -eq "!s")) {
        $usedCommand = $true
        
        if ($autoPref -eq "shadowpref") {
        $autoPref = "none"
        
        }
        else {
		
		<#
		Write-Host "Log in to an AD account? (y/n)" -ForegroundColor Yellow
		$currentUser = $ShadowCredT1.UserName
		if (($currentUser -eq $null) -OR ($currentUser -eq "none")) {
			$currentUser = "none"
		}
		Write-Host "Current account is $currentUser" -ForegroundColor Yellow
		$inputCredChoice = Read-Host
		if (($inputCredChoice -eq "y") -OR ($inputCredChoice -eq "yes")) {$shadowCredT1 = InputRDPCredential}
        #>
		
		$autoPref = "shadowpref"
		Write-Host "This will prompt for a connection!" -ForegroundColor Yellow
		Write-Host "Make sure to log in with admin credentials using the LOGIN command!" -ForegroundColor Yellow
        
        }

        $autoChanged = $true
         
    }
if (($userInput -eq "location")) {
        $usedCommand = $true
         $currentLinkMode = "location"
    }
    if (($userInput -eq "notes") -OR ($userInput -eq "!n")) {
        $usedCommand = $true
         $currentLinkMode = "notes"
    }
    if (($userInput -eq "ip")) {
        $usedCommand = $true
         $currentLinkMode = "ip"
    }
	
	if (($userInput -eq "settings")) {
        $usedCommand = $true
        start $scriptSettingsCFG
    }

    if (($userInput -eq "help") -OR ($userInput -eq "!h") -OR ($userInput -eq "/?")) {
        $usedCommand = $true
        ShowHelp
    }
    if (($userInput -eq "autopref") -OR ($userInput -eq "!a")) {
        $usedCommand = $true
        
		Write-Host "Enter a preference for links to open:" -ForegroundColor Yellow
		Write-Host "'inv' 'patch' 'config' 'none' (none will disable this feature)" -ForegroundColor Yellow
		
		$tempPref = Read-Host
		
		#basic input validation
		if (($tempPref -eq "inv") -OR ($tempPref -eq "patch") -OR ($tempPref -eq "config")) {
        $autoPref = $tempPref
        
        }
        else {
			Write-Host "Either 'none' was entered, or no input was provided" -ForegroundColor Gray
			#if (($autoPref -eq "inv") -OR ($autoPref -eq "patch") -OR ($autoPref -eq "config")) {$autoPref = "none"}
			
			
			
			
        $autoPref = "none"
        
        }

        $autoChanged = $true

    }

    if ($shadowCredT1 -eq $null) {
        $shadowCreds = $shadowCreds
    }
    else {
        $shadowCreds = $shadowCredT1
    }


	if ($autoChanged -eq $true) {Write-Host "Secondary preference is now $autoPref" -ForegroundColor Gray}
	




    return $currentLinkMode, $userInput, $usedCommand, $autoPref, $shadowCreds

    }

#searches computer inventory by computer name
function ComputerSearch {

Param    (
         
         [Parameter(Mandatory=$true, Position=0)]
         [Object[]] $inputTablePC
    )

    if ($enterItem -eq "") {
        Write-Host "No search query was provided!" -ForegroundColor Gray
        return
    }



    
    
    
        $selectedPC = $inputTablePC | Where-Object {$_.resource_name -like "*$enterItem*"}
        if ($enterItem -eq "all") {
            $selectedPC = $inputTablePC
        }    
    
        if ((($selectedPC | Measure-Object).Count) -eq 0) {
            Write-Host "No devices found with query: $enterItem" -ForegroundColor Yellow
        }
        else {
        

            #$selectedPC = $inputTablePC | Where-Object {$_.resource_name -eq $enterItem}
            ShowDataTable -inputTableOut $selectedPC
			$allowSelect = $true
			if (($autoMode -eq "none") -OR ($autoMode -eq "export")) {$allowSelect = $false} 
            #$selectedPC

             
			 
			 #script block to select one PC if an Automode is on.
			 if (($allowSelect) -AND ((($selectedPC | Measure-Object).Count) -gt 1)) {
				 
				 
				 Write-Host "A secondary preference is on, please enter a PC name from above by typing it:" -ForegroundColor Yellow
				 
				 $userChoice = Read-Host
				 
				 
				 $tempChoice = $selectedPC | Where-Object {$_.resource_name -like "*$userChoice*"}
				 if (!($tempChoice -eq $null)) {
					 
					 $selectedPC = $tempChoice
					 
				 }
				 if ($userChoice -eq $null) {Write-Host "Blank text, canceling action..." -ForegroundColor Yellow}
			
			 }
			 
			 
			 
			 

            if ((($selectedPC | Measure-Object).Count) -eq 1) {
                $pcID = ($selectedPC | Where-Object {$_.resource_name -like "*$enterItem*"}).resource_id
				$pcName = $selectedPC.resource_name
                
                
                #if the amount of computers is one, prompt for opening the URL (which is disabled rn)
				
				if (!($autoMode -eq "none")) {
                #Write-Host "Running before shadow"
				
				if ($autoMode -eq "shadowpref") {
					
					if ($shadowCreds -eq $null) {Write-Host "login command was not specified, please run that first." -ForegroundColor Yellow}
					else {
						#Write-Host "Running Shadowing things"
					StartShadowMSTSC -ShdCred $shadowCreds -ShdName $pcName
					}
					
				}
				
				if ($autoMode -eq "rdppref") {
					$command = "mstsc /v:$pcName"
					iex "& $command"
				}
				
				if ($autoMode -eq "managepref") {
					Write-Host "Opening management selection..." -ForegroundColor Cyan
					
					OpenDCManageLink -ResourceID $pcID
				}
				
				if (($autoMode -like "inv") -OR ($autoMode -like "patch") -OR ($autoMode -like "config")) {OpenDCIDLink -DCtempID $pcID -DCtempName $PCName}
               
                
}
        
            }
        else { 
        #amount of computers is more than 1, do not initiate a search
			if ((!($autoMode -eq "none")) -AND (($tempChoice -eq $null)) -AND ($enableSelect)) {
				
				Write-Host "Computer name $userChoice matched more than one time!" -ForegroundColor Yellow
				
			}
		
        } 
        
        }

		if ($enterItem -ne "all") {
			$selectedPC | foreach {

				$pcTempName = $_.resource_name
				

				$connectTest = Test-Connection $pcTempName -count 1 -ErrorAction SilentlyContinue
				if ($connectTest -ne $null) {
					
					
					if (($pcTempName -notlike "*LP-*") -AND ($global:quserEnabled -eq "y")) {
						QueryUserData -QueryServer $pcTempName
					}
					
					#$userAns = Read-Host -Prompt "Open this computer's details page? (y/n)"
					
				}
			}
		}

        if ($enterItem -eq "all") {
        Write-Host "All computers returned in output" -ForegroundColor Gray
    }

        
    


}


#searches computer inventory by notes, IP, OS, and location info
function DataSearch {

Param    (
         
         [Parameter(Mandatory=$true, Position=0)]
         [Object[]] $inputTableData
    )

    if ($enterItem -eq "") {
        Write-Host "No search query was provided!" -ForegroundColor Gray
        return
    }

    
    if ($setMode -like "notes") {
        $selectedPC = $inputTableData | Where-Object {$_.description -like "*$enterItem*"}
    }
	if ($setMode -like "location") {
        $selectedPC = $inputTableData | Where-Object {$_.location -like "*$enterItem*"}
    }
    if ($setMode -like "ip") {
        $selectedPC = $inputTableData | Where-Object {$_.ip_address -like "*$enterItem*"}
    }
    if ($setMode -like "osver") {
        $selectedPC = $inputTableData | Where-Object {$_.service_pack -like "*$enterItem*"}
    }

    
    
    
        
        if ($enterItem -eq "all") {
            $selectedPC = $inputTableData
        }    
    
        if ((($selectedPC | Measure-Object).Count) -eq 0) {
            Write-Host "No devices found with query: $enterItem" -ForegroundColor Yellow
        }
        else {
        

            #$selectedPC = $inputTablePC | Where-Object {$_.resource_name -eq $enterItem}
            ShowDataTable -inputTableOut $selectedPC
			$allowSelect = $true
			if (($autoMode -eq "none") -OR ($autoMode -eq "export")) {$allowSelect = $false} 

			#script block to select one PC if an Automode is on.

             if (($allowSelect) -AND ((($selectedPC | Measure-Object).Count) -gt 1)) {
				 
				 Write-Host "A secondary preference is on, please enter a PC name from above by typing it:" -ForegroundColor Yellow
				 $userChoice = Read-Host
				 
				 $tempChoice = $selectedPC | Where-Object {$_.resource_name -like "*$userChoice*"}
				 if (!($tempChoice -eq $null)) {
					 
					 $selectedPC = $tempChoice
					 $enterItem = $userChoice
					 
				 }
				 if ($userChoice -eq $null) {Write-Host "Blank text, canceling action..." -ForegroundColor Yellow}
			
			 }
			 
			 
			 

            if ((($selectedPC | Measure-Object).Count) -eq 1) {
				
				$pcTempName = $selectedPC.resource_name
                $pcID = $selectedPC.resource_id
				
                $pcName = $selectedPC.resource_name
                
                #if the amount of computers is one, prompt for opening the URL (which is disabled rn)
                


                if (!($autoMode -eq "none")) {
                #Write-Host "Running before shadow"
				
				if ($autoMode -eq "shadowpref") {
					
					if ($shadowCreds -eq $null) {Write-Host "login command was not specified, please run that first." -ForegroundColor Yellow}
					else {
						#Write-Host "Running Shadowing things"
					StartShadowMSTSC -ShdCred $shadowCreds -ShdName $pcName
					}
					
				}
				
				if ($autoMode -eq "rdppref") {
					$command = "mstsc /v:$pcName"
					iex "& $command"
				}
				
				if ($autoMode -eq "managepref") {
					Write-Host "Opening management selection..." -ForegroundColor Cyan
					
					OpenDCManageLink -ResourceID $pcID
				}
				
				if (($autoMode -like "inv") -OR ($autoMode -like "patch") -OR ($autoMode -like "config")) {OpenDCIDLink -DCtempID $pcID -DCtempName $PCName}
                #$selectedPC | ft
				#Write-Host "Resource ID is $pcID" -ForegroundColor Cyan
}
           
            }
        else { 
        #amount of computers is more than 1, do not initiate a search
			if ((!($autoMode -eq "none")) -AND (($tempChoice -eq $null)) -AND ($enableSelect)) {
				
				Write-Host "Computer name $userChoice matched more than one time!" -ForegroundColor Yellow
				
			}
        } 
        
        }

        if ($enterItem -eq "all") {
        Write-Host "All computers returned in output" -ForegroundColor Gray
    }

        
    


}

#searches computer inventory by username/fullname
function UserSearch {

Param    (
         
         [Parameter(Mandatory=$true, Position=0)]
         [Object[]] $inputTableUser
    )
    
    if ($enterItem -eq "") {
        Write-Host "No search query was provided!" -ForegroundColor Gray
        return
    }

    if ($setMode -like "fulluser") {
        $selectedUser = $inputTableUser | Where-Object {$_.owner -like "*$enterItem*"}
    }
    if ($setMode -like "username") {
        $selectedUser = $inputTableUser | Where-Object {$_.agent_logged_on_users -like "*$enterItem*"}
    }
    if ($enterItem -eq "all") {
        $selectedUser = $inputTableUser
    }



#check if search has results
if ((($selectedUser | Measure-Object).Count) -ge 1) {

	if (!((($selectedUser | Measure-Object).Count) -eq 1)) {
		#legacy code for filtering pc names
		#$selectedUser = $selectedUser | ? {$_.resource_name -ne "laptop"}
		#$activeUser = $userNames | Where-Object {$_.State -match "Active"}
	}


			ShowDataTable -inputTableOut $selectedUser
			$allowSelect = $true
			if (($autoMode -eq "none") -OR ($autoMode -eq "export")) {$allowSelect = $false} 


	#script block to select one PC if an Automode is on.

             if (($allowSelect) -AND ((($selectedUser | Measure-Object).Count) -gt 1)) {
				 
				 Write-Host "A secondary preference is on, please enter a PC name from above by typing it:" -ForegroundColor Yellow
				 $userChoice = Read-Host
				 
				 $tempChoice = $selectedUser | Where-Object {$_.resource_name -like "*$userChoice*"}
				 if (!($tempChoice -eq $null)) {
					 
					 $selectedUser = $tempChoice
					 $enterItem = $userChoice
					 
				 }
				 if ($userChoice -eq $null) {Write-Host "Blank text, canceling action..." -ForegroundColor Yellow}
			
			 }

		if ($enterItem -ne "all") {
			$selectedUser | foreach {

				$pcTempName = $_.resource_name
				

				$connectTest = Test-Connection $pcTempName -count 1 -ErrorAction SilentlyContinue
				if ($connectTest -ne $null) {
					
					
					if (($pcTempName -notlike "*LP-*") -AND ($global:quserEnabled -eq "y")) {
						QueryUserData -QueryServer $pcTempName
					}
					
					#$userAns = Read-Host -Prompt "Open this computer's details page? (y/n)"
					
				}
			}
		}
		



	if ((($selectedUser | Measure-Object).Count) -eq 1) {


		
		
		
		
		
		
		
		if (!($autoMode -eq "none")) {
				$pcID = $selectedUser.resource_id
				$pcName = $selectedUser.resource_name
                #Write-Host "Running before shadow"
				
				if ($autoMode -eq "shadowpref") {
					
					if ($shadowCreds -eq $null) {Write-Host "login command was not specified, please run that first." -ForegroundColor Yellow}
					else {
						#Write-Host "Running Shadowing things"
					StartShadowMSTSC -ShdCred $shadowCreds -ShdName $pcName
					}
					
				}
				
				if ($autoMode -eq "rdppref") {
					$command = "mstsc /v:$pcName"
					iex "& $command"
				}
				
				if ($autoMode -eq "managepref") {
					Write-Host "Opening management selection..." -ForegroundColor Cyan
					
					OpenDCManageLink -ResourceID $pcID
				}
				
				if (($autoMode -like "inv") -OR ($autoMode -like "patch") -OR ($autoMode -like "config")) {OpenDCIDLink -DCtempID $pcID -DCtempName $PCName}
                
}

		else {
			
				if (($allowSelect) -AND ((($selectedPC | Measure-Object).Count) -gt 1)) {
				
				Write-Host "Computer name $userChoice matched more than one time!" -ForegroundColor Yellow
				
			}
			
		}
		
		
		
		
		
		
		
		
		
		
	}

if ($enterItem -eq "all") {
        Write-Host "All users returned in output" -ForegroundColor Gray
    }

}
else {
    Write-Host "No devices found with query: $enterItem" -ForegroundColor Yellow
}

}

#code for calling 2fa methods, manages user input validation
function TwoFactorLogin {
TestAPIKeyValidity | Out-Null

$authInfo = $global:retrieve3
$foundError = $false
$foundError = ($authInfo.Content | ConvertFrom-Json) -like "*10002*"
#Write-Host "value of dctoken is"$global:dcToken

#Write-Host "api key value is null?"
#($global:dcToken -eq $null)
#Write-Host "api returned error?"
#($foundError -eq $true)

	if (($global:dcToken -eq $null) -OR ($foundError -eq $true)) {
		#Write-Host "Please log in" -ForegroundColor Gray
		#api key probably invalid or expired
	}
	else {
		$global:userLoggedIn = $true
		Write-Host "Stored API key is valid, logging in..."
	}



    while ($global:userLoggedIn -eq $false) {

        
        while ($userAuthenticated -eq $false) {
        
        
            LoginDCSystem
            $global:retrieve1 = $null
            GetDCOTPKey | Out-Null
            $authInfo = $global:retrieve1

            $jsonResponse1 = ($authInfo.Content | ConvertFrom-Json)
			
            $foundError = $jsonResponse1 -like "*10001*"

            if (!($foundError)) {
                    $jsonResponse2 = $jsonResponse1.message_response
                    $jsonResponse3 = $jsonResponse2.authentication
                    $jsonResponse4 = $jsonResponse3.two_factor_data
            

                    $global:uuID = $jsonResponse4.unique_userID
				
                    if ($global:uuID -ne $null) {
        
                        $userAuthenticated = $true
                        
                        Write-Host "Successfully received OTP challenge data" -ForegroundColor Green
        
                    }
            }
            else {
                Write-Host "Your user account was either locked out or your password is invalid." -ForegroundColor Red
            }


        }


        Write-Host "Enter your OTP Key from your authenticator app:"
        $global:OTPNum = Read-Host
        $global:retrieve2 = $null
        SubmitOTPChallenge | Out-Null
        $otpInfo = $global:retrieve2
        





        $jsonResponse1 = ($otpInfo.Content)
        $jsonResponse2 = $jsonResponse1 | ConvertFrom-Json
        $jsonResponse3 = $jsonResponse2.message_response
        $jsonResponse4 = $jsonResponse3.authentication
        $jsonResponse5 = $jsonResponse4.auth_data
        $authKey = $jsonResponse5.auth_token

        if ($authKey.length -ge 3) {
        
                $global:userLoggedIn = $true
                $global:authKey
                Write-Host "Successfully authenticated OTP" -ForegroundColor Green
                $global:dcToken = $authKey
                Write-Host "Completed authentication." -ForegroundColor Green 
            }
            else {
                $userAuthenticated = $false
                Write-Host "OTP Authentication failed, please start over." -ForegroundColor Red

                Write-Host
                Write-Host
            }

    }


}


#gets credentials to encode for DC API
function LoginDCSystem {
	
	
	
	
$validUserName = $false
$validPassword = $false
Write-Host "Please log into DC."

while ((!($validUserName)) -OR (!($validPassword))) {

$validUserName = $false
$validPassword = $false

    
    Write-Host
    Write-Host "Enter your Username" -ForegroundColor Yellow
    $global:userName = Read-Host
    if ($global:userName.Length -ge 2) {

    $validUserName = $true
    

    Write-Host "Enter your password" -ForegroundColor Yellow
    $secString = Read-Host -AsSecureString 

    $textPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secString))

    $global:userPass = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($textPass))

    if ($global:userPass.Length -ge 2) {
        $validPassword = $true
        
    }

    }
if ((!($validUserName)) -OR (!($validPassword))) {Write-Host "A username or password was left blank or too short!" -ForegroundColor Cyan}

}

}


#gets OTP response challenge from DC
function GetDCOTPKey {

$authURIOne = "https://$dcServerName`:$dcServerPort/api/1.4/desktop/authentication"
$servicePoint1 = [System.Net.ServicePointManager]::FindServicePoint($authURIOne)

    $urlAuth1 = @{

		Body = "{ 
			'username': '$global:userName',
			'password': '$global:userPass',
			'auth_type': 'ad_authentication',
			'domainName': '$global:userDom'
		}"
        ContentType = 'application/json'
        URI = $authURIOne
        Method = 'POST'
       Headers = @{"Accept"= "application/json"}
    }
    
    $global:retrieve1 = Invoke-WebRequest @urlAuth1 -UseBasicParsing

    # | Out-Null


    #cleans the username and encoded password global variables
    $global:userPass = $null
    $global:userName = $null
    $servicePoint1.CloseConnectionGroup($authURIOne)

}


#sends OTP key to DC, receives API user info from DC
function SubmitOTPChallenge {

$authURITwo = "https://$dcServerName`:$dcServerPort/api/1.4/desktop/authentication/otpValidate?uid=$global:uuid&otp=$global:otpNum&rememberme_enabled=true"
$servicePoint2 = [System.Net.ServicePointManager]::FindServicePoint($authURITwo)

    $urlAuth2 = @{
   
   
		Body = "{ 
			'uid': '$global:uuid',
			'otp': '$global:otpNum',
			'rememberme_enabled': 'true'
		}"
		
        WebSession = $retrieve2
        ContentType = 'application/json; charset=utf-8'
        URI = $authURITwo
        Method = 'POST'
       Headers = @{"Accept"= "application/json"
       }
    }


    $global:retrieve2 = Invoke-WebRequest @urlAuth2 -UseBasicParsing



    #cleans the uuid and otpNum global variables
    $global:uuid = $null
    $global:otpNum = $null
    $servicePoint2.CloseConnectionGroup($authURITwo)
   

}

function TestAPIKeyValidity {



$fullURI = "https://$dcServerName`:$dcServerPort/api/1.4/som/computers?pagelimit=1"
$servicePoint4 = [System.Net.ServicePointManager]::FindServicePoint($fullURI)
    $urlSOM = @{
   
   
        ContentType = 'application/json'
        URI = $fullURI
        Method = 'GET'
       Headers = @{'Authorization'=$global:dcToken
      ; "Accept"= "application/json"}
    }
   
    $global:retrieve3 = Invoke-WebRequest @urlSOM -UseBasicParsing



    $servicePoint4.CloseConnectionGroup($fullURI)


    }





while ($true) {


$global:forceRestart = $false


TwoFactorLogin

sleep 2
cls

ShowHelp



#$setMode, $enterItem, $runCommand
Write-Host "Secondary preference is currently $autoMode" -ForegroundColor Yellow

while ($global:forceRestart -eq $false) { #START OF WHILE TRUE LOOP

Write-Host $setMode.toUpper() -ForegroundColor Green

# NOTE: DO NOT RETURN VARIABLES WITHOUT WRITE HOST IN THE FUNCTION BELOW
# this problem could be resolved with global variables!
$setMode, $enterItem, $runCommand, $autoMode, $shadowCreds = SetDCMode -currentLinkMode $setMode


#Write to file for setMode and autoMode config settings
$settingsFileContent = Get-Content -Path $scriptSettingsCFG


$saveTableOrder = "tableOrder:" + $setOrder
$saveLastMode = "lastMode:" + $setMode
$saveLastPref = "lastPref:" + $autoMode
$saveQuserEnabled = "quserEnabled:" + $global:quserEnabled
$saveShdRequireConsent = "shdRequireConsent:" + $global:shadowRequireConsent
if ($global:savedAPIKey -ne $null) {$saveAPIKey = "apiKey:" + $global:savedAPIKey} 

#Write-Host "consent options"$global:quserEnabled $global:shadowRequireConsent -ForegroundColor Yellow


#do not need to save table order if it never updates
#$settingsFileContent[((($settingsFileContent | Select-String "tableOrder").LineNumber)-1)] = $saveTableOrder

$settingsFileContent[((($settingsFileContent | Select-String "lastMode").LineNumber)-1)] = $saveLastMode
$settingsFileContent[((($settingsFileContent | Select-String "lastPref").LineNumber)-1)] = $saveLastPref
$settingsFileContent[((($settingsFileContent | Select-String "quserEnabled").LineNumber)-1)] = $saveQuserEnabled
$settingsFileContent[((($settingsFileContent | Select-String "shdRequireConsent").LineNumber)-1)] = $saveShdRequireConsent
if ($global:savedAPIKey -ne $null) {$settingsFileContent[((($settingsFileContent | Select-String "apiKey").LineNumber)-1)] = $saveAPIKey} 

Out-File -FilePath $scriptSettingsCFG -InputObject $settingsFileContent
       #TAKE THIS CODE 
	   #   ($testvars | Select-String "lastpref").LineNumber

$global:savedAPIKey = $null

#Write-Host "Mode is set to: $setMode Entered item is: $enterItem Run Command is $runCommand" -ForegroundColor Cyan
#Write-Host "$runCommand" -ForegroundColor Green






if ($runCommand -eq $false) {




StartQuery | Out-Null


#$fullJsonOut
$filterAll = $global:fullJsonIn | Select owner, resource_name, resource_id, agent_logged_on_users, ip_address, description, location, service_pack, computer_live_status, mac_address


#replace computerstatus numbers with words
$filterAll | foreach {
$currentObject = $_
$tempvar = ($currentObject.computer_live_status -replace '1', "Online")
$currentObject.computer_live_status = $tempvar
$tempvar = ($currentObject.computer_live_status -replace '2', "Offline")
$currentObject.computer_live_status = $tempvar
$tempvar = ($currentObject.computer_live_status -replace '3', "Unregistered")
$currentObject.computer_live_status = $tempvar
}

#Sorts all computers alphabetically
$filterAll = $filterAll | Sort-Object -Property resource_name











    if (($setMode -like "computer")) {

    
    ComputerSearch -inputTablePC $filterAll

    
    
    }

    if (($setMode -like "fulluser") -or ($setMode -like "username")) {

    UserSearch -inputTableUser $filterAll

    

    }

    if (($setMode -like "ip") -or ($setMode -like "location") -or ($setMode -like "notes") -or ($setMode -like "osver")) {

    DataSearch -inputTableData $filterAll

   

    }

    if (($setMode -like "printer")) {
    
    PrinterSearch

    }

}

else {
	#Write-Host "Mode Changed to $setMode" -ForegroundColor Cyan 
	}



    } #END OF WHILE TRUE LOOP
    #$fullJson | Export-csv -Path "C:\temp\DCLOOKUP.csv" -NoTypeInformation
	
	
	} #end of big while true loop
	
	Write-Host "Script exited successfully"
	