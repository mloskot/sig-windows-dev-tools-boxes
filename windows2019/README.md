# `mloskot/sig-windows-dev-tools-windows-2019`

Custom version of Kubernetes sig-windows-dev-tools/windows-2019 box, tweaked and packaged with vagrant package.

## v1.0

Custom version of [sig-windows-dev-tools/windows-2019](https://app.vagrantup.com/sig-windows-dev-tools/boxes/windows-2019) for use with https://github.com/kubernetes-sigs/sig-windows-dev-tools with the following tweaks:

- VirtualBox Guest Additions 7.0.8
- Set VirtualBox OS type as `Windows2019_64`
- Disabled VirtualBox GUI features
- Disabled VirtualBox 2D and 3D acceleration
- Disabled VirtualBox Remote Desktop
- WinRM autostart: `sc config WinRM start= auto`
- Windows Firewall disabled: `netsh advfirewall set allprofiles state off`

## Notes

```
sc config WinRM start= auto
```

```
netsh advfirewall set allprofiles state off
```

```
$env:Path += ';C:\Program Files\Oracle\VirtualBox'
VBoxManage list vms
```

```
vagrant package --base "swdt-windows-2019_win2019_1682452266871_70681" --output swdt-windows-2019-ml-20230425.box
==> swdt-windows-2019_win2019_1682452266871_70681: Attempting graceful shutdown of VM...
    swdt-windows-2019_win2019_1682452266871_70681: Guest communication could not be established! This is usually because
    swdt-windows-2019_win2019_1682452266871_70681: SSH is not running, the authentication information was changed,
    swdt-windows-2019_win2019_1682452266871_70681: or some other networking issue. Vagrant will force halt, if
    swdt-windows-2019_win2019_1682452266871_70681: capable.
==> swdt-windows-2019_win2019_1682452266871_70681: Forcing shutdown of VM...
==> swdt-windows-2019_win2019_1682452266871_70681: Clearing any previously set forwarded ports...
==> swdt-windows-2019_win2019_1682452266871_70681: Exporting VM...
==> swdt-windows-2019_win2019_1682452266871_70681: Compressing package to: D:/_vagrant/swdt-windows-2019/boxes/swdt-windows-2019-ml-20230425.box
```

```
vagrant box add mloskot/sig-windows-dev-tools-windows-2019 swdt-windows-2019-ml-20230425.box
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'mloskot/swdt-windows-2019' (v0) for provider:
    box: Unpacking necessary files from: file:///D:/_vagrant/swdt-windows-2019/boxes/swdt-windows-2019-ml-20230425.box
    box:
==> box: Successfully added box 'mloskot/swdt-windows-2019' (v0) for 'virtualbox'!
```