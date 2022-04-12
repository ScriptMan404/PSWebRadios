<# AUTHOR https://github.com/ScriptMan404
THIS SCRIPT DEPENDS ON VLC, PLEASE MAKE SURE THAT YOU HAVE VLC INSTALLED ON YOUR SYSTEM
THIS SCRIPT USES RADIO BROWSER API : https://api.radio-browser.info/ #>

param (
    $Search
)

$Language = Get-Culture | Select-Object Name
$NL = Write-Output ""

$NL

$VLCExisting = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "VLC media player"}

if ($VLCExisting -eq $null) {
    if ($Language.Name -like "fr-*") {
        Write-Host -ForegroundColor Red "LE LECTEUR MULTIMEDIA VLC N'EST PAS INSTALLE ! LIEN DE TELECHARGEMENT > https://www.videolan.org/vlc "
    } else {
        Write-Host -ForegroundColor Red "VLC MEDIA PLAYER IS NOT INSTALLED ! DOWNLOAD LINK > https://www.videolan.org/vlc"
    }
    exit
}

if ($WEBHOST -eq $null) {
    $PINGCount = 1
    $FR1 = (Test-Connection "fr1.api.radio-browser.info" -Quiet -Count $PINGCount)
    $DE1 = (Test-Connection "de1.api.radio-browser.info" -Quiet -Count $PINGCount)
    $NL1 = (Test-Connection "nl1.api.radio-browser.info" -Quiet -Count $PINGCount)
    if ($FR1 -eq $true) {
        $global:WEBHOST = "fr1.api.radio-browser.info"
    } elseif ($DE1 -eq $true) {
        $global:WEBHOST = "de1.api.radio-browser.info"
    } elseif ($NL1 -eq $true) {
        $global:WEBHOST = "nl1.api.radio-browser.info"
    }
}

if ($Search -like "") {
    if ($Language.Name -like "fr-*") {
        $Search = Read-Host "RECHERCHER DES WEBRADIOS "
    } else {
        $Search = Read-Host "SEARCH FOR WEBRADIOS "
    }
    $NL
}

if ($Search -like "") {
    if ($Language.Name -like "fr-*") {
        Write-Host -ForegroundColor Red "LA VALEUR NE PEUT ETRE NULLE !"
    } else {
        Write-Host -ForegroundColor Red "THE VALUE CANNOT BE NULL !"
    }
    exit
 }

# SEARCHING FOR WEBRADIOS
$Webradios = Invoke-RestMethod "https://$WEBHOST/json/stations/search?name=$Search"

if ($Webradios.Count -eq 0) {
    if ($Language.Name -like "fr-*") {
        Write-Host -ForegroundColor Red "AUCUNE WEBRADIO AVEC LE NOM $Search N'A ETE TROUVEE !".ToUpper()
    } else {
        Write-Host -ForegroundColor Red "NO WEBRADIO WITH THE NAME $Search WAS FOUND !".ToUpper()
    }
    exit
}

$Menu = @{}
for ($i=1;$i -le $Webradios.Count; $i++) {
    Write-Host "|" -NoNewline; Write-Host -ForegroundColor DarkCyan "$i" -NoNewline; Write-Host "| $($Webradios[$i-1].name)"
    $Menu.Add($i,($Webradios[$i-1].name))
}

$NL
$Choice = Read-Host "ENTER WEBRADIO NUMBER "

if ($Choice -match "[a-z]" -or $Choice -match "[A-Z]" -or $Choice -eq "0" -or $Choice -like "") {
    $NL
    if ($Language.Name -like "fr-*") {
        Write-Host -ForegroundColor Red "VOUS DEVEZ FOURNIR UN NOMBRE DIFFERENT DE 0 !"
    } else {
        Write-Host -ForegroundColor Red "YOU MUST PROVIDE A NUMBER NOT EQUAL TO 0 !"
    }
    exit
}

$WRStream = $Webradios[$Choice-1]
$NL

# KILL PREVIOUS VLC WEBRADIO PROCESS
if ($VLCProcess -ne $null) {
    $VLCProcess | Stop-Process
}

# LAUNCHING WEBRADIO STREAM WITH VLC
$VLCPath = "C:\Program Files\VideoLAN\VLC"
$PROCESSOpts = @{
    WindowStyle = "Hidden"
    FilePath = "vlc.exe"
    WorkingDirectory = $VLCPath
    ArgumentList = $WRStream.url_resolved
}
$global:VLCProcess = Start-Process -PassThru @PROCESSOpts

# NOTIFICATION
Add-Type -AssemblyName System.Windows.Forms
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$global:notification = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $VLCProcess.Id).Path
$notification.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$notification.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$notification.BalloonTipText = "♫ ► " + $WRStream.name + " ♫"
$notification.BalloonTipTitle = "VLC media player"
$notification.Visible = $true
$notification.ShowBalloonTip(20000)