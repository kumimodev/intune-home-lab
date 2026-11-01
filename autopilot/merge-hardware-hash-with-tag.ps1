# Merge Autopilot CSV files and stamp a Group Tag on every row.
# Edit $GroupTag before you run this in your lab.

$GroupTag = 'LAB'

$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$csvFiles = Get-ChildItem -File -Path (Join-Path $scriptDirectory '*.csv') |
    Where-Object { $_.Name -ne 'merged-hardware-hash.csv' } |
    Select-Object -ExpandProperty FullName

if (-not $csvFiles) {
    Write-Host 'No CSV files found next to this script.'
    exit 1
}

$combinedData = @()
foreach ($file in $csvFiles) {
    $data = Import-Csv -Path $file
    $combinedData += $data
}

$outFile = Join-Path $scriptDirectory 'merged-hardware-hash.csv'
$combinedData |
    Select-Object *, @{ Name = 'Group Tag'; Expression = { $GroupTag } } |
    Export-Csv -Path $outFile -NoTypeInformation

Write-Host "Wrote $outFile with Group Tag $GroupTag"
