# Remediation: remove selected inbox apps for current users and from provisioning.
# Pattern expanded from a private removebloat sample, rewritten for a home lab.

$AppsList = @(
    '*Microsoft.WindowsFeedbackHub*',
    '*Clipchamp*',
    '*Microsoft.BingNews*',
    '*Microsoft.MicrosoftSolitaireCollection*',
    '*Microsoft.BingWeather*',
    '*Microsoft.Xbox*',
    '*Microsoft.SkypeApp*',
    '*Microsoft.ZuneVideo*',
    '*Microsoft.ZuneMusic*',
    '*Microsoft.People*',
    '*Microsoft.GetHelp*',
    '*Microsoft.YourPhone*',
    '*Microsoft.Getstarted*'
)

foreach ($App in $AppsList) {
    Get-AppxPackage -Name $App -AllUsers -ErrorAction SilentlyContinue |
        Remove-AppxPackage -ErrorAction SilentlyContinue

    Get-AppxProvisionedPackage -Online |
        Where-Object { $_.DisplayName -like $App -or $_.PackageName -like $App } |
        ForEach-Object {
            Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
        }
}

Write-Host 'Selected inbox apps removed where present.'
exit 0
