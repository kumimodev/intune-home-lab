#Requires -Version 5.1
<#
.SYNOPSIS
  Detection for selected inbox apps that a lab business desktop usually does not need.

.DESCRIPTION
  Exit 0 when clean. Exit 1 when at least one listed app is installed or provisioned.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$AppsList = @(
    'Microsoft.WindowsFeedbackHub',
    'Clipchamp.Clipchamp',
    'Microsoft.BingNews',
    'Microsoft.MicrosoftSolitaireCollection',
    'Microsoft.BingWeather',
    'Microsoft.XboxApp',
    'Microsoft.Xbox.TCUI',
    'Microsoft.XboxGameOverlay',
    'Microsoft.XboxGamingOverlay',
    'Microsoft.XboxIdentityProvider',
    'Microsoft.XboxSpeechToTextOverlay',
    'Microsoft.SkypeApp',
    'Microsoft.ZuneVideo',
    'Microsoft.ZuneMusic',
    'Microsoft.People',
    'Microsoft.GetHelp',
    'Microsoft.YourPhone',
    'Microsoft.Getstarted'
)

$found = New-Object System.Collections.Generic.List[string]

$installed = @(Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue)
$provisioned = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue)

foreach ($app in $AppsList) {
    $hitInstalled = $installed | Where-Object { $_.Name -like "$app*" -or $_.Name -eq $app }
    $hitProvisioned = $provisioned | Where-Object { $_.DisplayName -like "$app*" -or $_.PackageName -like "*$app*" }
    if ($hitInstalled -or $hitProvisioned) {
        $found.Add($app) | Out-Null
        Write-Output "Found unwanted app: $app"
    }
}

if ($found.Count -gt 0) {
    Write-Output 'Unwanted inbox apps detected.'
    exit 1
}

Write-Output 'No unwanted inbox apps found.'
exit 0
