# Support scripts

Day to day helpers for a home lab tenant. Nothing here stores a password in plain text.

## Files

1. `collect-device-info.bat` writes username, hostname, and BIOS serial to Downloads.
2. `update-os.ps1` installs available Windows updates through PSWindowsUpdate.
3. `install-winget.ps1` installs the latest winget bundle from GitHub releases.
4. `winget-upgrade-all.ps1` upgrades every winget package that will accept silent flags.
5. `enable-vm-platform.ps1` turns on the Virtual Machine Platform feature.
6. `update-defender-signatures.ps1` refreshes Microsoft Defender signatures.
7. `create-local-lab-user.ps1` creates a standard local user after a SecureString prompt, with a note about Windows LAPS.
8. `new-scan-share.ps1` creates a local scan folder and SMB share after a SecureString prompt.
9. `invoke-64bit-powershell.snippet.ps1` is the SysNative relaunch header for Win32 scripts.
10. `reset-winsock.bat` runs `netsh winsock reset` only. Reboot afterwards.
