#uses VLC to convert mp4 files to mp3

$outputExtension = ".mp3"
$bitrate = 64
#$bitrate = 160
$channels = 1

foreach($inputFile in get-childitem -Filter *.mp4)
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

$processName
}