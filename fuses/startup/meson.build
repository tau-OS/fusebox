fuse_files = files(
    'StartupFuse.vala',
    'StartupView.vala'
)


shared_module('fuse-startup',
    fuse_files,
    dependencies: [
        libfusebox_dep,
        meson.get_compiler('vala').find_library('posix'),
        dependency('libhelium-1', fallback: [ 'libhelium', 'helium_dep' ]),
        dependency('libbismuth-1', fallback: [ 'libbismuth', 'bismuth_dep' ], version: '>=1.0.0'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)