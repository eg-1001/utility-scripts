#Shadow RDP Script Version Changes
#v1 - Initial version, no GUI
#v2 - Added UAC to the script to ensure admin permissions existed
#v3 - Added detection system for getting the sessionID, this uses code from a github page)
#v4 - Redesigned parts of the script to fit in a GUI
#v5 - Removed the UAC requirement to use this script (still requires admin creds on remote pc)
#v6 - Added Limited Off Domain Functionality (requires Shadow registry to be set along with PSRemoting)
#v7 - completely reworked identification system that obtains user session data (used to be code from a github page, added in my own code that already existed)

Add-Type -assembly System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()


# Hide PowerShell Console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)
cls
Write-Host "RDP Shadowing Script v7"
Write-Host "This should list out everything the script is running."
Write-Host "Edit this file to see a history of changes to this script."
Write-Host
Write-Host "Script Started..."
Write-Host
<#function ChangeConsole {
	
	if ($consoleCheck.Checked -eq $true) {
		[Console.Window]::ShowWindow($consolePtr, 0)
		$consoleCheck.Checked = $false
	}
	else {
		[Console.Window]::ShowWindow($consolePtr, 1)
		$consoleCheck.Checked = $true
	}
	
	
	
}#>


$main_form = New-Object System.Windows.Forms.Form

$main_form.Text ='Shadow MSTSC Script'

$main_form.Width = 470

$main_form.Height = 240

$iconBase64      = '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'
$iconBytes       = [Convert]::FromBase64String($iconBase64)
$stream          = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
$stream.Write($iconBytes, 0, $iconBytes.Length);
$iconImage       = [System.Drawing.Image]::FromStream($stream, $true)
$main_form.Icon       = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())


$main_form.AutoSize = $true

#userNameLabel ------------------------------------


$userNameLabel = New-Object System.Windows.Forms.Label

$userNameLabel.Text = "Enter username:"

$userNameLabel.Location  = New-Object System.Drawing.Point(10,40)

$userNameLabel.AutoSize = $true

$main_form.Controls.Add($userNameLabel)

#userNameTextBox -----------------------------------

$userNameTextBox = New-Object System.Windows.Forms.TextBox

$userNameTextBox.Text = "accu\"

$userNameTextBox.Location = New-Object System.Drawing.Point(130,40)

$userNameTextBox.Size = New-Object System.Drawing.Size(140,23)

$userNameTextBox.AutoSize = $true

$main_form.Controls.Add($userNameTextBox)


#passwordLabel ------------------------------------


$passwordLabel = New-Object System.Windows.Forms.Label

$passwordLabel.Text = "Enter password:"

$passwordLabel.Location  = New-Object System.Drawing.Point(10,70)

$passwordLabel.AutoSize = $true

$main_form.Controls.Add($passwordLabel)

#passwordTextBox -----------------------------------

$passwordTextBox = New-Object System.Windows.Forms.TextBox

$passwordTextBox.Location = New-Object System.Drawing.Point(130,70)

$passwordTextBox.PasswordChar = "*"

$passwordTextBox.Size = New-Object System.Drawing.Size(140,23)

$passwordTextBox.AutoSize = $true

$main_form.Controls.Add($passwordTextBox)



#compNameLabel ------------------------------------


$compNameLabel = New-Object System.Windows.Forms.Label

$compNameLabel.Text = "Enter computer name:"

$compNameLabel.Location  = New-Object System.Drawing.Point(10,100)

$compNameLabel.AutoSize = $true

$main_form.Controls.Add($compNameLabel)

#compNameTextBox -----------------------------------

$compNameTextBox = New-Object System.Windows.Forms.TextBox

$compNameTextBox.Location = New-Object System.Drawing.Point(130,100)

$compNameTextBox.Size = New-Object System.Drawing.Size(140,23)

$compNameTextBox.AutoSize = $true

$main_form.Controls.Add($compNameTextBox)

#compNameButton -------------------------------------

$compNameButton = New-Object System.Windows.Forms.Button

$compNameButton.Location = New-Object System.Drawing.Point(280,96)

$compNameButton.Size = New-Object System.Drawing.Size(160,23)

$compNameButton.Text = "Connect"

$compNameButton.AutoSize = $true

$main_form.Controls.add($compNameButton)



<#ConsoleButton -------------------------------------

$consoleButton= New-Object System.Windows.Forms.Button

$consoleButton.Location = New-Object System.Drawing.Point(280,196)

$consoleButton.Size = New-Object System.Drawing.Size(160,23)

$consoleButton.Text = "Show/Hide Console"

$consoleButton.AutoSize = $true



$main_form.Controls.add($consoleButton)
#>

<#consoleCheck
$consoleCheck = New-Object System.Windows.Forms.CheckBox

$consoleCheck.Location = New-Object System.Drawing.Point(80,200)

$consoleCheck.AutoSize = $true

$consoleCheck.Checked = $false

$consoleCheck.Name = "Toggle Console Visibility"

$consoleCheck.Add_CheckStateChanged({

if ($consoleCheck.Checked -eq $true) {
		[Console.Window]::ShowWindow($consolePtr, 0)
		$consoleCheck.Checked = $false
	}
	else {
		[Console.Window]::ShowWindow($consolePtr, 1)
		$consoleCheck.Checked = $true
	}

#ChangeConsole

})

