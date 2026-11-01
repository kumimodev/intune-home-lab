#Requires -Version 5.1
<#
.SYNOPSIS
  Remediation that applies Singapore Standard Time and en-SG locale settings.

.DESCRIPTION
  Intune proactive remediation script. Exit 0 on success.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param()

$ErrorActionPreference = 'Stop'
if (-not $PSCmdlet.ShouldProcess('en-SG localisation', 'Apply lab localisation settings')) {
    return
}


try {
    Set-TimeZone -Id 'Singapore Standard Time'
    Start-Service -Name W32Time -ErrorAction SilentlyContinue
    & w32tm.exe /resync /force | Out-Null

    Set-WinSystemLocale -SystemLocale 'en-SG'
    Set-WinUILanguageOverride -Language 'en-SG'
    $languageList = New-WinUserLanguageList -Language 'en-SG'
    Set-WinUserLanguageList -LanguageList $languageList -Force

    Write-Output 'Localisation remediated to en-SG with Singapore Standard Time.'
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
