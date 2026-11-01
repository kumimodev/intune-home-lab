# Detection: Windows 11 consumer Microsoft Teams AppX package.
# Exit 0 = not present. Exit 1 = present and should be removed.

if ($null -eq (Get-AppxPackage -Name MicrosoftTeams -ErrorAction SilentlyContinue)) {
    Write-Host 'Microsoft Teams consumer client not found.'
    exit 0
}

Write-Host 'Microsoft Teams consumer client found.'
exit 1
