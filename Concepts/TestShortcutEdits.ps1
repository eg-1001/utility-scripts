$oldPrefix = "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
$newPrefix = "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE"
$searchPath = "C:\Users\egomezleon\Desktop\Outlook.lnk"

$shell = new-object -com wscript.shell
write-host "Updating shortcut target" -foregroundcolor red -backgroundcolor black

$lnk = $shell.createShortcut($searchPath)
$oldPath = $lnk.targetPath
$lnkRegex = "^" + [regex]::escape( $oldPrefix )



$newPath = $oldPath -replace $lnkRegex, $newPrefix
$lnk.targetPath = $newPath
$lnk.Save()

<#
dir $searchPath -filter *.lnk -recurse | foreach {
$lnk = $shell.createShortcut( $_.fullname )
$oldPath= $lnk.targetPath
$lnkRegex = "^" + [regex]::escape( $oldPrefix )

if ( $oldPath -match $lnkRegex ) {
$newPath = $oldPath -replace $lnkRegex, $newPrefix

write-host "Found: " + $_.fullname -foregroundcolor yellow -backgroundcolor black
write-host " Replace: " + $oldPath
write-host " With: " + $newPath
$lnk.targetPath = $newPath
$lnk.Save()
}
}
#>