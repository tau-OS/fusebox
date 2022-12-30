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
        helium_dep
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)