<#
.SYNOPSIS
  Remove a lab printer by name.

.EXAMPLE
  powershell.exe -ExecutionPolicy Bypass -File .\uninstall-printer.ps1 -PrinterName "Lab Printer 01"
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [String]$PrinterName
)

$printer = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
if ($printer) {
    Remove-Printer -Name $PrinterName -Confirm:$false
    Write-Host "Removed printer $PrinterName"
    exit 0
}

Write-Host "Printer $PrinterName was not found"
exit 0
