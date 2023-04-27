# `mloskot/sig-windows-dev-tools-ubuntu-2004`

Custom version of roboxes/ubuntu2004 box, tweaked and packaged with vagrant package for use with https://github.com/kubernetes-sigs/sig-windows-dev-tools

## v1.0

Custom version of `roboxes/ubuntu2004` for use with https://github.com/kubernetes-sigs/sig-windows-dev-tools

- VirtualBox Guest Additions 7.0.8 with workaround [libXt.so missing](https://github.com/dotless-de/vagrant-vbguest/issues/425#issuecomment-1515225030)
- Set VirtualBox OS type as `Ubuntu20_LTS_64`
- Disabled VirtualBox GUI features
- Disabled VirtualBox 2D and 3D acceleration
- Disabled VirtualBox Remote Desktop
