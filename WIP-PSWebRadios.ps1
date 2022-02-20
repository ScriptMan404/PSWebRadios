# https://github.com/ScriptMan404 #

# THIS SCRIPT DEPENDS ON VLC, PLEASE MAKE SURE THAT YOU HAVE VLC INSTALLED ON YOUR SYSTEM #

# THIS SCRIPT USES RADIO BROWSER API : https://api.radio-browser.info/ #

$NL = Write-Output ""
$NL
$Search = Read-Host "SEARCH FOR WEBRADIOS "
$NL
if ($Search -like "") {
    Write-Host -ForegroundColor Red "THE VALUE CANNOT BE NULL ! EXITING..."
    exit
 }

# SEARCHING FOR WEBRADIOS
$Webradios = Invoke-RestMethod "https://fr1.api.radio-browser.info/json/stations/search?name=$Search"
if ($Webradios.Count -eq 0) {
    Write-Host -ForegroundColor Red "NO WEBRADIO WITH THE FOLLOWING NAME $Search WAS FOUND ! EXITING...".ToUpper()
    exit
}
$Menu = @{}
for ($i=1;$i -le $Webradios.Count; $i++) {
    Write-Host "|$i| $($Webradios[$i-1].name)"
    $Menu.Add($i,($Webradios[$i-1].name))
}
$NL
$Choice = Read-Host "ENTER THE LINE NUMBER OF THE WEBRADIO YOU WANT TO LISTEN "
if ($Choice -match "[a-z]" -or $Choice -match "[A-Z]" -or $Choice -eq "0" -or $Choice -like "") {
    $NL
    Write-Host -ForegroundColor Red "YOU MUST PROVIDE A NUMBER NOT EQUAL TO 0, EXITING..."
    exit
}
$WRStream = $Webradios[$Choice-1]
$NL
Write-Host -ForegroundColor Green "NOW PLAYING :" $WRStream.name
$NL

# KILL PREVIOUS VLC WEBRADIO PROCESS
if ($VLCProcess -ne $null) {
    $VLCProcess | Stop-Process
}

# LAUNCH WEBRADIO STREAM WITH VLC
$VLCPath = "C:\Program Files\VideoLAN\VLC"
$global:VLCProcess = Start-Process -WindowStyle Hidden -PassThru -FilePath "vlc.exe" -WorkingDirectory $VLCPath -ArgumentList $WRStream.url_resolved