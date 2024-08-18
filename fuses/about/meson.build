subdir('data')

fuse_files = files(
    'AboutFuse.vala',
    'OSView.vala',
)

shared_module('fuse-about',
    gresources,
    fuse_files,
    dependencies: [
        dependency('libgtop-2.0'),
        dependency('gudev-1.0'),
        dependency('udisks2'),
        meson.get_compiler('vala').find_library('posix'),
        libfusebox_dep,
        dependency('libhelium-1'),
        dependency('libbismuth-1', version: '>=1.0.0'),
        dependency('gl'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)
