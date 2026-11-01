@echo off
REM Merge Windows 10 Pro and Windows 11 Pro from WIM based ISOs into one folder tree.
REM Expects Win10.iso and Win11.iso in C:\temp\ISO\
REM Confirm the Pro index with DISM before you trust SourceIndex 6.

IF NOT EXIST C:\temp\ISO\CustomizedISO (
    MKDIR C:\temp\ISO\CustomizedISO
)

IF NOT EXIST C:\temp\ISO\temp (
    MKDIR C:\temp\ISO\temp
)

echo Mounting Windows 10 ISO...
powershell.exe -NoProfile -Command "Mount-DiskImage -ImagePath 'C:\Temp\ISO\Win10.ISO'"

echo Extracting Windows 10 media...
xcopy D:\*.* C:\temp\ISO\CustomizedISO /E /H /K /I

Dism /export-image /SourceImageFile:"C:\temp\ISO\CustomizedISO\sources\install.wim" /SourceIndex:6 /DestinationImageFile:"C:\temp\ISO\temp\install.wim" /Compress:max /CheckIntegrity

echo Dismounting Windows 10 ISO...
powershell.exe -NoProfile -Command "Dismount-DiskImage -ImagePath 'C:\Temp\ISO\Win10.ISO'"

echo Mounting Windows 11 ISO...
powershell.exe -NoProfile -Command "Mount-DiskImage -ImagePath 'C:\Temp\ISO\Win11.ISO'"

echo Extracting Windows 11 media...
xcopy D:\*.* C:\temp\ISO\temp\ /E /H /K /I

echo Exporting Windows 11 Pro into the shared WIM...
Dism /export-image /SourceImageFile:"C:\temp\ISO\temp\sources\install.wim" /SourceIndex:6 /DestinationImageFile:"C:\temp\ISO\temp\install.wim" /Compress:max /CheckIntegrity

echo Dismounting Windows 11 ISO...
powershell.exe -NoProfile -Command "Dismount-DiskImage -ImagePath 'C:\Temp\ISO\Win11.ISO'"

echo Moving merged WIM into CustomizedISO...
powershell.exe -NoProfile -Command "Move-Item -Path 'C:\temp\ISO\temp\install.wim' -Destination 'C:\temp\ISO\CustomizedISO\sources\install.wim' -Force"

echo Cleaning temporary extract folder...
rd /S /Q "C:\Temp\ISO\temp\"

echo Operation completed. Listing images in the merged WIM:
DISM /Get-WimInfo /WimFile:"C:\temp\ISO\CustomizedISO\sources\install.wim"

echo Confirm you only see Windows 10 Pro and Windows 11 Pro.
pause
