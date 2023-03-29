$installerDir = "\\helike\installs\Microsoft\Office 2019\EasyOfficeInstaller\"
$installerBat = $installerDir + "InstallOfficeViaScript.bat"
$installerLnk = $installerDir + "Elevate_InstallOfficeViaScript.lnk"

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


$buildTemp = Get-ChildItem -Path $officeArchLocation -Filter "*16.0.*"
$listOfBuilds = $buildTemp.Name

$loopVer = $true

while ($loopVer) {
$listOfBuilds
Write-Host "Select an office build version using the corresponding folder name"

$officeBuild = Read-Host


    $foundBuild = $listOfBuilds | Where-Object {$_ -Like "$officeBuild"}
    if ($foundBuild -eq $officeBuild) {
        $loopVer = $false
    }
    else {
        Write-Host "Please enter a valid folder name." -ForegroundColor Yellow
       # Write-Host "Entered items: $foundBuild A $officeBuild" 
    }

    

}



$officeBuildLocation = $officeArchLocation + "\" + $officeBuild
Write-Host "Selected folder name $officeBuildLocation"



if (Test-Path $officeCopyTemp) {
    Remove-Item $officeCopyTemp -Force -Recurse
}

Write-Host "Copying Office files, please wait..." -ForegroundColor Yellow

    Copy-Item $officeBuildLocation $officeCopyTemp -Recurse



Copy-Item $installerBat $officeCopyTemp
Copy-Item $installerLnk $officeCopyTemp

$runOut = $officeCopyTemp + "Elevate_InstallOfficeViaScript.lnk"
iex $runOut

sleep 10