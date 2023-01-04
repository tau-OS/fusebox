# Fusebox

![Fusebox Screenshot](data/screenshot.png?raw=true)

## Fuses

Fusebox is just the container application for Fusebox Fuses, which provide the actual settings for various hardware and software.

## Building, Testing, and Installation

You'll need the following dependencies:

- libglib2.0-dev
- libgtk-4-dev
- libhelium-1-dev
- libbismuth-1-dev
- meson
- valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install` then execute with `co.tauos.Fusebox`

    sudo ninja install
    co.tauos.Fusebox
