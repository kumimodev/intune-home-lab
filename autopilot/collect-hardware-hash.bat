:: Collect Autopilot hardware hash for a lab device.
:: Run as administrator.
:: Output folder: C:\ForInTuneEnrolment\

@echo Extracting Autopilot hardware hash...

@powershell -NoProfile -ExecutionPolicy Bypass -Command "& {try { $folderPath = 'C:\ForInTuneEnrolment\'; if (-not (Test-Path $folderPath)) { New-Item -ItemType Directory -Path $folderPath -Force | Out-Null }; Set-Location -Path $folderPath; $env:Path += ';C:\Program Files\WindowsPowerShell\Scripts'; Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned; Install-Script -Name Get-WindowsAutopilotInfo -Force; Get-WindowsAutopilotInfo -OutputFile (\"AutopilotHWID_$($env:USERNAME).csv\"); Write-Host \"Hardware hash exported to $folderPath\" } catch { Write-Host \"Could not extract hardware hash. Run as administrator and check network access to the PowerShell Gallery.\"; exit 1 }}"

@pause
