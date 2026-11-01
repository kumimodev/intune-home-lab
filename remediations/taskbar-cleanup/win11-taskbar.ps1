# Trim Windows 11 taskbar defaults on the Default user profile.
# Example:
#   .\win11-taskbar.ps1 -RemoveTaskView -RemoveWidgets -RemoveChat -RemoveSearch

param (
    [switch]$RemoveTaskView,
    [switch]$RemoveWidgets,
    [switch]$RemoveChat,
    [switch]$RemoveSearch
)

$markerKey = 'HKLM:\SOFTWARE\IntuneHomeLab\Taskbar'
if (-not (Test-Path $markerKey)) {
    New-Item -Path $markerKey -Force | Out-Null
}
New-ItemProperty -Path $markerKey -Name 'CustomizeTaskbar' -Value '1' -PropertyType String -Force | Out-Null

reg load HKLM\DefaultUser C:\Users\Default\NTUSER.DAT | Out-Null

$hive = 'HKLM:\DefaultUser'

switch ($PSBoundParameters.Keys) {
    'RemoveTaskView' {
        New-ItemProperty -Path "$hive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowTaskViewButton' -Value 0 -PropertyType DWord -Force | Out-Null
    }
    'RemoveWidgets' {
        New-ItemProperty -Path "$hive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'TaskbarDa' -Value 0 -PropertyType DWord -Force | Out-Null
    }
    'RemoveChat' {
        New-ItemProperty -Path "$hive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'TaskbarMn' -Value 0 -PropertyType DWord -Force | Out-Null
    }
    'RemoveSearch' {
        $searchKey = "$hive\Software\Microsoft\Windows\CurrentVersion\Search"
        if (-not (Test-Path $searchKey)) {
            New-Item -Path $searchKey -Force | Out-Null
        }
        New-ItemProperty -Path $searchKey -Name 'SearchboxTaskbarMode' -Value 0 -PropertyType DWord -Force | Out-Null
    }
    Default {
        Write-Host 'No parameters were specified. Pass -RemoveTaskView, -RemoveWidgets, -RemoveChat, and or -RemoveSearch.'
    }
}

[GC]::Collect()
reg unload HKLM\DefaultUser | Out-Null
