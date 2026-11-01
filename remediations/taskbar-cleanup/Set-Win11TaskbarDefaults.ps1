#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Trims Windows 11 taskbar defaults on the Default user profile.

.DESCRIPTION
  Loads the Default NTUSER.DAT hive and applies selected Explorer Advanced values.
  Pass one or more switches.

.EXAMPLE
  .\Set-Win11TaskbarDefaults.ps1 -RemoveTaskView -RemoveWidgets -RemoveChat -RemoveSearch
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$RemoveTaskView,
    [switch]$RemoveWidgets,
    [switch]$RemoveChat,
    [switch]$RemoveSearch
)

$ErrorActionPreference = 'Stop'
if (-not $PSCmdlet.ShouldProcess('Windows 11 taskbar defaults', 'Apply taskbar defaults')) {
    return
}


if (-not ($RemoveTaskView -or $RemoveWidgets -or $RemoveChat -or $RemoveSearch)) {
    Write-Error 'Specify at least one of -RemoveTaskView, -RemoveWidgets, -RemoveChat, -RemoveSearch.'
    exit 1
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

$markerKey = 'HKLM:\SOFTWARE\IntuneHomeLab\Taskbar'
if (-not (Test-Path -LiteralPath $markerKey)) {
    New-Item -Path $markerKey -Force | Out-Null
}
New-ItemProperty -Path $markerKey -Name 'CustomizeTaskbar' -Value '1' -PropertyType String -Force | Out-Null

$hiveLoaded = $false
try {
    & reg.exe load 'HKLM\DefaultUser' 'C:\Users\Default\NTUSER.DAT' | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not load Default user hive.' }
    $hiveLoaded = $true
    $root = 'HKLM:\DefaultUser'

    if ($RemoveTaskView) {
        Write-TaskbarDword -Root $root -RelativePath 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 0
    }
    if ($RemoveWidgets) {
        Write-TaskbarDword -Root $root -RelativePath 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 0
    }
    if ($RemoveChat) {
        Write-TaskbarDword -Root $root -RelativePath 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarMn' -Value 0
    }
    if ($RemoveSearch) {
        Write-TaskbarDword -Root $root -RelativePath 'Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 0
    }

    Write-Output 'Windows 11 Default profile taskbar values updated.'
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
finally {
    [GC]::Collect()
    if ($hiveLoaded) {
        & reg.exe unload 'HKLM\DefaultUser' | Out-Null
    }
}
