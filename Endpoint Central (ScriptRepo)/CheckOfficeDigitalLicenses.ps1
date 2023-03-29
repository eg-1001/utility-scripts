cls
if (test-path "${env:PROGRAMDATA}\Microsoft\Office\Licenses") {
GCI "${env:PROGRAMDATA}\Microsoft\Office\Licenses\5\Perpetual"
}
else {Write-Error "No digital licenses found"}