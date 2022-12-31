fuse_files = files(
    'AppearanceFuse.vala',
    'AppearanceView.vala'
)

shared_module('fuse-appearance',
    fuse_files,
    dependencies: [
        libfusebox_dep,
        dependency('libhelium-1', fallback: [ 'libhelium', 'helium_dep' ]),
        dependency('libbismuth-1', fallback: [ 'libbismuth', 'bismuth_dep' ], version: '>=1.0.0'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)