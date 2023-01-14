fuse_files = files(
    'StartupFuse.vala',
    'StartupView.vala',
    'Utils.vala',
    'StartupAppDialog.vala',
    'Backend/DesktopFileEnumerator.vala',
    'Backend/KeyFile.vala',
    'Backend/KeyFileFactory.vala',
    'Backend/Monitor.vala',
    'Entities/AppInfo.vala'
)


shared_module('fuse-startup',
    fuse_files,
    dependencies: [
        meson.get_compiler('vala').find_library('posix'),
        libfusebox_dep,
        dependency('libhelium-1'),
        dependency('libbismuth-1', fallback: [ 'libbismuth', 'bismuth_dep' ], version: '>=1.0.0'),
        dependency('glib-2.0', version: '>=2.34'),
        dependency('gio-2.0', version: '>=2.34'),
        dependency('gobject-2.0', version: '>=2.34'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)