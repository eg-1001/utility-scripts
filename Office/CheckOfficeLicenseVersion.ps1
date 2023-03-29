cls
$failedCheck = $false


if (!(Test-Path "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.vbs"))
    
    {

    if ((Test-Path "C:\Program Files\Microsoft Office\Office16\OSPP.vbs")) 
    
        {
            $licenseStatus = cscript "C:\Program Files\Microsoft Office\Office16\OSPP.vbs" /dstatusall

           
            
        }

    
    
    else {
        $licenseStatus = "No office install exists."
        $failedCheck = $true
        
        }
    }

else
    {
        

        $licenseStatus = cscript "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.vbs" /dstatusall

        
     

    } 

    $pcName = $env:COMPUTERNAME

    $O16 = Select-String -InputObject $licenseStatus "LICENSE DESCRIPTION: Office 16, RETAIL channel LICENSE STATUS:  ---LICENSED---  Last 5"
    $O19 = Select-String -InputObject $licenseStatus "LICENSE DESCRIPTION: Office 19, RETAIL channel LICENSE STATUS:  ---LICENSED---  Last 5"


    if ($failedCheck) {$licenseStatus | Out-File -FilePath "\\titan\common\erik\OfficeLic\Missing\$pcName.txt"}
    else {
    
    if (!($O16 -eq $null)) {$licenseStatus | Out-File -FilePath "\\titan\common\erik\OfficeLic\Present16\$pcName.txt"}
    if (!($O19 -eq $null)) {$licenseStatus | Out-File -FilePath "\\titan\common\erik\OfficeLic\Present19\$pcName.txt"}
        
    if (($O16 -eq $null) -AND ($O19 -eq $null)) {
        
        "Nothing was found." | Out-File -FilePath "\\titan\common\erik\OfficeLic\NoLicense\$pcName.txt"

    }
    
    }
    

   