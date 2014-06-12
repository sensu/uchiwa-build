## Uchiwa Build

This project builds Omnibus packages for Uchiwa, a Sensu dashboard.
Vagrant, VirtualBox, and Bunchr are used to create the packages.
Debian packages are built on Ubuntu 12.04, and RPMs are built on
Centos 6.5.

### Run

```
vagrant up
./scripts/upload
./scripts/clean
```
