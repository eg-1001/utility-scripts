@echo off
setlocal
:PROMPT
SET /P AREYOUSURE=Are you sure you want to restart? (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END

echo ... rest of file ...
shutdown /r /t 0

:END

