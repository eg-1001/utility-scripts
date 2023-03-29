#uses VLC to convert mp4 files to mp3

#clean RunDir

$scriptDir = "C:\Temp\convert mp4 to mp3\Script\ScriptStatus.log"
Write-Host "Starting Script..." -ForegroundColor Gray 
$execDate = Get-Date
"------------" | Out-File -FilePath $scriptDir -Append
"Script Started at $execDate" | Out-File -FilePath $scriptDir -Append

$teamFolder = "\\titan\team_folders\Board of Directors\Recordings\"
$runDir = "C:\Temp\convert mp4 to mp3\Working"
Set-Location $runDir

$listToDelete = gci -Path $runDir
$listToDelete | foreach {
    Remove-Item -Path $_.FullName -ErrorAction SilentlyContinue
}

$copyMP4 = gci -Path $teamFolder -Filter *.mp4
if ($copyMP4 -eq $null) {
    Write-Host "No files were found to convert." -ForegroundColor Gray 
    "No files to convert from $teamFolder" | Out-File -FilePath $scriptDir -Append
    exit
} 
Write-Host "Copying files." -ForegroundColor Gray 
"Found the following files from $teamFolder to move:" | Out-File -FilePath $scriptDir -Append
$copyMP4 | foreach {

    Copy-Item $_.FullName -Destination $runDir
    $_.Name | Out-File -FilePath $scriptDir -Append

}

$outputExtension = ".mp3"
#$bitrate = 64
$bitrate = 160
$channels = 1

Write-Host "Files copied locally!" -ForegroundColor Yellow 
Write-Host "Converting files..." -ForegroundColor Gray 

#<#

foreach($inputFile in get-childitem -Path $runDir -Filter *.mp4)
{ 
  $outputFileName = [System.IO.Path]::GetFileNameWithoutExtension($inputFile.FullName) + $outputExtension;
  $outputFileName = [System.IO.Path]::Combine($inputFile.DirectoryName, $outputFileName);
  $outputCompleteName = ($inputFile.Name).SubString(0,($inputFile.Name).Length-3)
  
  $inputCompleteName = $inputFile.Name
  #$inputCompleteName = "March 10th Loan Review Meeting Recording.mp4"
  $outputCompleteName = $outputCompleteName + "mp3"
  
  $programFiles = $env:ProgramFiles
  if($programFiles -eq $null) { $programFiles = ${env:ProgramFiles(x86)}; }
  
  $processName = $programFiles + "\VideoLAN\VLC\vlc.exe"
  #$processName = ".\converter.exe"
  $processArgs = "-I dummy -vvv `"$inputCompleteName`" --sout=#transcode{acodec=`"mp3`",ab=`"$bitrate`",`"channels=$channels`"}:standard{access=`"file`",mux=`"wav`",dst=`"$outputCompleteName`"} vlc://quit"
  
  start-process $processName $processArgs -wait
  
 # Write-Host "Running Command $processName $processArgs"
 #$processName

}
Write-Host "Conversions Completed!" -ForegroundColor Yellow 
Write-Host "Moving files..." -ForegroundColor Gray 

$listToCopy = gci -Path $runDir -Filter *.mp3


"Saved the following MP3 files:" | Out-File -FilePath $scriptDir -Append

$listToCopy | foreach {

    Copy-Item $_.FullName -Destination "$teamFolder\Automatic MP3 Convert (Complete)" -Force -ErrorAction SilentlyContinue
    $_.Name | Out-File -FilePath $scriptDir -Append

}

$copyMP4 | foreach {

    Move-Item $_.FullName -Destination "$teamFolder\Automatic MP3 Convert (Complete)" -Force -ErrorAction SilentlyContinue

}
#>

$listToDelete = gci -Path $runDir
$listToDelete | foreach {
    Remove-Item -Path $_.FullName -ErrorAction SilentlyContinue
}



Write-Host "File moves completed!" -ForegroundColor Yellow 

"Conversion has completed." | Out-File -FilePath $scriptDir -Append
