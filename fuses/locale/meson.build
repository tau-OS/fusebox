fuse_files = files(
    'LocaleFuse.vala',
    'LocaleView.vala',
    'LanguagePicker.vala',
    'FormatPicker.vala',
    'LanguageRow.vala',
    'Utils.vala',
)

shared_module('fuse-locale',
    fuse_files,
    dependencies: [
        meson.get_compiler('vala').find_library('posix'),
        libfusebox_dep,
        dependency('libhelium-1'),
        dependency('libbismuth-1', fallback: [ 'libbismuth', 'bismuth_dep' ], version: '>=1.0.0'),
        dependency('gnome-desktop-4'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)
