# Remediation: apply Singapore Standard Time and en-SG locale settings.

Set-TimeZone -Id 'Singapore Standard Time'

Start-Service -Name W32Time -ErrorAction SilentlyContinue
w32tm /resync /force | Out-Null

Set-WinSystemLocale -SystemLocale 'en-SG'
Set-WinUILanguageOverride -Language 'en-SG'

$LanguageList = New-WinUserLanguageList 'en-SG'
Set-WinUserLanguageList $LanguageList -Force

Write-Output 'Localisation remediated to en-SG with Singapore Standard Time.'
exit 0
