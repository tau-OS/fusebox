posix_dep = meson.get_compiler('vala').find_library('posix')
ibus_dep = dependency('ibus-1.0')

shared_module(
    'fuse-mouse',
    'MouseFuse.vala',
    'KeyboardView.vala',
    'MouseView.vala',
    'TouchpadView.vala',
    'LayoutPage.vala',
    'LayoutPageDisplay.vala',

    dependencies: [
        meson.get_compiler('vala').find_library('posix'),
        dependency('glib-2.0', version: '>=2.34'),
        dependency('gio-2.0', version: '>=2.34'),
        dependency('gobject-2.0', version: '>=2.34'),
        dependency('gee-0.8'),
        dependency('libxml-2.0'),
        posix_dep,
        ibus_dep,
        libfusebox_dep,
        dependency('libhelium-1'),
        dependency('libbismuth-1', version: '>=1.0.0'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system'),
)
