# Generic TCP/IP printer Win32 sample

Install a printer from an INF driver, create a TCP/IP port, then register the printer.

## Example Intune install command

```text
powershell.exe -ExecutionPolicy Bypass -File .\install-printer.ps1 -PortName "IP_10.0.0.50" -PrinterIP "10.0.0.50" -PrinterName "Lab Printer 01" -DriverName "Generic Lab Driver" -INFFile "labprinter.inf"
```

## Example uninstall command

```text
powershell.exe -ExecutionPolicy Bypass -File .\uninstall-printer.ps1 -PrinterName "Lab Printer 01"
```

## Detection idea

Look for the printer name under:

`HKLM\Software\Microsoft\Windows NT\CurrentVersion\Print\Printers\Lab Printer 01`

Ship the INF and driver files beside the scripts in your Win32 package. The sample addresses use the `10.0.0.x` range only.
