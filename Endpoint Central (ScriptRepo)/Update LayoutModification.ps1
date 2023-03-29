$userFolders = (gci -path "$env:SystemDrive\users" -Directory).Fullname
$userFolders | foreach {
    $updatedLocation = $_ + "\AppData\Local\Microsoft\Windows\Shell"
    $testPath = $updatedLocation+"\LayoutModification.xml"
    if (Test-Path -Path $testPath) {
    Copy-Item -Path "\\daphnis\shared\LayoutModification.xml" -Destination $updatedLocation -Force -Verbose}
    
}
