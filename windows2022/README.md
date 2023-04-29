# `mloskot/sig-windows-dev-tools-windows-2022`

Custom version of Kubernetes valengus/windows-2022-standard-core box, tweaked and packaged with vagrant package.

## v1.0

Custom version of [valengus/windows-2022-standard-core](https://app.vagrantup.com/valengus/boxes/windows-2022-standard-core) for use with https://github.com/kubernetes-sigs/sig-windows-dev-tools with the following tweaks:

- Windows Updates installed (All quality updates)
- Windows Updates disabled
- Windows Remove Desktop disabled
- Windows Remote Management (WinRM) autostart: `sc config WinRM start= auto`
- Windows Firewall disabled: `netsh advfirewall set allprofiles state off`
- Windows Defender Antivirus disabled
- VirtualBox Guest Additions 7.0.8
- Set VirtualBox OS type as `Windows2019_64`
- Disabled VirtualBox GUI features
- Disabled VirtualBox 2D and 3D acceleration
- Disabled VirtualBox Remote Desktop
