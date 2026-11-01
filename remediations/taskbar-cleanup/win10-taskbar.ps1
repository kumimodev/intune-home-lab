# Trim Windows 10 taskbar defaults for the current user and the Default profile.
# Example:
#   .\win10-taskbar.ps1 -RemoveNews -RemoveSearchBar -RemoveTaskView

param (
    [switch]$RemoveNews,
    [switch]$RemoveSearchBar,
    [switch]$RemoveTaskView
)

if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64') {
    try {
        & "$ENV:WINDIR\SysNative\WindowsPowerShell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH @PSBoundParameters
    }
    catch {
        throw "Failed to start $PSCOMMANDPATH"
    }
    exit
}

$markerKey = 'HKCU:\SOFTWARE\IntuneHomeLab\Taskbar'
if (-not (Test-Path $markerKey)) {
    New-Item -Path $markerKey -Force | Out-Null
}
New-ItemProperty -Path $markerKey -Name 'CustomizeTaskbar' -Value '1' -PropertyType String -Force | Out-Null

reg load HKU\DefaultUser C:\Users\Default\NTUSER.DAT | Out-Null

switch ($PSBoundParameters.Keys) {
    'RemoveNews' {
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds' -Name 'ShellFeedsTaskbarViewMode' -Value 2 -PropertyType DWord -Force | Out-Null
    }
    'RemoveSearchBar' {
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 0 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'TraySearchBoxVisible' -Value 0 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'TraySearchBoxVisibleOnAnyMonitor' -Value 0 -PropertyType DWord -Force | Out-Null
    }
    'RemoveTaskView' {
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 0 -PropertyType DWord -Force | Out-Null
    }
    Default {
        Write-Host 'No parameters were specified. Pass -RemoveNews, -RemoveSearchBar, and or -RemoveTaskView.'
    }
}

[GC]::Collect()
reg unload HKU\DefaultUser | Out-Null
