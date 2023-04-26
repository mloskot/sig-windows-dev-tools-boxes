# sig-windows-dev-tools-boxes

Experimental Vagrant boxes for testing https://github.com/kubernetes-sigs/sig-windows-dev-tools setup **on Windows host** using Virtual Box.

## Boxes

- [mloskot//sig-windows-dev-tools-ubuntu-2204](https://app.vagrantup.com/mloskot/boxes/sig-windows-dev-tools-ubuntu-2204) is tweaked version of [roboxes/ubuntu2204](https://app.vagrantup.com/roboxes/boxes/ubuntu2204)
- [mloskot/sig-windows-dev-tools-windows-2019](https://app.vagrantup.com/mloskot/boxes/sig-windows-dev-tools-windows-2019) is tweak version of [sig-windows-dev-tools/boxes/windows-2019](https://app.vagrantup.com/sig-windows-dev-tools/boxes/windows-2019)

## Features

- VirtualBox Guest Additions 7.0.8
- Set explicit VirtualBox OS type
- Disabled VirtualBox GUI features
- Disabled VirtualBox 2D and 3D acceleration
- Disabled VirtualBox Remote Desktop
- Windows box with WinRM startup set to `auto` instead of `auto (delayed)`: `sc config WinRM start= auto`
- Windows Firewall disabled: `netsh advfirewall set allprofiles state off`

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
    ```
    cd windows2019
    vagrant up
    vagrant package --base <machine name> --output <name>.box
    ```
2. Upload `<name>.box` file to app.vagrantup.com
3. Update `Vagrantfile`-s of tests with new version/box
4. Test with `.\run_test.ps1 test_<box>`
5. Clone SWDT from https://github.com/kubernetes-sigs/sig-windows-dev-tools 
6. Modify its `Vagrantfile` to use desired new boxes
7. Run SWDT to create cluster using new boxes
