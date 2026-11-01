#Requires -Version 5.1
<#
.SYNOPSIS
  Detection for Singapore Standard Time and en-SG locale settings.

.DESCRIPTION
  Intune proactive remediation detection.
  Exit 0 when healthy. Exit 1 when remediation should run.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$currentTimeZone = (Get-TimeZone).Id
$currentSysLocale = (Get-WinSystemLocale).Name
$ui = Get-WinUILanguageOverride
$currentUILang = if ($ui -and $ui.Name) { $ui.Name } else { [string]$ui }
$currentKeyboard = (Get-WinUserLanguageList)[0].LanguageTag

if (
    $currentTimeZone -eq 'Singapore Standard Time' -and
    $currentSysLocale -eq 'en-SG' -and
    $currentUILang -eq 'en-SG' -and
    $currentKeyboard -eq 'en-SG'
) {
    Write-Output 'Localisation is set to en-SG with Singapore Standard Time.'
    exit 0
}

Write-Output 'Localisation settings are missing or incorrect.'
exit 1
