# Requires a CSV in the current directory with the following column data:
# Extension, FirstName, LastName


$csvConvertList = Get-ChildItem -Path .\ -Filter *.csv

$csvConvertList | foreach {

    $currentFile = $_

    $userTable = Import-Csv -Path $_.FullName -Header primaryExtension, firstName, lastName

    $itemTest1 = $_.Name
    $itemTest2 = ($itemTest1.Substring(0,($itemTest1.length)-3))
    $bomtxtFileName = $itemTest2+"bomtxt"

    Remove-Item $bomtxtFileName -ErrorAction SilentlyContinue


    $userTable | foreach {



        $vcardBegin = "BEGIN:VCARD"
        $vcardVersion = "VERSION:2.1"
        $vcardFullName = "FN:ACCU_" + $_.FirstName + " " + $_.LastName
        $vcardNames = "N:" + $_.FirstName + " " + $_.LastName + ";" + "ACCU_" + ";;;"
        #if (!(($_.CellPhone).Length -lt 2)) {$vcardMobilePhone = "TEL;CELL:" + $_.CellPhone}
        #else {$_.CellPhone -eq $null} 
        $vcardWorkPhone = "TEL;WORK:626-208-" + $_.primaryExtension
        $vcardEnd = "END:VCARD"

        $fullVCard = $vcardBegin, $vcardVersion, $vcardFullName, $vcardNames, $vcardWorkPhone, $vcardEnd

        if ($_.FirstName -ne "FirstName") {$fullVCard | Out-File -FilePath .\$bomtxtFileName -Append -Encoding utf8}
        

    }







    Write-Host "Processed file $_" -ForegroundColor Yellow

   



}


Write-Host "Recoding Files with BOM properties" -ForegroundColor Cyan


$bomtxtConvertList = Get-ChildItem -Path .\ -Filter *.bomtxt

$bomtxtConvertList | foreach {

    $itemTest1 = $_.Name
    $itemTest2 = ($itemTest1.Substring(0,($itemTest1.length)-6))
    $vcfFileName = $itemTest2+"vcf"
    
    
    $currentTxt = Get-Content -Raw $_.FullName





    $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

    [System.IO.File]::WriteAllLines($vcfFileName, $currentTxt, $utf8NoBomEncoding)

    Remove-Item $_.FullName -ErrorAction SilentlyContinue

}



 sleep 3