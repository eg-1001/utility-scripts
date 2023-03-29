#easy script for invoking GPUpdate remotely

$host.ui.rawui.WindowTitle = "Remote Group Policy Update"

if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  
  Write-Host "Please log in with admin credentials for the server you intend to connect to."
  sleep 3
  
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
}





while ($true) {
	$currentPC = Read-Host -Prompt "Enter a computer name to invoke GPUpdate on (type `"exit`" to quit)"
	
	if (($currentPC -eq "exit") -OR ($currentPC -eq "quit")) {
		
		exit
		
	}
	
	$invalidPC = $false
	
	
	$connectTest = Test-Connection $currentPC -count 1 -ErrorAction SilentlyContinue	
	if ($connectTest -eq $null) { $invalidPC = $true }
                               
                if ($invalidPC -eq $false) {
					
					Invoke-GPUpdate -Computer $currentPC -force
					
				}
				else {
					
					Write-Host "Computer is offline or doesn't exist." -ForegroundColor Red
					
				}
	
	
	
	
	
	
	
	
	
}

