@echo ON
REM Set variables
	REM Office Architecture 32/64
	set /P arch="Enter version of Office (32/64):"

	REM Folder creation
	set /P bld="Enter a name for the Office Install folder (ex. 1906-Build_11727.20230):"
	
ECHO The office folder at "H:\Microsoft\Office 2016 Home & Business\Office2016_%arch%bit_Automated\%bld%" will be deleted if it exists
PAUSE

REM Check if Temporary ODT folder exists on C:
IF EXIST "C:\TempODT\NUL" ( rmdir /S "C:\TempODT") ELSE ( mkdir "C:\TempODT\OfficeDeploymentTool" )

REM Copy the setup.exe from current directory to local temp folder
	copy "H:\Microsoft\Office 2016 Home & Business\OfficeDeploymentTool\setup.exe" "C:\TempODT\OfficeDeploymentTool"

REM Copy XML file to local temp folder
	copy "H:\Microsoft\Office 2016 Home & Business\OfficeDeploymentTool\installconfig%arch%.xml" "C:\TempODT\OfficeDeploymentTool"
	cd /d "C:\TempODT\OfficeDeploymentTool"


REM Deletes the pre-existing folder on H:\

IF EXIST "H:\Microsoft\Office 2016 Home & Business\Office2016_%arch%bit_Automated\%bld%\NUL" ( rmdir /S "H:\Microsoft\Office 2016 Home & Business\Office2016_%arch%bit_Automated\%bld%" ) ELSE ( mkdir "H:\Microsoft\Office 2016 Home & Business\Office2016_%arch%bit_Automated\%bld%" )

REM Starts the download
	setup.exe /download installconfig%arch%.xml
	
REM Moves the setup and config files to the newly created H:\ directory
	copy "setup.exe" "H:\Microsoft\Office 2016 Home & Business\Office2016_%arch%bit_Automated\%bld%"
	copy "installconfig%arch%.xml" "H:\Microsoft\Office 2016 Home & Business\Office2016_%arch%bit_Automated\%bld%"

ECHO Copying the downloaded Office folder in "H:\Microsoft\Office 2016 Home & Business\OfficeDeploymentTool" to "H:\Microsoft\Office 2016 Home & Business\Office2016_%arch%bit_Automated\%bld%"

REM Move the local downloaded office folder from the temp directory to H:\
	robocopy "C:\TempODT\OfficeDeploymentTool\Office" "H:\Microsoft\Office 2016 Home & Business\Office2016_%arch%bit_Automated\%bld%\Office" /E
	ECHO The Office Install folder was saved at "H:\Microsoft\Office 2016 Home & Business\Office2016_%arch%bit_Automated\%bld%"
	cd /d "H:\Microsoft\Office 2016 Home & Business\Office2016_%arch%bit_Automated\%bld%"

REM Renames the XML file
	ren installconfig%arch%.xml installconfig.xml

REM Deletes the temp directory
	del /S /F /Q "C:\TempODT"
	rmdir /s /q "C:\TempODT"

msg %username% Task Completed
pause
