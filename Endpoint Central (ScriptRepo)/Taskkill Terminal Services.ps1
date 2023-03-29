if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
}

$allprocesses = gcim win32_process
$TermSvcData = $allprocesses | Where-Object {$_.CommandLine -like "*TermService"}
$termPID = $TermSvcData.ProcessId
taskkill /PID $termPID /F