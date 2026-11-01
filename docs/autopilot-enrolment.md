# Autopilot enrolment notes

These notes match the scripts in `autopilot/`.

## Collect a hardware hash

1. Sign in to the device as a local admin, or open an elevated command prompt from WinPE if you are that far along.
2. Copy `collect-hardware-hash.bat` to the device.
3. Run it as administrator.
4. Accept the PowerShell Gallery prompts for `Get-WindowsAutopilotInfo` if this is the first run.
5. Find the CSV under `C:\ForInTuneEnrolment\`.

The file name includes the current username so you can tell devices apart when you gather several hashes.

## Collect username, hostname, and serial

`scripts/collect-device-info.bat` writes a small text file to the current user Downloads folder. It is handy when you want a quick label for the Autopilot record without opening System Information by hand.

## Merge several CSV files

1. Put every Autopilot CSV in one folder with `merge-hardware-hash.ps1`.
2. Run the script in PowerShell.
3. Upload `merged-hardware-hash.csv` to Intune.

If you want a Group Tag on every row, use `merge-hardware-hash-with-tag.ps1` and edit the tag value at the top of the file. The sample tag is `LAB`. Change it to whatever your Autopilot profile filters on.

## Import into Intune

1. Open Microsoft Intune admin centre.
2. Go to Devices, then Enroll devices, then Windows Autopilot devices.
3. Import the CSV.
4. Assign a deployment profile and, if you use them, an Enrolment Status Page profile.
5. Soft wipe or Autopilot reset the device, then enrol again.

## Common gotchas

1. Hash collection needs admin rights and outbound access to install the gallery script the first time.
2. The Group Tag in the CSV must match the filter on your Autopilot profile or the profile will not apply.
3. Hybrid join needs extra connectivity and a domain join connector. This lab sticks to Entra ID join only.
4. Keep the CSV out of public chats. It identifies the device hardware.
