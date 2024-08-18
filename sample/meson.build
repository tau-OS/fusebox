shared_module(
    'fuse-sample',
    'SampleFuse.vala',
    dependencies: [
        meson.get_compiler('vala').find_library('posix'),
        dependency('glib-2.0', version: '>=2.34'),
        dependency('gio-2.0', version: '>=2.34'),
        dependency('gobject-2.0', version: '>=2.34'),
        libfusebox_dep,
        dependency('libhelium-1'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system'),
)
