# `mloskot/sig-windows-dev-tools-windows-2022-g`

Custom version of [gusztavvargadr/windows-server-2022-standard-core](https://app.vagrantup.com/gusztavvargadr/boxes/windows-server-2022-standard-core)
dedicated for use with [kubernetes-sigs/sig-windows-dev-tools](https://github.com/kubernetes-sigs/sig-windows-dev-tools)

List of essential features of the original base box:

- User `vagrant` with password `vagrant` and Vagrant's insecure key
- Windows Updates disabled
- Maintenance tasks disabled
- Windows Defender disabled
- UAC disabled

List of additional custom changes (see [provision.ps1](../provision.ps1)):

- Installed VirtualBox Guest Additions 7.0.8
- Installed Windows Feature Containers
- Installed ContainerD 1.7.0 and nerdctl 1.4.0 - current latest
- Uninstalled Windows Defender
- Uninstalled selection of unused Windows Features
- Uninstalled Chef Infra Client
- Enabled PowerShell as OpenSSH default shell
- Hostname renamed to `winworker`

`Vagrantfile`:

- Set VirtualBox OS type as `Windows2022_64`
- Set explicit graphic controller `vboxsvga`
- Disabled VirtualBox GUI features
- Disabled VirtualBox 2D and 3D acceleration
- Disabled VirtualBox Remote Desktop
- Disabled Clipboard
- Disabled Drag-n-Drop 
