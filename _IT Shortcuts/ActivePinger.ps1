$pcName = $args[0]

$activePC = $false


if ($pcName -eq $null) {
$pcName = read-host -Prompt "Please enter the PC name to connect to"
}
Write-Host
Write-Host "Note: Connection attempts will not be shown"

                $connectTest = Test-Connection $pcName -count 1 -ErrorAction SilentlyContinue
                
             if ($connectTest -eq $null) { $activePC = $true }
                               
                while ($activePC -eq $true) {
					
					#Write-Host "Retrying Connection"
					$connectTest = Test-Connection $pcName -count 1 -ErrorAction SilentlyContinue
					
					if ($connectTest -eq $null) { $activePC = $true }
else {$activePC = $false}

				

                }
	
$currDate = Get-Date	
Write-Host "$pcName is active as of $currDate"
msg $env:UserName $pcName is active	as of $currDate
pause
