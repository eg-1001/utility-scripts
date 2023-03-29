Copy-Item "\\helike\installs\Microsoft\Office 2019\EasyOfficeInstaller\EasyOfficeLicense(LocalOnly).ps1" -Destination "C:\temp\"
Copy-Item "\\helike\installs\Microsoft\Office 2019\EasyOfficeInstaller\Elevate_EasyOfficeLicense(LocalOnly).lnk" -Destination "C:\temp\"
Start-Process -Wait "C:\temp\Elevate_EasyOfficeLicense(LocalOnly).lnk"

Remove-Item "C:\temp\EasyOfficeLicense(LocalOnly).ps1" -Force
Remove-Item "C:\temp\Elevate_EasyOfficeLicense(LocalOnly).lnk" -Force