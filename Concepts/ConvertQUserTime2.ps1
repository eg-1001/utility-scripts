#this should be the number from QUser!
$num = 246



$fullMinHour = (New-TimeSpan -Minutes $num)

Write-Host $fullMinHour