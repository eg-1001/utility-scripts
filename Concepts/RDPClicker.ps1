Add-Type -AssemblyName System.Windows.Forms
$signature=@'
[DllImport("user32.dll",CharSet=CharSet.Auto,CallingConvention=CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@
$SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru

$getPass = Read-Host -Prompt "Enter your password" -AsSecureString
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($getPass)
$passValue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

$screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$screen | Get-Member -MemberType Property
#[Windows.Forms.Cursor]::Position = "$($screen.Width),$($screen.Height)"
#Write-Host $screen.Width
#Write-Host $screen.Height
#Write-Host = [Windows.Forms.Cursor]::Position

#Click GlobalProtect in Taskbar
<#
[Windows.Forms.Cursor]::Position = "$(1724),$(1058)"
sleep -Seconds 1
$SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0);
$SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0);
sleep -Seconds 1
#>

#Click globalprotect Connect button
<#
[Windows.Forms.Cursor]::Position = "$(1697),$(991)"
sleep -Seconds 1
$SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0);
$SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0);
sleep -Seconds 1
#>

#click username to select it
<#
[Windows.Forms.Cursor]::Position = "$(1700),$(870)"
sleep -Seconds 1
$SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0);
$SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0);
$SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0);
$SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0);
sleep -Seconds 1
#>
$wshell = New-Object -ComObject wscript.shell;
#clear username field
<#

$wshell.SendKeys('{DELETE}') 
sleep -Seconds 1
#>
#enter data
<#
$wshell.SendKeys('egomezleon')
$wshell.SendKeys('{TAB}') 
$wshell.SendKeys($passValue)
#>
#write-host $passValue

#click button
<#
[Windows.Forms.Cursor]::Position = "$(1800),$(950)"
sleep -Seconds 1
$SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0);
$SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0);
sleep -Seconds 6
#>

#send "1"
<#
$wshell.SendKeys('1')
$wshell.SendKeys('{ENTER}') 
sleep -Seconds 1
#>

cd ".\Computers\Shortcuts"

while ($true) {

$pcName = Read-Host -Prompt "Enter PC Name"
$connectTest = Test-Connection $pcName -count 1 -ErrorAction SilentlyContinue

if ($connectTest -ne $null) {
		mstsc "$pcName.rdp"
		#
		#$wshell.SendKeys('egomezleon')
		sleep -Seconds 1
		$wshell.SendKeys('{TAB}') 
		$wshell.SendKeys('{ENTER}') 
		sleep -Seconds 1
		$wshell.SendKeys($passValue)
		#$wshell.SendKeys('1')
		$wshell.SendKeys('{ENTER}') 
		#$wshell.SendKeys($passValue)   	
	    }
		else {
			Write-Host "No PC Found"
		}



}