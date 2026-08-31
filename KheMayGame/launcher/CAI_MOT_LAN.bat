@echo off
setlocal
set "DEST=%LOCALAPPDATA%\KheMayLauncher"
if not exist "%DEST%" mkdir "%DEST%"
copy /Y "%~dp0KheMay_Launcher.ps1" "%DEST%\KheMay_Launcher.ps1" >nul
copy /Y "%~dp0CHAY_KHE_MAY.bat" "%DEST%\CHAY_KHE_MAY.bat" >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$d=[Environment]::GetFolderPath('Desktop'); $s=(New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $d 'Khe May.lnk')); $s.TargetPath='%DEST%\CHAY_KHE_MAY.bat'; $s.WorkingDirectory='%DEST%'; $s.IconLocation='$env:SystemRoot\System32\shell32.dll,23'; $s.Save()"
start "" "%DEST%\CHAY_KHE_MAY.bat"
endlocal
