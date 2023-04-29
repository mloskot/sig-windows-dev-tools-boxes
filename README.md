# sig-windows-dev-tools-boxes

Experimental Vagrant boxes for testing https://github.com/kubernetes-sigs/sig-windows-dev-tools setup **on Windows host** using Virtual Box.

## Boxes

> **WARNING:** The boxes have not been optimised for size, just some packages have been removed from Ubuntu boxes (e.g. build tools).

The avaialble custom twaeked versions of test boxes:

- [mloskot/sig-windows-dev-tools-ubuntu-2004](https://app.vagrantup.com/mloskot/boxes/sig-windows-dev-tools-ubuntu-2004) based on [roboxes/ubuntu2004](https://app.vagrantup.com/roboxes/boxes/ubuntu2004)
- [mloskot/sig-windows-dev-tools-ubuntu-2204](https://app.vagrantup.com/mloskot/boxes/sig-windows-dev-tools-ubuntu-2204) based on [roboxes/ubuntu2204](https://app.vagrantup.com/roboxes/boxes/ubuntu2204)
- [mloskot/sig-windows-dev-tools-windows-2019](https://app.vagrantup.com/mloskot/boxes/sig-windows-dev-tools-windows-2019) based on [sig-windows-dev-tools/boxes/windows-2019](https://app.vagrantup.com/sig-windows-dev-tools/boxes/windows-2019)
- [mloskot/sig-windows-dev-tools-windows-2022](https://app.vagrantup.com/mloskot/boxes/sig-windows-dev-tools-windows-2022) based on [valengus/windows-2022-standard-core](https://app.vagrantup.com/valengus/boxes/windows-2022-standard-core)

## Features

- VirtualBox Guest Additions 7.0.8 (including [workaround for libXt.so missing](https://github.com/dotless-de/vagrant-vbguest/issues/425#issuecomment-1515225030) on Ubuntu 22.04)
- Set explicit VirtualBox OS type
- Disabled VirtualBox GUI features
- Disabled VirtualBox 2D and 3D acceleration
- Disabled VirtualBox Remote Desktop
- Windows box with WinRM startup forced to `auto` instead of `auto (delayed)`: `sc config WinRM start= auto`
- Windows Firewall disabled: `netsh advfirewall set allprofiles state off`
- Windows Defender Antivirus disabled

## Test

```powershell
.\run_test.ps1 test_ubuntu2204
.\run_test.ps1 test_windows2019
```

Simple smoke test run `vagrant up` and `vagrant destroy` 10 times as poor-man way to determine
boot and provisioning times, catch any deviations, discover (WinRM) timeouts and other issues.
The runner script saves complete output in log file per test directory.

## Build

There is no sophisticated build pipeline using configuration management tools.

The boxes are simply packaged VirtualBox machines:

1. Create VirtualBox machine

    ```console
    cd windows2019
    vagrant up
    # Apply tweaks - the gist of this project!
    vagrant package --base <machine name> --output <name>.box
    ```

2. Upload `<name>.box` file to app.vagrantup.com
3. Update `Vagrantfile`-s of tests with new version/box
4. Test with `.\run_test.ps1 test_<box>`
5. Clone SWDT from https://github.com/kubernetes-sigs/sig-windows-dev-tools 
6. Modify its `Vagrantfile` to use desired new boxes
7. Run SWDT to create cluster using new boxes