$main_form.Controls.add($consoleCheck)
#>

#showConsoleButton -------------------------------------

$showConsoleButton = New-Object System.Windows.Forms.Button

$showConsoleButton.Location = New-Object System.Drawing.Point(280,10)

$showConsoleButton.Size = New-Object System.Drawing.Size(160,23)

$showConsoleButton.Text = "Show Console"

$showConsoleButton.AutoSize = $true

$main_form.Controls.add($showConsoleButton)

#hideConsoleButton -------------------------------------

$hideConsoleButton = New-Object System.Windows.Forms.Button

$hideConsoleButton.Location = New-Object System.Drawing.Point(280,50)

$hideConsoleButton.Size = New-Object System.Drawing.Size(160,23)

$hideConsoleButton.Text = "Hide Console"

$hideConsoleButton.AutoSize = $true

$main_form.Controls.add($hideConsoleButton)


#compNameLabel ------------------------------------


$compErrLabel = New-Object System.Windows.Forms.Label

$compErrLabel.Text = ""

$compErrLabel.Location  = New-Object System.Drawing.Point(10,130)

$compErrLabel.AutoSize = $true

$main_form.Controls.Add($compErrLabel)

$showConsoleButton.Add_Click(

{
	[Console.Window]::ShowWindow($consolePtr, 1)
}

)


$hideConsoleButton.Add_Click(

{
	[Console.Window]::ShowWindow($consolePtr, 0)
}

)


$compNameButton.Add_Click(

{
				#Write-Host $passwordTextBox.Text
				#Write-Host $userNameTextBox.Text
				
				$passConvert = ConvertTo-SecureString $passwordTextBox.Text -AsPlainText -Force
				
				[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userNameTextBox.Text, $passConvert)
				
				#Write-Host "password below"
				#Write-Host $credObject.UserName
				#Write-Host $credObject.GetNetworkCredential().Password
				
				
                $invalidPC = $false
                $pcName = $compNameTextBox.Text

                $connectTest = Test-Connection $pcName -count 1 -ErrorAction SilentlyContinue
				$warningSess = $false
				
                Write-Host $connectTest
                
                if ($connectTest -eq $null) { $invalidPC = $true }
                               
                if ($invalidPC -eq $false) {

				
				if ($pcName -notmatch "[a-z]") {
					$noDomain = $true
				}
				else {
					$noDomain = $false
				}
				Write-Host "Off Domain is $offDomain"

Write-Host "No Domain is $noDomain"


     $computer = $pcName


                    $tempfile = "C:\temp\rdpscriptTemp.txt"
					
				
				if ($noDomain -eq $true) {
					Invoke-Command -ComputerName $computer -ScriptBlock {quser.exe} -Credential $credObject | Out-File "$tempfile"
					$allSessions = Get-Content $tempfile
					Remove-Item $tempfile -force
				}
				else {
					$allSessions = quser /server:$computer
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

Write-Host $userNames

if (!($activeUser -eq $null)) {$activeTrue = $true}

if ($userNames -eq $null) {$warningSess = $true}

if (!($discUser -eq $null)) {$discTrue = $true}

Write-Host "active:" $activeTrue
Write-Host "warning:" $warningSess
Write-Host "disconnected:" $discTrue


$SessID = $activeUser.ID
        
    




				if ($activeTrue -eq $true)
				
				{
					
					
					
				
						$uName = $userNameTextBox.Text
						$cmdArgs = "/shadow:$SessId /v:$pcName /noconsentprompt /control"
						
					   
						
						if ($noDomain -eq $true) {
							[Console.Window]::ShowWindow($consolePtr, 1)
						cls
						Write-Host "Enter the user's password"
						runas /netonly /user:$uName "mstsc.exe $cmdArgs"
						[Console.Window]::ShowWindow($consolePtr, 0)
						}
						else {
							 Start-Process mstsc.exe -WorkingDirectory "C:\Windows\System32" -ArgumentList $cmdArgs -Credential $credObject
						}
#$command = "mstsc.exe /shadow:$SessId /v:$pcName /noconsentprompt /control"
                 

                

                Write-Host

                

                $compErrLabel.ForeColor = 'green'
                $compErrLabel.Text = "Connection to $pcName is successful."

				}
				
				
				else {
                
				if ($discTrue -eq $true) {
				$compErrLabel.ForeColor = 'red'
                $compErrLabel.Text = "$pcName has a disconnected user."
				}
                
				else {
				$compErrLabel.ForeColor = 'red'
                $compErrLabel.Text = "$pcName does not have any users logged in."
				}


                }
                
                
                }
                else {
					
                $pcLength = $compNameTextBox.Text
			
				if ($pcLength.length -lt 1) {
					$compErrLabel.ForeColor = 'red'
					$compErrLabel.Text = "A computer name was not entered"
				}
				else {
					$compErrLabel.ForeColor = 'red'
					$compErrLabel.Text = "$pcName does not exist or is not reachable."
				}
                }

                

}

)







$main_form.ShowDialog()





