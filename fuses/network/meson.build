fuse_files = files(
  'NetworkFuse.vala',
  'ProxySection.vala',
  'VPNSection.vala',
  'WifiSection.vala',
  'WiredSection.vala',
)

shared_module(
  'fuse-network',
  fuse_files,
  dependencies: [
    meson.get_compiler('vala').find_library('posix'),
    dependency('glib-2.0', version: '>=2.34'),
    dependency('gio-2.0', version: '>=2.34'),
    dependency('gobject-2.0', version: '>=2.34'),
    libfusebox_dep,
    dependency('libhelium-1'),
    dependency('gtk4', version: '>=4.12'),
    dependency('libnm', version: '>=1.2'),
  ],
  install: true,
  install_dir: join_paths(fuses_dir, 'network'),
)
