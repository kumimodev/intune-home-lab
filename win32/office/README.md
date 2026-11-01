# Microsoft 365 Apps sample XML

Use these with the Office Deployment Tool in a Win32 app or during image build.

1. `configuration-install.xml` installs 64 bit Current Channel apps and excludes Access, Groove, Lync, Publisher, and Bing.
2. `configuration-uninstall.xml` removes the same product id.
3. Company name is set to `Contoso Lab`. Change it before you publish the package.

Pair the XML with `setup.exe` from the Office Deployment Tool. This sample does not ship the binary.
