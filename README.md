## Uchiwa Build

This project builds Omnibus packages for Uchiwa, a Sensu dashboard.
Vagrant, VirtualBox, and Bunchr are used to create the packages.
Debian packages are built on Ubuntu 10.04, and RPMs are built on
Centos 6.5.

### Run

```
export UCHIWA_VERSION=0.1.2
export BUILD_NUMBER=1
bundle install
vagrant up
./scripts/upload
./scripts/clean
```
