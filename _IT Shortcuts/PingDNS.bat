@echo off
echo type exit to quit
echo Available prefixes: AD, AZ, BR, IT, WS (blank will reset prefix)
echo Ping Settings: once, forever (once is default)
set nPings=one
:loop

echo --------------------

echo Active Prefix: %hPref%
echo Number of Pings: %nPings%
set "hName="
set /P hName="Enter hostname/command:"
IF "%hName%"=="exit" (
    Exit
)
IF "%hName%"=="forever" (
    set nPings=forever
	goto loop
)
IF "%hName%"=="one" (
    set nPings=one
	goto loop
)
IF "%hName%"=="AD" (
    set hPref=AD-
	goto loop
)
IF "%hName%"=="ad" (
    set hPref=AD-
	goto loop
)
IF "%hName%"=="AZ" (
    set hPref=AZ-
	goto loop
)
IF "%hName%"=="az" (
    set hPref=AZ-
	goto loop
)
IF "%hName%"=="BR" (
    set hPref=BR-
	goto loop
)
IF "%hName%"=="br" (
    set hPref=BR-
	goto loop
)
IF "%hName%"=="WS" (
    set hPref=WS-
	goto loop
)
IF "%hName%"=="ws" (
    set hPref=WS-
	goto loop
)
IF "%hName%"=="IT" (
    set hPref=IT-
	goto loop
)
IF "%hName%"=="IT" (
    set hPref=IT-
	goto loop
)
IF [%hName%]==[] (
    set "hPref="
	goto loop
)

IF "%nPings%"=="one" (
	cmd /c "ping -n 1 %hPref%%hName%"
	goto loop
)
IF "%nPings%"=="forever" (
	cmd /c "ping %hPref%%hName% -t"
	goto loop
)



goto loop