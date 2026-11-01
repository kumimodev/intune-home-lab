# Merge every Autopilot hardware hash CSV in this folder into one file.
# Place the CSV files next to this script, then run it in PowerShell.

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
    $combinedData += Import-Csv -Path $file
}

$outFile = Join-Path $scriptDirectory 'merged-hardware-hash.csv'
$combinedData |
    Select-Object -Property * -Unique |
    Export-Csv -Path $outFile -NoTypeInformation

Write-Host "Wrote $outFile"
