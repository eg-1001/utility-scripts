#working POC script for API login with Packetfence, currently doesn't do much besides get an API key

# https://192.168.3.20:1443/


$pfServerName = "192.168.3.20"
$pfServerPort = "9999"
$global:pfToken
$userDom = "accu"
$userLoggedIn = $false
$userAuthenticated = $false
$authInfo = $null
$userName = $null
$userPass = $null
$otpNum = $null
$uniqueUserID = $null
$retrieve2 = $null
$retrieve1 = $null
$global:dcToken = $null



#ignore SSL issues
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy







function SubmitOTPChallenge {

$authURITwo = "https://$pfServerName`:$pfServerPort/api/1.3/desktop/authentication?username=$script:userName&password=$script:userPass&auth_type=ad_authentication&domainName=$script:userDom"

$servicePoint2 = [System.Net.ServicePointManager]::FindServicePoint($authURITwo)

    $urlAuth2 = @{
   
        WebSession = $retrieve2
        ContentType = 'application/json; charset=utf-8'
        URI = $authURITwo
        Method = 'POST'
       Headers = @{"Accept"= "application/json"
       }
    }

Write-Host "test UUID $global:uniqueUserID and otpnumber $global:OTPNum and authURI $authURITwo" -ForegroundColor Magenta
    # | Out-Null
    $global:retrieve2 = Invoke-WebRequest @urlAuth2 -UseBasicParsing
    $global:retrieve2 
Write-Host "$global:uniqueUserID"

    #cleans the uuid and otpNum global variables
    $global:uniqueUserID = $null
    $global:otpNum = $null
    $servicePoint2.CloseConnectionGroup($authURITwo)
   

}


function GetPFAPIKey {

$authURIOne = "https://$pfServerName`:$pfServerPort/api/v1/login"
$servicePoint1 = [System.Net.ServicePointManager]::FindServicePoint($authURIOne)

$UserDetails = @{
                 "username" = "$global:userName"
                 "password" = "$global:userPass" 
                 }



    $urlAuth1 = @{
   
   
        ContentType = 'application/json'
        URI = $authURIOne
        Method = 'POST'
        Body = ($UserDetails|ConvertTo-Json)

       Headers = @{"Accept"= "application/json"}
    }
    
    $global:retrieve1 = Invoke-WebRequest @urlAuth1 -UseBasicParsing

    # | Out-Null
    
   

    #cleans the username and encoded password global variables
    $global:userPass = $null
    $global:userName = $null
    $servicePoint1.CloseConnectionGroup($authURIOne)

}

function LoginPFSystem {
$validUserName = $false
$validPassword = $false
Write-Host "Please log into PacketFence."

while ((!($validUserName)) -OR (!($validPassword))) {

$validUserName = $false
$validPassword = $false

    
    Write-Host
    Write-Host "Enter your Username" -ForegroundColor Yellow
    $global:userName = Read-Host
    if ($global:userName.Length -ge 2) {

    $validUserName = $true
    

    Write-Host "Enter your password" -ForegroundColor Yellow
    $secString = Read-Host -AsSecureString 

    $global:userPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secString))
    #$script:userPass = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($textPass))

    if ($global:userPass.Length -ge 2) {
        $validPassword = $true
        
    }

    }
if ((!($validUserName)) -OR (!($validPassword))) {Write-Host "A username or password was left blank or too short!" -ForegroundColor Cyan}

}

}


function TwoFactorLogin {

    while ($userLoggedIn -eq $false) {

        
        while ($userAuthenticated -eq $false) {
        
        
            LoginDCSystem
            $global:retrieve1 = $null
            GetDCOTPKey | Out-Null
            $authInfo = $global:retrieve1

            $jsonResponse1 = ($authInfo.Content | ConvertFrom-Json)
			Write-Host $jsonResponse1
            $foundError = $jsonResponse1 -like "*10001*"

            if (!($foundError)) {
                    $jsonResponse2 = $jsonResponse1.message_response
                    $jsonResponse3 = $jsonResponse2.authentication
                    $jsonResponse4 = $jsonResponse3.two_factor_data
            
					Write-Host " aaaaa"
                    $global:uniqueUserID = $jsonResponse4.unique_userID

                    if ($global:uniqueUserID -ne $null) {
        
                        $userAuthenticated = $true
                        $global:uniqueUserID
                        Write-Host "Successfully received OTP" -ForegroundColor Green
        
                    }
            }
            else {
                Write-Host "Your user account was either locked out or your password is invalid." -ForegroundColor Red
            }


        }


        Write-Host "Enter your OTP Key from your authenticator app:"
        $global:OTPNum = Read-Host
        $global:retrieve2 = $null
        SubmitOTPChallenge | Out-Null
        $otpInfo = $global:retrieve2
        


        $otpInfo.Content


        $jsonResponse1 = ($otpInfo.Content)
        $jsonResponse2 = $jsonResponse1 | ConvertFrom-Json
        $jsonResponse3 = $jsonResponse2.message_response
        $jsonResponse4 = $jsonResponse3.authentication
        $jsonResponse5 = $jsonResponse4.auth_data
        $authKey = $jsonResponse5.auth_token

        if ($authKey.length -ge 3) {
        
                $userLoggedIn = $true
                $global:authKey
                Write-Host "Successfully authenticated OTP" -ForegroundColor Green
                $global:dcToken = $authKey
                Write-Host "Completed authentication." -ForegroundColor Green 
            }
            else {
                $userAuthenticated = $false
                Write-Host "OTP Authentication failed, please start over." -ForegroundColor Red

                Write-Host
                Write-Host
            }

    }


}

function StartQuery {



$fullURI = "https://$dcServerName`:$dcServerPort/api/1.3/inventory"
$servicePoint3 = [System.Net.ServicePointManager]::FindServicePoint($fullURI)
    $urlSOM = @{
   
   
        ContentType = 'application/json'
        URI = $fullURI
        Method = 'GET'
       Headers = @{'Authorization'=$global:dcToken
      ; "Accept"= "application/json"}
    }
    
    $jsonContent = $null
    $global:fullJsonIn = $null
    
          
    $jsonContent = Invoke-WebRequest @urlSOM -UseBasicParsing

    $jsonResponse = ($jsonContent.Content | ConvertFrom-Json)
Out-File -FilePath .\DCScriptout.txt -InputObject $jsonResponse -Append

    $servicePoint3.CloseConnectionGroup($fullURI)


    }




LoginPFSystem
GetPFAPIKey | Out-Null

Write-Host "output here"
$global:retrieve1
#TwoFactorLogin



#StartQuery





    #sleep 10
   

   

  