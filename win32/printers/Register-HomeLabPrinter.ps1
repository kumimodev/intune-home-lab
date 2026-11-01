#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Registers a TCP or hostname based printer for an Intune Win32 lab package.

.DESCRIPTION
  Intended to ship inside an .intunewin payload next to a vendor INF.
  Steps use only Microsoft documented tools and cmdlets:
  pnputil.exe /add-driver, Add-PrinterDriver, Add-PrinterPort, Add-Printer.
  When Intune starts a 32 bit host on 64 bit Windows, the script relaunches
  through SysNative PowerShell so printer cmdlets see the 64 bit stack.
  Progress is appended under %ProgramData%\IntuneHomeLab\PrinterSetup.

.PARAMETER PrinterName
  Display name shown in Windows.

.PARAMETER DriverName
  Printer driver name exactly as listed in the INF.

.PARAMETER InfPath
  Path to the INF inside the Win32 package folder (or an absolute lab path).

.PARAMETER PortHost
  DNS name or IPv4 address of the printer. Example: printer.lab.local

.PARAMETER PortName
  Optional port object name. Defaults to IP_<PortHost> with dots turned into underscores.

.PARAMETER SetAsDefault
  Makes this printer the user default after a successful add.

.EXAMPLE
  .\Register-HomeLabPrinter.ps1 -PrinterName 'Lab Floor Printer' -DriverName 'Contoso Laser Class Driver' -InfPath '.\driver\contoso.inf' -PortHost 'printer.lab.local'

.EXAMPLE
  .\Register-HomeLabPrinter.ps1 -PrinterName 'Lab Floor Printer' -DriverName 'Contoso Laser Class Driver' -InfPath '.\driver\contoso.inf' -PortHost '10.0.0.50' -SetAsDefault
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PrinterName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$DriverName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$InfPath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PortHost,

    [string]$PortName,

    [switch]$SetAsDefault
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsWow64Process {
    return ($env:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
}

function Invoke-Wow64Relaunch {
    if (-not (Test-IsWow64Process)) {
        return
    }
    $native = Join-Path $env:WINDIR 'SysNative\WindowsPowerShell\v1.0\PowerShell.exe'
    if (-not (Test-Path -LiteralPath $native)) {
        throw 'SysNative PowerShell was not found. Cannot continue from a 32 bit host.'
    }
    $argList = @(
        '-NoProfile'
        '-ExecutionPolicy', 'Bypass'
        '-File', $PSCommandPath
        '-PrinterName', $PrinterName
        '-DriverName', $DriverName
        '-InfPath', $InfPath
        '-PortHost', $PortHost
    )
    if ($PortName) { $argList += @('-PortName', $PortName) }
    if ($SetAsDefault) { $argList += '-SetAsDefault' }
    $proc = Start-Process -FilePath $native -ArgumentList $argList -Wait -PassThru -NoNewWindow
    exit $proc.ExitCode
}

function Get-PrinterSetupLogPath {
    $root = Join-Path $env:ProgramData 'IntuneHomeLab\PrinterSetup'
    if (-not (Test-Path -LiteralPath $root)) {
        New-Item -ItemType Directory -Path $root -Force | Out-Null
    }
    $safe = ($PrinterName -replace '[<>:"/\\|?*]', '_')
    return (Join-Path $root ($safe + '-setup.log'))
}

function Write-PrinterSetupLog {
    param([string]$Message)
    $line = '{0:yyyy-MM-dd HH:mm:ss} {1}' -f (Get-Date), $Message
    Add-Content -LiteralPath (Get-PrinterSetupLogPath) -Value $line -Encoding UTF8
    Write-Verbose $Message
}

Invoke-Wow64Relaunch

if (-not $PortName) {
    $PortName = 'IP_' + ($PortHost -replace '\.', '_')
}

$resolvedInf = $InfPath
if (-not [System.IO.Path]::IsPathRooted($InfPath)) {
    $resolvedInf = Join-Path $PSScriptRoot $InfPath
}
if (-not (Test-Path -LiteralPath $resolvedInf)) {
    Write-Error "INF not found: $resolvedInf"
    exit 1
}

Write-PrinterSetupLog "Begin register PrinterName=$PrinterName DriverName=$DriverName PortHost=$PortHost PortName=$PortName Inf=$resolvedInf"

try {
    Write-PrinterSetupLog 'Staging driver package with pnputil'
    $pnputil = Join-Path $env:SystemRoot 'System32\pnputil.exe'
    $stage = Start-Process -FilePath $pnputil -ArgumentList @('/add-driver', $resolvedInf, '/install') -Wait -PassThru -NoNewWindow
    # 0 success, 259 already present on some builds
    if ($stage.ExitCode -notin 0, 259) {
        throw "pnputil /add-driver failed with exit code $($stage.ExitCode)"
    }

    if (-not (Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue)) {
        Write-PrinterSetupLog "Add-PrinterDriver $DriverName"
        Add-PrinterDriver -Name $DriverName
    }
    else {
        Write-PrinterSetupLog "Driver already registered: $DriverName"
    }

    if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue)) {
        Write-PrinterSetupLog "Add-PrinterPort $PortName -> $PortHost"
        Add-PrinterPort -Name $PortName -PrinterHostAddress $PortHost
    }
    else {
        Write-PrinterSetupLog "Port already present: $PortName"
    }

    $existing = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-PrinterSetupLog "Printer already present, refreshing link to driver/port: $PrinterName"
        Remove-Printer -Name $PrinterName
    }

    Write-PrinterSetupLog "Add-Printer $PrinterName"
    Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName

    if (-not (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue)) {
        throw 'Add-Printer returned without creating the printer object.'
    }

    if ($SetAsDefault) {
        Write-PrinterSetupLog "Setting default printer: $PrinterName"
        $printerObject = Get-CimInstance -ClassName Win32_Printer -Filter ("Name='" + $PrinterName.Replace("'", "\'") + "'")
        if ($printerObject) {
            Invoke-CimMethod -InputObject $printerObject -MethodName SetDefaultPrinter | Out-Null
        }
    }

    Write-PrinterSetupLog 'Register completed successfully'
    Write-Output "Registered printer '$PrinterName' on port '$PortName'."
    exit 0
}
catch {
    Write-PrinterSetupLog ("Register FAILED: " + $_.Exception.Message)
    Write-Error $_.Exception.Message
    exit 1
}
