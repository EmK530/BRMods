@echo off
cls
if exist "%cd%\NativeResolution.gd" goto:skip
echo NativeResolution not found, downloading...
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/EmK530/BRMods/main/Batch/NativeResolution/mod_main.gd', 'NativeResolution.gd')"
start /B "" "Buckshot Roulette.exe" --script "%cd%\NativeResolution.gd"
exit
