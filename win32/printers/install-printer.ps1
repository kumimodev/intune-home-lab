<#
.SYNOPSIS
  Install a TCP/IP printer from an INF based driver for a lab Win32 app.

.DESCRIPTION
  Stages the driver with pnputil, adds the printer driver, creates a port, then adds the printer.
  Sample values use 10.0.0.x style addresses only. Replace them for your lab.

.EXAMPLE
  powershell.exe -ExecutionPolicy Bypass -File .\install-printer.ps1 -PortName "IP_10.0.0.50" -PrinterIP "10.0.0.50" -PrinterName "Lab Printer 01" -DriverName "Generic Lab Driver" -INFFile "labprinter.inf"
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [String]$PortName,
    [Parameter(Mandatory = $true)]
    [String]$PrinterIP,
    [Parameter(Mandatory = $true)]
    [String]$PrinterName,
    [Parameter(Mandatory = $true)]
    [String]$DriverName,
    [Parameter(Mandatory = $true)]
    [String]$INFFile
)

$scriptFailed = $false

if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64') {
    try {
        & "$ENV:WINDIR\SysNative\WindowsPowerShell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH -PortName $PortName -PrinterIP $PrinterIP -DriverName $DriverName -PrinterName $PrinterName -INFFile $INFFile
    }
    catch {
        Write-Error "Failed to start $PSCOMMANDPATH"
        Write-Warning $_.Exception.Message
        $scriptFailed = $true
    }
    exit
}

function Write-LogEntry {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [string]$FileName = "$PrinterName.log",
        [switch]$Stamp
    )

    $logDir = 'C:\temp'
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $LogFile = Join-Path $logDir $FileName
    $Time = Get-Date -Format 'HH:mm:ss.fff'
    $Date = Get-Date -Format 'yyyy-MM-dd'

    if ($Stamp) {
        $LogText = "<$Value> <time=`"$Time`" date=`"$Date`">"
    }
    else {
        $LogText = $Value
    }

    try {
        Out-File -InputObject $LogText -Append -NoClobber -Encoding utf8 -FilePath $LogFile -ErrorAction Stop
    }
    catch {
        Write-Warning "Unable to write log entry to $LogFile"
    }
}

Write-LogEntry -Value '##################################'
Write-LogEntry -Stamp -Value 'Installation started'
Write-LogEntry -Value '##################################'
Write-LogEntry -Value "Port Name: $PortName"
Write-LogEntry -Value "Printer IP: $PrinterIP"
Write-LogEntry -Value "Printer Name: $PrinterName"
Write-LogEntry -Value "Driver Name: $DriverName"
Write-LogEntry -Value "INF File: $INFFile"

if (-not $scriptFailed) {
    try {
        Write-LogEntry -Stamp -Value "Staging driver from INF $INFFile"
        Start-Process -FilePath pnputil.exe -ArgumentList @('/add-driver', $INFFile) -Wait -PassThru | Out-Null
    }
    catch {
        Write-Warning 'Error staging driver to the driver store'
        Write-LogEntry -Stamp -Value $_.Exception.Message
        $scriptFailed = $true
    }
}

if (-not $scriptFailed) {
    try {
        $DriverExist = Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue
        if (-not $DriverExist) {
            Write-LogEntry -Stamp -Value "Adding printer driver $DriverName"
            Add-PrinterDriver -Name $DriverName -Confirm:$false
        }
        else {
            Write-LogEntry -Stamp -Value "Printer driver $DriverName already exists"
        }
    }
    catch {
        Write-Warning 'Error installing printer driver'
        Write-LogEntry -Stamp -Value $_.Exception.Message
        $scriptFailed = $true
    }
}

if (-not $scriptFailed) {
    try {
        $PortExist = Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue
        if (-not $PortExist) {
            Write-LogEntry -Stamp -Value "Adding port $PortName"
            Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP -Confirm:$false
        }
        else {
            Write-LogEntry -Stamp -Value "Port $PortName already exists"
        }
    }
    catch {
        Write-Warning 'Error creating printer port'
        Write-LogEntry -Stamp -Value $_.Exception.Message
        $scriptFailed = $true
    }
}

if (-not $scriptFailed) {
    try {
        $PrinterExist = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
        if ($PrinterExist) {
            Write-LogEntry -Stamp -Value "Removing existing printer $PrinterName"
            Remove-Printer -Name $PrinterName -Confirm:$false
        }

        Write-LogEntry -Stamp -Value "Adding printer $PrinterName"
        Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName -Confirm:$false

        if (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue) {
            Write-LogEntry -Stamp -Value "Printer $PrinterName added successfully"
        }
        else {
            Write-Warning 'Printer object was not created'
            $scriptFailed = $true
        }
    }
    catch {
        Write-Warning 'Error creating printer'
        Write-LogEntry -Stamp -Value $_.Exception.Message
        $scriptFailed = $true
    }
}

if ($scriptFailed) {
    Write-Error 'Printer installation failed. Check C:\temp for the log file.'
    Write-LogEntry -Stamp -Value 'Installation failed'
    exit 1
}

Write-LogEntry -Stamp -Value 'Installation completed'
exit 0
