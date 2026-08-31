$ErrorActionPreference = 'Stop'

$VersionUrl = 'https://raw.githubusercontent.com/Gamevalentine/CoupleHunt3D-Web/khemay-game/KheMayGame/dist/latest-version.txt'
$BuildUrl   = 'https://github.com/Gamevalentine/CoupleHunt3D-Web/releases/download/khemay-latest/KheMay-Windows.zip'
$InstallDir = Join-Path $env:LOCALAPPDATA 'KheMayGame'
$VersionFile = Join-Path $InstallDir 'version.txt'
$ExePath = Join-Path $InstallDir 'NguoiTrucCuoiCung.exe'

function Read-LocalVersion {
    if (Test-Path $VersionFile) { return (Get-Content $VersionFile -Raw).Trim() }
    return ''
}

function Start-Game {
    if (-not (Test-Path $ExePath)) { throw "Không tìm thấy game tại $ExePath" }
    Start-Process -FilePath $ExePath -WorkingDirectory $InstallDir
}

try {
    $remoteVersion = (Invoke-WebRequest -UseBasicParsing -Uri $VersionUrl -TimeoutSec 15).Content.Trim()
    $localVersion = Read-LocalVersion

    if (($remoteVersion -ne $localVersion) -or (-not (Test-Path $ExePath))) {
        Write-Host 'Đang tải bản Khe Mây mới nhất...'
        $tempRoot = Join-Path $env:TEMP ('KheMayUpdate_' + [guid]::NewGuid().ToString('N'))
        $zipPath = Join-Path $tempRoot 'KheMay-Windows.zip'
        $extractDir = Join-Path $tempRoot 'game'
        New-Item -ItemType Directory -Force -Path $extractDir | Out-Null

        Invoke-WebRequest -UseBasicParsing -Uri $BuildUrl -OutFile $zipPath -TimeoutSec 300
        Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

        if (-not (Test-Path (Join-Path $extractDir 'NguoiTrucCuoiCung.exe'))) {
            throw 'Bản tải về không có NguoiTrucCuoiCung.exe.'
        }

        if (Test-Path $InstallDir) {
            Get-ChildItem -LiteralPath $InstallDir -Force | Remove-Item -Recurse -Force
        } else {
            New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
        }

        Copy-Item -Path (Join-Path $extractDir '*') -Destination $InstallDir -Recurse -Force
        Set-Content -Path $VersionFile -Value $remoteVersion -NoNewline
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }

    Start-Game
}
catch {
    if (Test-Path $ExePath) {
        Write-Warning ('Không kiểm tra được bản mới: ' + $_.Exception.Message)
        Start-Game
    } else {
        Add-Type -AssemblyName PresentationFramework
        [System.Windows.MessageBox]::Show(
            "Không thể cài/chạy Khe Mây.`n`n$($_.Exception.Message)",
            'Người Trực Cuối Cùng'
        ) | Out-Null
        exit 1
    }
}
