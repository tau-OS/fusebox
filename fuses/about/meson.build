fuse_files = files(
    'AboutFuse.vala',
    'OSView.vala',
)

shared_module('fuse-about',
    fuse_files,
    dependencies: [
        dependency('libgtop-2.0'),
        dependency('gudev-1.0'),
        meson.get_compiler('vala').find_library('posix'),
        libfusebox_dep,
        dependency('libhelium-1', fallback: [ 'libhelium', 'helium_dep' ]),
        dependency('libbismuth-1', fallback: [ 'libbismuth', 'bismuth_dep' ], version: '>=1.0.0'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)