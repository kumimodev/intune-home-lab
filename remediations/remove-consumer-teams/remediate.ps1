#Requires -Version 5.1
<#
.SYNOPSIS
  Removes the Windows 11 consumer Microsoft Teams AppX package.

.DESCRIPTION
  Also clears matching provisioned packages when present. Exit 0 on success.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param()

$ErrorActionPreference = 'Stop'
if (-not $PSCmdlet.ShouldProcess('consumer Teams packages', 'Remove consumer Teams packages')) {
    return
}


try {
    Get-AppxPackage -Name 'MicrosoftTeams' -ErrorAction SilentlyContinue |
        Remove-AppxPackage -ErrorAction Stop

    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like '*MicrosoftTeams*' -or $_.PackageName -like '*MicrosoftTeams*' } |
        ForEach-Object {
            Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
        }

    Write-Output 'Microsoft Teams consumer app removed where present.'
    exit 0
}
catch {
    Write-Error "Failed to remove Microsoft Teams consumer app: $($_.Exception.Message)"
    exit 1
}
