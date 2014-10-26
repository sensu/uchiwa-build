## Uchiwa Build

This project builds packages for Uchiwa, a Sensu dashboard.
Vagrant, Test-Kitchen and Vagrant are used to create the packages.
Debian packages are built on Ubuntu 14.04, and RPMs are built on
Centos 6.5.

### Run

```
export UCHIWA_VERSION=0.1.2
export BUILD_NUMBER=1
kitchen converge build-centos65-64
kitchen destroy build-centos65-64
kitchen test test
```
