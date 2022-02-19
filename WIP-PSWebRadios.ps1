$NL = echo ""

echo $VLCProcess

$NL
$Search = Read-Host "Search for webradios"
$NL

$Webradios = Invoke-RestMethod "https://fr1.api.radio-browser.info/json/stations/search?name=$Search"

$Menu = @{}
    for ($i=1;$i -le $Webradios.Count; $i++) {
        Write-Host "$i. $($Webradios[$i-1].name)"
        $Menu.Add($i,($Webradios[$i-1].name))
    }
$NL
[int]$Choice = Read-Host "Enter selection"
$WRStream = $Webradios[$Choice-1]

$NL
Write-Host -ForegroundColor Green "Now playing :" $WRStream.name
$NL

$VLCPath = "C:\Program Files\VideoLAN\VLC"
if ($VLCProcess -eq $null) {
    $global:VLCProcess = Start-Process -WindowStyle Hidden -PassThru -FilePath "vlc.exe" -WorkingDirectory $VLCPath -ArgumentList $WRStream.url_resolved
} else {
    $VLCProcess | Stop-Process
    $global:VLCProcess = Start-Process -WindowStyle Hidden -PassThru -FilePath "vlc.exe" -WorkingDirectory $VLCPath -ArgumentList $WRStream.url_resolved
}