$downloaderDir = "\\helike\installs\Microsoft\Office 2019\EasyOfficeInstaller\"
$downloaderBat = $downloaderDir + "DownloadOfficeViaScript.bat"
$downloaderLnk = $downloaderDir + "Elevate_DownloadOfficeViaScript.lnk"
$downloaderExe = $downloaderDir + "Setup.exe"

$officeArch = "0"
$officeVersion = "2019"
$officeLocation = "\\helike\installs\Microsoft\Office 2019\"
$officeArchLocation = $officeLocation
$officeBuildLocation = $officeLocation
$officeBuild = "0"
$officeCopyTemp = "C:\temp\officeInstaller\"




$loopArch = $true

while ($loopArch) {
    Write-Host "Select an office architecture: (32/64)"
    $officeArch = Read-Host

    if (($officeArch -eq "32") -OR ($officeArch -eq "64")) {
        $loopArch = $false
    }
    else {
        Write-Host "Please enter a valid architecture." -ForegroundColor Yellow
    }


}

$readOut = "Selected the " + $officeArch + "bit architecture."
#Write-Host $readOut


$saveOut = $officeLocation + "Office2019_" + $officeArch + "bit_Automated"
$officeArchLocation = $saveOut




$loopVer = $true

while ($loopVer) {



Write-Host "Enter a valid office build number (ex: 16.0.14527.20276):"

$officeBuild = Read-Host
$buildTemp = Get-ChildItem -Path $officeArchLocation -Filter "*16.0.*"
$listOfBuilds = $buildTemp.Name

    $foundBuild = $listOfBuilds | Where-Object {$_ -Like "$officeBuild"}
    if ($foundBuild -eq $officeBuild) {
        Write-Host "Build version $foundBuild already exists. This script will not overwrite the existing version." -ForegroundColor Yellow
    }
    else {
		
		if (($officeBuild -match "16.0.*") -AND ($officeBuild.length -ge 5)) {$loopVer = $false}
		else {Write-Host "Please enter a valid folder name." -ForegroundColor Yellow}
        
		
       
	   # Write-Host "Entered items: $foundBuild A $officeBuild" 
    }

    

}

if (Test-Path $officeCopyTemp) {
    Remove-Item $officeCopyTemp -Force -Recurse
}

New-Item $officeCopyTemp -ItemType Directory

$officeBuildLocation = $officeArchLocation + "\" + $officeBuild
Write-Host "Selected folder name $officeBuildLocation"



$ODTConfig = Get-Content "\\helike\installs\Microsoft\Office 2019\EasyOfficeInstaller\installconfigLatest.xml"
$ODTConfig[1] = "  <Add OfficeClientEdition=`"$officeArch`" Channel=`"Current`" SourcePath=`"$officeCopyTemp`" Version=`"$officeBuild`" AllowCdnFallback=`"FALSE`">"
$xmlPath = $officeCopyTemp + "\installConfigScript.xml"
$ODTConfig | Out-File -FilePath $xmlPath

$DCODTConfig = Get-Content "\\helike\installs\Microsoft\Office 2019\EasyOfficeInstaller\installconfigLatest.xml"
$DCODTConfig[1] = "  <Add OfficeClientEdition=`"$officeArch`" Channel=`"Current`" SourcePath=`"`" Version=`"$officeBuild`" >"
$DCxmlPath = $officeCopyTemp + "\installConfigDC.xml"
$DCODTConfig | Out-File -FilePath $DCxmlPath




#Write-Host "Copying Office files, please wait..." -ForegroundColor Yellow

    #Copy-Item $officeBuildLocation $officeCopyTemp -Recurse



#Copy-Item $downloaderBat $officeCopyTemp
#Copy-Item $downloaderLnk $officeCopyTemp
Copy-Item $downloaderExe $officeCopyTemp

$runOut1 = $officeCopyTemp + "setup.exe"
$runOut2 = "/download " + $officeCopyTemp + "installConfigScript.xml"
#iex 
Write-Host "Downloading Office. This may take 5 minutes..." -ForegroundColor Cyan

Start-Process -Wait $runOut1 -ArgumentList $runOut2



sleep 10

#New-Item $officeBuildLocation -Type Directory

Copy-Item $officeCopyTemp -Destination $officeArchLocation -Force -Recurse
$renameOut = $officeArchLocation + "\officeInstaller"
Rename-Item $renameOut -NewName $officeBuildLocation -Force



Write-Host "Done downloading office." -ForegroundColor Cyan
msg * "Download complete!"
sleep 3