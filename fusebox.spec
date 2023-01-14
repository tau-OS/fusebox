%define glib2_version 2.72.0
%define gnome_desktop_version 42.0
%define gsd_version 42.1
%define gsettings_desktop_schemas_version 42.0
%define gtk4_version 4.6.2
%define libhelium_version 1.0
%global debug_package %{nil}
%global geoclue2_version 2.6.0

Name:           fusebox
Version:        0.1.6
Release:        2
Summary:        Change system and user settings.

License:        GPLv3+ and CC-BY-SA
URL:            https://github.com/tau-OS/fusebox
Source0:        https://github.com/tau-OS/fusebox/archive/refs/heads/main.zip

BuildRequires:  chrpath
BuildRequires:  gcc
BuildRequires:  gettext
BuildRequires:  meson
BuildRequires:  git
BuildRequires:  desktop-file-utils
BuildRequires:  vala
BuildRequires:  pkgconfig(accountsservice)
BuildRequires:  pkgconfig(gio-2.0) >= %{glib2_version}
BuildRequires:  pkgconfig(gnome-desktop-4) >= %{gnome_desktop_version}
BuildRequires:  pkgconfig(gnome-settings-daemon) >= %{gsd_version}
BuildRequires:  pkgconfig(gsettings-desktop-schemas) >= %{gsettings_desktop_schemas_version}
BuildRequires:  pkgconfig(gtk4) >= %{gtk4_version}
BuildRequires:  pkgconfig(gudev-1.0)
BuildRequires:  libhelium-devel
BuildRequires:  libbismuth-devel
BuildRequires:  pkgconfig(libgtop-2.0)
BuildRequires:  pkgconfig(x11)
BuildRequires:  pkgconfig(udisks2)
BuildRequires:  pkgconfig(geocode-glib-2.0)
BuildRequires:  pkgconfig(gweather4)
BuildRequires:  pkgconfig(libgeoclue-2.0) >= %{geoclue2_version}
BuildRequires:  pkgconfig(ibus-1.0)
BuildRequires:  pkgconfig(pwquality)

Requires: libhelium%{?_isa} >= %{libhelium_version}
Requires: libbismuth%{?_isa} >= %{libhelium_version}
Requires: glib2%{?_isa} >= %{glib2_version}
Requires: gnome-desktop4%{?_isa} >= %{gnome_desktop_version}
Requires: gnome-settings-daemon%{?_isa} >= %{gsd_version}
Requires: gsettings-desktop-schemas%{?_isa} >= %{gsettings_desktop_schemas_version}
Requires: gtk4%{?_isa} >= %{gtk4_version}
Requires: accountsservice
Requires: iso-codes
Requires: alsa-lib
Requires: cups-pk-helper
Requires: dbus

Recommends: NetworkManager-wifi
Recommends: nm-connection-editor
Recommends: gnome-remote-desktop
Recommends: rygel
Recommends: switcheroo-control

%description
This package contains the settings application for the tauOS desktop, which
allows to configure keyboard and mouse properties, sound setup, desktop theme
and background, user interface properties, screen resolution, and other settings.

%package devel
Summary:        Development files for fusebox
Requires:       fusebox = %{version}-%{release}

%description devel
This package contains the libraries and header files that are needed
for settings fuses for fusebox.

%prep
%autosetup -n fusebox-main -Sgit
git init
git remote add origin https://github.com/tau-OS/fusebox
git pull -v origin main --force --rebase
git submodule update --init --recursive

%build
%meson
%meson_build

%install
%meson_install

%files
%{_bindir}/co.tauos.Fusebox
%{_datadir}/applications/co.tauos.Fusebox.desktop
%{_datadir}/glib-2.0/schemas/co.tauos.Fusebox.gschema.xml
%{_datadir}/metainfo/co.tauos.Fusebox.appdata.xml
%{_libdir}/fusebox-1/personal/libfuse-appearance.so
%{_libdir}/fusebox-1/system/libfuse-about.so
%{_libdir}/fusebox-1/system/libfuse-datetime.so
%{_libdir}/fusebox-1/system/libfuse-startup.so
%{_libdir}/fusebox-1/system/libfuse-locale.so
%{_libdir}/girepository-1.0/fusebox-1.typelib
%{_libdir}/libfusebox-1.so
%{_libdir}/libfusebox-1.so.1
%{_datadir}/icons/hicolor/128x128/apps/co.tauos.Fusebox.svg
%{_datadir}/icons/hicolor/128x128@2/apps/co.tauos.Fusebox.svg

%files devel
%{_datadir}/vala/vapi/fusebox-1.deps
%{_datadir}/vala/vapi/fusebox-1.vapi
%{_libdir}/pkgconfig/fusebox-1.pc
%{_datadir}/gir-1.0/fusebox-1.gir
%{_includedir}/fusebox-1.h

%changelog
* Tue Jan 10 2023 Lains <lainsce@airmail.cc> - 0.1.0-1
- Initial Release
