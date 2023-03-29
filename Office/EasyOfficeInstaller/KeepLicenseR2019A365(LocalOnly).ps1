$userInput = ""
$officeArchCommand = "0"
$commandPass = ""
$officeCopyTemp = "C:\temp\officeInstaller\"
$officeRemoveLocation = "\\helike\installs\Microsoft\Office 365\EasyOfficeInstaller\Upgrade2019to365\Script Dependencies\Uninstaller"
$officeInstallerLocation = "\\helike\installs\Microsoft\Office 365\EasyOfficeInstaller\Upgrade2019to365\Script Dependencies\16.0.15928.20198"

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

Write-Host "Found an office installation"



if (Test-Path $officeCopyTemp) {
    Remove-Item $officeCopyTemp -Force -Recurse
}

Write-Host "Copying Office uninstaller, please wait..." -ForegroundColor Yellow


Copy-Item $officeRemoveLocation $officeCopyTemp -Recurse
	
cd C:\temp\officeInstaller
.\Setup.exe /configure removeconfigLatest.xml


#waiting for uninstall to finish up
cd C:\temp
sleep 5

if (Test-Path $officeCopyTemp) {
    Remove-Item $officeCopyTemp -Force -Recurse
}

Write-Host "old Office versions should be uninstalled"


Write-Host "Copying Office 365 installer, please wait..." -ForegroundColor Yellow

Copy-Item $officeInstallerLocation $officeCopyTemp -Recurse
cd C:\temp\officeInstaller
.\Setup.exe /configure installconfigScript.xml

Write-Host "Office 365 should be installed"