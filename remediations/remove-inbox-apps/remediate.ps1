#Requires -Version 5.1
<#
.SYNOPSIS
  Removes selected inbox apps for current users and from provisioning.

.DESCRIPTION
  Idempotent where packages are already absent. Exit 0 when finished.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'

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

foreach ($app in $AppsList) {
    Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "$app*" -or $_.Name -eq $app } |
        Remove-AppxPackage -ErrorAction SilentlyContinue

    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "$app*" -or $_.PackageName -like "*$app*" } |
        ForEach-Object {
            Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
        }
}

Write-Output 'Selected inbox apps removed where present.'
exit 0
