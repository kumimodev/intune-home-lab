#Requires -Version 5.1
<#
.SYNOPSIS
  Merges Autopilot hardware hash CSV files in a folder into one file.

.DESCRIPTION
  Reads every CSV in -Path except the merge output name.
  Optionally stamps a Group Tag on every row.

.PARAMETER Path
  Folder that holds Autopilot CSV files. Defaults to the script directory.

.PARAMETER GroupTag
  Optional Autopilot Group Tag applied to every merged row.

.PARAMETER OutputFileName
  Name of the merged CSV. Default is merged-hardware-hash.csv.

.EXAMPLE
  .\Merge-AutopilotHardwareHash.ps1

.EXAMPLE
  .\Merge-AutopilotHardwareHash.ps1 -GroupTag 'LAB'
#>
[CmdletBinding()]
param(
    [string]$Path = $PSScriptRoot,
    [string]$GroupTag,
    [string]$OutputFileName = 'merged-hardware-hash.csv'
)

$ErrorActionPreference = 'Stop'

if (-not $Path) {
    $Path = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$csvFiles = Get-ChildItem -File -Path (Join-Path $Path '*.csv') |
    Where-Object { $_.Name -ne $OutputFileName } |
    Select-Object -ExpandProperty FullName

if (-not $csvFiles) {
    Write-Error "No CSV files found in $Path"
    exit 1
}

$combined = foreach ($file in $csvFiles) {
    Import-Csv -Path $file
}

$outFile = Join-Path $Path $OutputFileName
if ($PSBoundParameters.ContainsKey('GroupTag') -and $GroupTag) {
    $combined |
        Select-Object *, @{ Name = 'Group Tag'; Expression = { $GroupTag } } |
        Export-Csv -Path $outFile -NoTypeInformation
    Write-Output "Wrote $outFile with Group Tag $GroupTag"
}
else {
    $combined |
        Select-Object -Property * -Unique |
        Export-Csv -Path $outFile -NoTypeInformation
    Write-Output "Wrote $outFile"
}
exit 0
