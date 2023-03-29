@echo off
echo type exit to quit
echo Available prefixes: AD, AZ, BR, IT, WS (blank will reset prefix)
:loop

echo --------------------

echo Active Prefix: %hPref%
set "hName="
set /P hName="Enter hostname/command:"
IF "%hName%"=="exit" (
    Exit
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
IF "%hName%"=="it" (
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
cmd /c "nslookup %hPref%%hName%"




goto loop