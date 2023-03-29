$pcName = $args[0]

$inactivePC = $false


if ($pcName -eq $null) {
$pcName = read-host -Prompt "Please enter the PC name to connect to"
}
Write-Host
Write-Host "Connecting to $pcName"

                $connectTest = Test-Connection $pcName -count 1 -ErrorAction SilentlyContinue
                
             if ($connectTest -eq $null) { $inactivePC = $true }
                               
                while ($inactivePC -eq $true) {
					
					#Write-Host "Retrying Connection"
					$connectTest = Test-Connection $pcName -count 1 -ErrorAction SilentlyContinue
					
					if ($connectTest -eq $null) { $inactivePC = $true }
else {$inactivePC = $false}

				

                }
	
$currDate = Get-Date	
Write-Host "$pcName is currently active as of $currDate"
Write-Host
Write-Host "Waiting for a connection failure."





$activePC = $true

$connectTest = Test-Connection $pcName -count 1 -ErrorAction SilentlyContinue
                
             if ($connectTest -eq $null) { $activePC = $false }
                               
                while ($activePC -eq $true) {
					
					#Write-Host "Retrying Connection"
					$connectTest = Test-Connection $pcName -count 1 -ErrorAction SilentlyContinue
					
					if ($connectTest -eq $null) { $activePC = $false }
else {$activePC = $true}

				

                }
			
			
			
$currDate = Get-Date
Write-Host "$pcName is inactive as of $currDate"
Write-Host
Write-Host "Waiting for the connection to come back up." 
				
				
				
				
				
$reactivePC = $false


Write-Host


                $connectTest = Test-Connection $pcName -count 1 -ErrorAction SilentlyContinue
                
             if ($connectTest -eq $null) { $reactivePC = $true }
                               
                while ($reactivePC -eq $true) {
					
					#Write-Host "Retrying Connection"
					$connectTest = Test-Connection $pcName -count 1 -ErrorAction SilentlyContinue
					
					if ($connectTest -eq $null) { $reactivePC = $true }
else {$reactivePC = $false}

				

                }




$currDate = Get-Date	
Write-Host "$pcName is back on as of $currDate"
msg $env:UserName $pcName is back on as of $currDate



pause
