# Fusebox

## Fuses

Fusebox is a container application, that provides settings as Fuses, for various hardware and software.

## Building, Testing, and Installation

You'll need the following dependencies:

```
libglib2.0-dev
libgtk-4-dev
libhelium-1-dev
libbismuth-1-dev
meson
valac
```

Run `meson` to configure the build environment and then `ninja` to build

```sh
meson build --prefix=/usr
cd build
ninja
```

To install, use `ninja install` then execute with `com.fyralabs.Fusebox`

```sh
sudo ninja install
com.fyralabs.Fusebox
```
