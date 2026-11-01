#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Removes a lab printer previously registered by Register-HomeLabPrinter.ps1.

.DESCRIPTION
  Removes the printer with Remove-Printer. Optionally removes the matching
  printer port with Remove-PrinterPort when -RemovePort is set and no other
  printer still uses that port. Idempotent when the printer is already gone.
  Relaunches in 64 bit PowerShell under WOW64. Logs under ProgramData.

.PARAMETER PrinterName
  Display name of the printer to remove.

.PARAMETER PortName
  Optional port to remove after the printer is gone.

.PARAMETER RemovePort
  Also remove PortName when nothing else references it.

.EXAMPLE
  .\Unregister-HomeLabPrinter.ps1 -PrinterName 'Lab Floor Printer'

.EXAMPLE
  .\Unregister-HomeLabPrinter.ps1 -PrinterName 'Lab Floor Printer' -PortName 'IP_printer_lab_local' -RemovePort
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PrinterName,

    [string]$PortName,

    [switch]$RemovePort
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Wow64Relaunch {
    if ($env:PROCESSOR_ARCHITEW6432 -ne 'AMD64') {
        return
    }
    $native = Join-Path $env:WINDIR 'SysNative\WindowsPowerShell\v1.0\PowerShell.exe'
    $argList = @(
        '-NoProfile'
        '-ExecutionPolicy', 'Bypass'
        '-File', $PSCommandPath
        '-PrinterName', $PrinterName
    )
    if ($PortName) { $argList += @('-PortName', $PortName) }
    if ($RemovePort) { $argList += '-RemovePort' }
    $proc = Start-Process -FilePath $native -ArgumentList $argList -Wait -PassThru -NoNewWindow
    exit $proc.ExitCode
}

function Write-PrinterSetupLog {
    param([string]$Message)
    $root = Join-Path $env:ProgramData 'IntuneHomeLab\PrinterSetup'
    if (-not (Test-Path -LiteralPath $root)) {
        New-Item -ItemType Directory -Path $root -Force | Out-Null
    }
    $safe = ($PrinterName -replace '[<>:"/\\|?*]', '_')
    $log = Join-Path $root ($safe + '-remove.log')
    $line = '{0:yyyy-MM-dd HH:mm:ss} {1}' -f (Get-Date), $Message
    Add-Content -LiteralPath $log -Value $line -Encoding UTF8
    Write-Verbose $Message
}

Invoke-Wow64Relaunch

try {
    Write-PrinterSetupLog "Begin unregister PrinterName=$PrinterName"

    if (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue) {
        Remove-Printer -Name $PrinterName
        Write-PrinterSetupLog "Removed printer $PrinterName"
        Write-Output "Removed printer '$PrinterName'."
    }
    else {
        Write-PrinterSetupLog "Printer already absent: $PrinterName"
        Write-Output "Printer '$PrinterName' was not present."
    }

    if ($RemovePort -and $PortName) {
        $stillUsed = Get-Printer -ErrorAction SilentlyContinue | Where-Object { $_.PortName -eq $PortName }
        if ($stillUsed) {
            Write-PrinterSetupLog "Port $PortName still in use, leaving it in place"
        }
        elseif (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue) {
            Remove-PrinterPort -Name $PortName
            Write-PrinterSetupLog "Removed port $PortName"
            Write-Output "Removed port '$PortName'."
        }
    }

    Write-PrinterSetupLog 'Unregister completed'
    exit 0
}
catch {
    Write-PrinterSetupLog ("Unregister FAILED: " + $_.Exception.Message)
    Write-Error $_.Exception.Message
    exit 1
}
