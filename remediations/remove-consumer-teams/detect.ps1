#Requires -Version 5.1
<#
.SYNOPSIS
  Detection for the Windows 11 consumer Microsoft Teams AppX package.

.DESCRIPTION
  Exit 0 when the package is not present. Exit 1 when remediation should remove it.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$pkg = Get-AppxPackage -Name 'MicrosoftTeams' -ErrorAction SilentlyContinue

if ($null -eq $pkg) {
    Write-Output 'Microsoft Teams consumer client not found.'
    exit 0
}

Write-Output 'Microsoft Teams consumer client found.'
exit 1
