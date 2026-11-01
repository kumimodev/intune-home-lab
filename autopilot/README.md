# Autopilot helpers

Collect hardware hashes on lab devices, then merge the CSV files before you import them into Intune.

## Scripts

1. `collect-hardware-hash.bat` installs `Get-WindowsAutopilotInfo` from the PowerShell Gallery and writes a CSV to `C:\ForInTuneEnrolment\`.
2. `merge-hardware-hash.ps1` combines every CSV in the script folder into `merged-hardware-hash.csv`.
3. `merge-hardware-hash-with-tag.ps1` does the same and adds a Group Tag column. Edit the tag at the top of the script.

Run the batch file as administrator. Keep the merged CSV private to your lab.
