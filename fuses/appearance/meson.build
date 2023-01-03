fuse_files = files(
    'AppearanceFuse.vala',
    'AppearanceView.vala',
    'WallpaperGrid.vala',
    'DockView.vala',
)

shared_module(
    'fuse-appearance',
    fuse_files,
    dependencies: [
        libfusebox_dep,
        meson.get_compiler('vala').find_library('posix'),
        dependency('libhelium-1'),
        dependency('libbismuth-1', fallback: [ 'libbismuth', 'bismuth_dep' ], version: '>=1.0.0'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)