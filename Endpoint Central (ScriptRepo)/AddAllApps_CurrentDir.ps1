$filesA = Get-ChildItem .\*.appx
$filesP = Get-ChildItem .\*.appxbundle
$filesM = Get-ChildItem .\*.Emsixbundle
$filesA | ForEach-Object {
add-appxprovisionedpackage -online -packagepath $_.Name -SkipLicense
}
$filesP | ForEach-Object {
add-appxprovisionedpackage -online -packagepath $_.Name -SkipLicense
}
$filesM | ForEach-Object {
add-appxprovisionedpackage -online -packagepath $_.Name -SkipLicense
}