#Requires -Version 5.1
<#
.SYNOPSIS
  Intune Win32 detection helper for a lab printer by display name.

.DESCRIPTION
  Uses Get-Printer only. Exit 0 when the printer exists (detected).
  Exit 1 when it does not (not detected). Suitable as the Intune detection script.

.PARAMETER PrinterName
  Display name that Register-HomeLabPrinter.ps1 created.

.EXAMPLE
  .\Test-HomeLabPrinter.ps1 -PrinterName 'Lab Floor Printer'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PrinterName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$printer = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
if ($printer) {
    Write-Output "Detected printer '$PrinterName'."
    exit 0
}

Write-Output "Printer '$PrinterName' not detected."
exit 1
