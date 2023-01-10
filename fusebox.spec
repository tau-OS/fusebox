%define glib2_version 2.72.0
%define gnome_desktop_version 42.0
%define gsd_version 42.1
%define gsettings_desktop_schemas_version 42.0
%define gtk4_version 4.6.2
%define libhelium_version 1.0
%define libbismuth_version 1.0
%global debug_package %{nil}

Name:           fusebox
Version:        0.1.0
Release:        1
Summary:        Change system and user settings.

License:        GPLv3+ and CC-BY-SA
URL:            https://github.com/tau-OS/fusebox
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
Requires: libhelium%{?_isa} >= %{libhelium_version}
Requires: libbismuth%{?_isa} >= %{libbismuth_version}
Requires: glib2%{?_isa} >= %{glib2_version}
Requires: gnome-desktop4%{?_isa} >= %{gnome_desktop_version}
Requires: gnome-settings-daemon%{?_isa} >= %{gsd_version}
Requires: gsettings-desktop-schemas%{?_isa} >= %{gsettings_desktop_schemas_version}
Requires: gtk4%{?_isa} >= %{gtk4_version}
Requires: accountsservice
 
%description
This package contains the settings application for the tauOS desktop, which
allows to configure keyboard and mouse properties, sound setup, desktop theme
and background, user interface properties, screen resolution, and other settings.
 
%prep
%autosetup

%build
%meson
%meson_build

%install
%meson_install

%files
%{_bindir}/co.tauos.Fusebox
%{_datadir}/applications/co.tauos.Fusebox.desktop
%{_datadir}/glib-2.0/schemas/co.tauos.Fusebox.gschema.xml
%{_datadir}/icons/hicolor/scalable/apps/co.tauos.Fusebox.svg
%{_datadir}/appdata/co.tauos.Fusebox.appdata.xml

%changelog
* Tue Jan 10 2023 Lains <lainsce@airmail.cc> - 0.1.0-1
- Initial Release
