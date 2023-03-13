fuse_files = files(
    'LocaleFuse.vala',
    'LocaleView.vala',
    'LanguagePicker.vala',
    'FormatPicker.vala',
    'LanguageRow.vala',
    'Preview.vala',
    'Utils.vala',
)

shared_module('fuse-locale',
    fuse_files,
    dependencies: [
        meson.get_compiler('vala').find_library('posix'),
        libfusebox_dep,
        dependency('libhelium-1'),
        dependency('libbismuth-1', version: '>=1.0.0'),
        dependency('gnome-desktop-4'),
        dependency('gweather4', version: '>= 3.90.0'),
        dependency('accountsservice')
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'personal')
)
