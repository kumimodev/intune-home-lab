# Detection: Singapore Standard Time and en-SG locale settings.
# Exit 0 = healthy. Exit 1 = needs remediation.

$ErrorActionPreference = 'SilentlyContinue'

$CurrentTimeZone = (Get-TimeZone).Id
$CurrentSysLocale = (Get-WinSystemLocale).Name
$CurrentUILang = (Get-WinUILanguageOverride).Name
if (-not $CurrentUILang) {
    $CurrentUILang = (Get-WinUILanguageOverride)
}
$CurrentKeyboard = (Get-WinUserLanguageList)[0].LanguageTag

if (
    $CurrentTimeZone -eq 'Singapore Standard Time' -and
    $CurrentSysLocale -eq 'en-SG' -and
    $CurrentUILang -eq 'en-SG' -and
    $CurrentKeyboard -eq 'en-SG'
) {
    Write-Output 'Localisation is set to en-SG with Singapore Standard Time.'
    exit 0
}

Write-Output 'Localisation settings are missing or incorrect.'
exit 1
