%define glib2_version 2.72.0
%define gnome_desktop_version 42.0
%define gsd_version 42.1
%define gsettings_desktop_schemas_version 42.0
%define gtk4_version 4.6.2
%define libhelium_version 1.0
%global debug_package %{nil}

Summary:        Change system and user settings
Name:           fusebox
Version:        0.1.0
Release:        1
License:        GPLv2+ and CC-BY-SA
URL:            https://tauos.co
Source0:        https://github.com/tau-OS/fusebox/archive/refs/heads/main.zip
BuildRequires:  gcc
BuildRequires:  gettext
BuildRequires:  meson
BuildRequires:  git
BuildRequires:  pkgconfig(accountsservice)
BuildRequires:  pkgconfig(gio-2.0) >= %{glib2_version}
BuildRequires:  pkgconfig(gnome-desktop-4) >= %{gnome_desktop_version}
BuildRequires:  pkgconfig(gnome-settings-daemon) >= %{gsd_version}
BuildRequires:  pkgconfig(gsettings-desktop-schemas) >= %{gsettings_desktop_schemas_version}
BuildRequires:  pkgconfig(gtk4) >= %{gtk4_version}
BuildRequires:  pkgconfig(gudev-1.0)
BuildRequires:  libhelium-devel
BuildRequires:  pkgconfig(libgtop-2.0)
BuildRequires:  pkgconfig(x11)
 
# Versioned library deps
Requires: libhelium%{?_isa} >= %{libhelium_version}
Requires: glib2%{?_isa} >= %{glib2_version}
Requires: gnome-desktop4%{?_isa} >= %{gnome_desktop_version}
Requires: gnome-settings-daemon%{?_isa} >= %{gsd_version}
Requires: gsettings-desktop-schemas%{?_isa} >= %{gsettings_desktop_schemas_version}
Requires: gtk4%{?_isa} >= %{gtk4_version}
Requires: accountsservice
 
%description
This package contains the settings application for the tauOS desktop, which
allows to configure accessibility options, desktop fonts, keyboard and mouse
properties, sound setup, desktop theme and background, user interface
properties, screen resolution, and other settings.
 
%prep
%autosetup -n fusebox -Sgit
git init
git remote add origin https://github.com/tau-OS/fusebox
# git fetch origin
git pull -v origin main --force --rebase

%build
%meson -Dsample=false
%meson_build

%install
%meson_install
%license COPYING
%doc README.md

%changelog
* Sat Dec 30 2022 Lains <lainsce@airmail.cc> - 0.1.0-1
- Initial Release