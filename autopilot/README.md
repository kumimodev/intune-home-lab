# Autopilot helpers

| Script | Purpose |
| --- | --- |
| `Get-AutopilotHardwareHash.ps1` | Collect a hardware hash CSV (needs Gallery script `Get-WindowsAutopilotInfo`) |
| `Merge-AutopilotHardwareHash.ps1` | Merge CSV files in a folder, optional `-GroupTag` |

Run the collector elevated on the lab device. Merge on any admin workstation that holds the CSV files.
