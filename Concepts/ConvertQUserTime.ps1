#this should be the number from QUser!
$num = 246



#hours convert code
$decHours = $num / 60
$decHours

$fullHours = [math]::Truncate($decHours)



#minutes convert code

$decMinutes = $num - ($fullHours * 60) 

if ($decMinutes -lt 10) {
    $fullMinutes = "0$decMinutes"
}
else {
    $fullMinutes = "$decMinutes"
}


#time output code

$fullTime = "$fullHours`:$fullMinutes"

Write-Host $fullTime