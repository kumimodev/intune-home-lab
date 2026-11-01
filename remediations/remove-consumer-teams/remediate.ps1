# Remediation: remove the Windows 11 consumer Microsoft Teams AppX package.

try {
    Get-AppxPackage -Name MicrosoftTeams -ErrorAction Stop | Remove-AppxPackage -ErrorAction Stop
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like '*MicrosoftTeams*' -or $_.PackageName -like '*MicrosoftTeams*' } |
        Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
    Write-Host 'Microsoft Teams consumer app removed.'
    exit 0
}
catch {
    Write-Error "Failed to remove Microsoft Teams consumer app: $($_.Exception.Message)"
    exit 1
}
