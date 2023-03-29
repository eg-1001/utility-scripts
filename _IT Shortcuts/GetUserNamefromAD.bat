@echo off
echo type exit to quit

:loop

echo --------------------

@echo off
echo Active Prefix: %hPref%
set "hName="
set /P hName="Enter username/command:"
IF "%hName%"=="exit" (
    Exit
)



IF [%hName%]==[] (
    set "hPref="
	goto loop
)

powershell.exe "Get-ADUser -Identity %hPref%%hName% | select Name"
	





goto loop