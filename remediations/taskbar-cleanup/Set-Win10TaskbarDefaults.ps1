#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Trims Windows 10 taskbar defaults for the current user and the Default profile.

.DESCRIPTION
  Applies selected registry values under HKCU and under the Default user hive.
  Pass one or more switches. Doing nothing when no switch is set returns an error.

.EXAMPLE
  .\Set-Win10TaskbarDefaults.ps1 -RemoveNews -RemoveSearchBar -RemoveTaskView
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$RemoveNews,
    [switch]$RemoveSearchBar,
    [switch]$RemoveTaskView
)

$ErrorActionPreference = 'Stop'
if (-not $PSCmdlet.ShouldProcess('Windows 10 taskbar defaults', 'Apply taskbar defaults')) {
    return
}


if (-not ($RemoveNews -or $RemoveSearchBar -or $RemoveTaskView)) {
    Write-Error 'Specify at least one of -RemoveNews, -RemoveSearchBar, -RemoveTaskView.'
    exit 1
}

if ($env:PROCESSOR_ARCHITEW6432 -eq 'AMD64') {
    $sysNative = Join-Path $env:WINDIR 'SysNative\WindowsPowerShell\v1.0\PowerShell.exe'
    & $sysNative -ExecutionPolicy Bypass -NoProfile -File $PSCommandPath @PSBoundParameters
    exit $LASTEXITCODE
}

function Write-TaskbarDword {
    param(
        [string]$Root,
        [string]$RelativePath,
        [string]$Name,
        [int]$Value
    )
    $path = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    New-ItemProperty -Path $path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
}

$markerKey = 'HKCU:\SOFTWARE\IntuneHomeLab\Taskbar'
if (-not (Test-Path -LiteralPath $markerKey)) {
    New-Item -Path $markerKey -Force | Out-Null
}
New-ItemProperty -Path $markerKey -Name 'CustomizeTaskbar' -Value '1' -PropertyType String -Force | Out-Null

$hiveLoaded = $false
try {
    & reg.exe load 'HKU\DefaultUser' 'C:\Users\Default\NTUSER.DAT' | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not load Default user hive.' }
    $hiveLoaded = $true

    $targets = @('HKCU:', 'Registry::HKEY_USERS\DefaultUser')
    foreach ($root in $targets) {
        if ($RemoveNews) {
            Write-TaskbarDword -Root $root -RelativePath 'Software\Microsoft\Windows\CurrentVersion\Feeds' -Name 'ShellFeedsTaskbarViewMode' -Value 2
        }
        if ($RemoveSearchBar) {
            Write-TaskbarDword -Root $root -RelativePath 'Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 0
            Write-TaskbarDword -Root $root -RelativePath 'Software\Microsoft\Windows\CurrentVersion\Search' -Name 'TraySearchBoxVisible' -Value 0
            Write-TaskbarDword -Root $root -RelativePath 'Software\Microsoft\Windows\CurrentVersion\Search' -Name 'TraySearchBoxVisibleOnAnyMonitor' -Value 0
        }
        if ($RemoveTaskView) {
            Write-TaskbarDword -Root $root -RelativePath 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 0
        }
    }

    Write-Output 'Windows 10 taskbar defaults updated for current user and Default profile.'
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
finally {
    [GC]::Collect()
    if ($hiveLoaded) {
        & reg.exe unload 'HKU\DefaultUser' | Out-Null
    }
}
