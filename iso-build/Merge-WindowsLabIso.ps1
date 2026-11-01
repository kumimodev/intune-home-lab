#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Builds a lab media folder that contains Windows 10 Pro and Windows 11 Pro images.

.DESCRIPTION
  Mounts two ISOs, exports the chosen edition indexes into one install image,
  and leaves a CustomizedISO folder ready for further ISO authoring tools.
  Confirm SourceIndex values with DISM /Get-WimInfo before you trust the defaults.

.PARAMETER Windows10Iso
  Path to a Windows 10 ISO.

.PARAMETER Windows11Iso
  Path to a Windows 11 ISO.

.PARAMETER WorkRoot
  Working folder. Default is C:\LabISO.

.PARAMETER Windows10Index
  Image index for Windows 10 Pro inside the source install image.

.PARAMETER Windows11Index
  Image index for Windows 11 Pro inside the source install image.

.PARAMETER ImageFormat
  esd or wim. Default is esd.

.EXAMPLE
  .\Merge-WindowsLabIso.ps1 -Windows10Iso 'C:\LabISO\Win10.iso' -Windows11Iso 'C:\LabISO\Win11.iso'
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$Windows10Iso,

    [Parameter(Mandatory = $true)]
    [string]$Windows11Iso,

    [string]$WorkRoot = 'C:\LabISO',

    [int]$Windows10Index = 6,

    [int]$Windows11Index = 6,

    [ValidateSet('esd', 'wim')]
    [string]$ImageFormat = 'esd'
)

$ErrorActionPreference = 'Stop'
if (-not $PSCmdlet.ShouldProcess($WorkRoot, 'Merge Windows lab ISO media')) {
    return
}


foreach ($iso in @($Windows10Iso, $Windows11Iso)) {
    if (-not (Test-Path -LiteralPath $iso)) {
        throw ("ISO not found: " + $iso)
    }
}

$custom = Join-Path $WorkRoot 'CustomizedISO'
$temp = Join-Path $WorkRoot 'temp'
New-Item -ItemType Directory -Path $custom -Force | Out-Null
New-Item -ItemType Directory -Path $temp -Force | Out-Null

function Get-IsoDriveLetter {
    param([string]$IsoPath)
    $vol = Mount-DiskImage -ImagePath $IsoPath -PassThru | Get-Volume
    return ($vol.DriveLetter.ToString() + ':')
}

function Dismount-IsoSafe {
    param([string]$IsoPath)
    Dismount-DiskImage -ImagePath $IsoPath -ErrorAction SilentlyContinue | Out-Null
}

$installName = 'install.' + $ImageFormat
$mergedImage = Join-Path $temp $installName

try {
    Write-Verbose 'Mounting Windows 10 ISO...'
    $d10 = Get-IsoDriveLetter -IsoPath $Windows10Iso
    Write-Verbose ("Copying Windows 10 media from " + $d10)
    & robocopy.exe ($d10 + '\') ($custom + '\') /E /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null

    $src10 = Join-Path $custom ('sources\' + $installName)
    if (-not (Test-Path -LiteralPath $src10)) {
        $alt = if ($ImageFormat -eq 'esd') { 'install.wim' } else { 'install.esd' }
        $src10Alt = Join-Path $custom ('sources\' + $alt)
        if (Test-Path -LiteralPath $src10Alt) { $src10 = $src10Alt }
    }
    if (-not (Test-Path -LiteralPath $src10)) {
        throw ("Could not find install.esd or install.wim under " + $custom + '\sources')
    }

    Write-Verbose ("Exporting Windows 10 index " + $Windows10Index)
    & dism.exe /export-image ("/SourceImageFile:" + $src10) ("/SourceIndex:" + $Windows10Index) ("/DestinationImageFile:" + $mergedImage) /Compress:max /CheckIntegrity
    if ($LASTEXITCODE -ne 0) { throw ("DISM export for Windows 10 failed with " + $LASTEXITCODE) }
    Dismount-IsoSafe -IsoPath $Windows10Iso

    Write-Verbose 'Mounting Windows 11 ISO...'
    $d11 = Get-IsoDriveLetter -IsoPath $Windows11Iso
    $win11Extract = Join-Path $temp 'win11'
    New-Item -ItemType Directory -Path $win11Extract -Force | Out-Null
    & robocopy.exe ($d11 + '\') ($win11Extract + '\') /E /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null

    $src11 = Join-Path $win11Extract ('sources\' + $installName)
    if (-not (Test-Path -LiteralPath $src11)) {
        $alt = if ($ImageFormat -eq 'esd') { 'install.wim' } else { 'install.esd' }
        $src11Alt = Join-Path $win11Extract ('sources\' + $alt)
        if (Test-Path -LiteralPath $src11Alt) { $src11 = $src11Alt }
    }
    if (-not (Test-Path -LiteralPath $src11)) {
        throw ("Could not find install image under " + $win11Extract + '\sources')
    }

    Write-Verbose ("Exporting Windows 11 index " + $Windows11Index + " into merged image")
    & dism.exe /export-image ("/SourceImageFile:" + $src11) ("/SourceIndex:" + $Windows11Index) ("/DestinationImageFile:" + $mergedImage) /Compress:max /CheckIntegrity
    if ($LASTEXITCODE -ne 0) { throw ("DISM export for Windows 11 failed with " + $LASTEXITCODE) }
    Dismount-IsoSafe -IsoPath $Windows11Iso

    $destImage = Join-Path $custom ('sources\' + $installName)
    Move-Item -LiteralPath $mergedImage -Destination $destImage -Force
    Write-Output ("Merged image is at " + $destImage)
    & dism.exe /Get-WimInfo ("/WimFile:" + $destImage)
    Write-Output 'Confirm you only see the Windows 10 Pro and Windows 11 Pro editions you expected.'
    exit 0
}
catch {
    Dismount-IsoSafe -IsoPath $Windows10Iso
    Dismount-IsoSafe -IsoPath $Windows11Iso
    Write-Error $_.Exception.Message
    exit 1
}
finally {
    if (Test-Path -LiteralPath $temp) {
        Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
    }
}
