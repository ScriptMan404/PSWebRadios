$NL = echo ""

$NL
$Search = Read-Host "Search for webradios"

$Webradios = Invoke-RestMethod "https://fr1.api.radio-browser.info/json/stations/search?name=$Search"

$NL
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

$VLCPath = "C:\Program Files\VideoLAN\VLC"
if ($VLCProcess -eq $null) {
    $VLCProcess = Start-Process -WindowStyle Hidden -PassThru -FilePath "vlc.exe" -WorkingDirectory $VLCPath -ArgumentList $WRStream.url_resolved
} else {
    $VLCProcess | Stop-Process
    $VLCProcess = Start-Process -WindowStyle Hidden -PassThru -FilePath "vlc.exe" -WorkingDirectory $VLCPath -ArgumentList $WRStream.url_resolved
}