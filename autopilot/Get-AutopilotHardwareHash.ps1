#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Collects an Autopilot hardware hash CSV for a lab device.

.DESCRIPTION
  Installs Get-WindowsAutopilotInfo from the PowerShell Gallery if needed,
  then writes a CSV under the output folder.

.PARAMETER OutputDirectory
  Folder for the CSV. Default is C:\LabAutopilot.

.EXAMPLE
  .\Get-AutopilotHardwareHash.ps1
#>
[CmdletBinding()]
param(
    [string]$OutputDirectory = 'C:\LabAutopilot'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

$env:Path += ';C:\Program Files\WindowsPowerShell\Scripts'
if (-not (Get-Command Get-WindowsAutopilotInfo -ErrorAction SilentlyContinue)) {
    Install-Script -Name Get-WindowsAutopilotInfo -Force -Scope CurrentUser
}

$outFile = Join-Path $OutputDirectory ("AutopilotHWID_{0}.csv" -f $env:USERNAME)
Get-WindowsAutopilotInfo -OutputFile $outFile
Write-Output "Hardware hash exported to $outFile"
exit 0
