# Detection: selected inbox apps that a lab business desktop usually does not need.
# Exit 0 = clean. Exit 1 = at least one listed app is installed or provisioned.

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

$FoundApps = 0

foreach ($App in $AppsList) {
    $CheckProvisioned = Get-AppxProvisionedPackage -Online |
        Where-Object { $_.DisplayName -like $App -or $_.PackageName -like $App }
    $CheckInstalled = Get-AppxPackage -Name $App -AllUsers -ErrorAction SilentlyContinue

    if ($CheckProvisioned -or $CheckInstalled) {
        Write-Host "Found unwanted app matching pattern: $App"
        $FoundApps++
    }
}

if ($FoundApps -gt 0) {
    Write-Host 'Unwanted inbox apps detected.'
    exit 1
}

Write-Host 'No unwanted inbox apps found.'
exit 0
