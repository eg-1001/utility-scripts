Write-Host "This script can check, install, or remove a product key for Office."
$userInput = ""
$officeArchCommand = "0"
$commandPass = ""

#get office version

if (!(Test-Path "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.vbs"))
    
    {

    if ((Test-Path "C:\Program Files\Microsoft Office\Office16\OSPP.vbs")) 
    
        {
            $officeArchCommand = "cscript.exe " + "`"C:\Program Files\Microsoft Office\Office16\OSPP.vbs`""           
            
        }    
    
    else {
        Write-Host "No office install exists." -ForegroundColor Red
	sleep 8
        exit
        
        }
    }

else
    {
        
        $officeArchCommand = "cscript.exe " + "`"C:\Program Files (x86)\Microsoft Office\Office16\OSPP.vbs`""        

    } 




while ($true) {
	
	Write-Host "Enter a command from the list below, along with any required syntax" -ForegroundColor Gray
	Write-Host "Check" -ForegroundColor Gray
	Write-Host "Add <PRODUCTKEY>" -ForegroundColor Gray
	Write-Host "Remove <PARTIALPRODUCTKEY>" -ForegroundColor Gray
	Write-Host "Quit" -ForegroundColor Gray
	Write-Host
	
	$userInput = Read-Host
	
	Write-Host
	
	if (($userInput -like "*check*") -OR ($userInput[0] -like "c")) {
		
		$commandPass = "$officeArchCommand" + " /dstatusall"
		$licenseStatus = iex $commandPass
		
		$newStatus = $licenseStatus -replace ("ERROR DESCRIPTION: The Software Licensing Service reported that the product key is not available.","")
		$newStatus = $newStatus -replace ("LICENSE STATUS:  ---UNLICENSED---","")
		$newStatus = $newStatus -replace ("ERROR CODE: 0xC004F014","")
		#$newStatus = $newStatus -replace ("LICENSE DESCRIPTION: Office 19, RETAIL* channel","")
		#$newStatus = $newStatus -replace ("LICENSE NAME: Office 19* edition","")
				
		#$keyOnly = $newStatus | Where-Object {$_ -like "*Last 5 characters*"}
		
		$numCount = 0
		
		#$newStatus
		Write-Host "-------"
		$newStatus | foreach {
			
			$currentObj = $_
			$itemStore = $currentObj | Where-Object {$_ -like "*Last 5 characters*"}
			if ($itemStore -ne $null) {
				Write-Host $newStatus[$numCount - 3]
				Write-Host $newStatus[$numCount - 2]
				Write-Host $newStatus[$numCount]
				Write-Host "-------"
				}
			$numCount++
		}

		
		#$keyOnly
		
		<#
		if (!($O16 -eq $null)) {$Off16KeyFound
		Write-Host "16" -ForegroundColor Yellow}
		if (!($O19 -eq $null)) {$Off16KeyFound
		Write-Host "19" -ForegroundColor Yellow}
		#>
		
		
		
		
		
		
		Write-Host
	}
	if (($userInput -like "*add*") -OR ($userInput[0] -like "a")) {
		
		$pKey = $userInput -replace ("add ","")
		$pKey = $pkey -replace ("a ","")
		
		
		$commandPass = "$officeArchCommand" + " /inpkey:$pKey"
		iex $commandPass
		
		
		
		Write-Host
		
	}
	if (($userInput -like "*remove*") -OR ($userInput[0] -like "r")) {
		
		$pKey = $userInput -replace ("remove ","")
		$pKey = $pkey -replace ("r ","")
		
		
		$commandPass = "$officeArchCommand" + " /unpkey:$pKey"
		iex $commandPass
		
		
		
		Write-Host
		
	}
	if (($userInput -like "*quit*") -OR ($userInput[0] -like "q")) {
		exit
	}
	
	
	
	
}





#$prodkey -like "*-*-*-*-*"



<#
$o19
		$Regex = [Regex]::new("(?<=installed product key: )(.*)(?=- SKU)")           
		$Match = $Regex.Match($O16)           
		if($Match.Success)           
		{           
			$O16 = $Match.Value           
		}
		
		$Regex = [Regex]::new("(?<=installed product key: )(.*)(?=- SKU)")           
		$Match = $Regex.Match($O19)           
		if($Match.Success)           
		{           
			$O19 = $Match.Value           
		}
		
		$Off16KeyFound = "Office 16 key present:" + $O16.Substring(0,5)
		$Off19KeyFound = "Office 19 key present:" + $O19.Substring(0,5)
#>