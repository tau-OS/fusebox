fuse_files = files(
  'src/Device.vala',
  'src/DeviceRow.vala',
  'src/InputDeviceMonitor.vala',
  'src/InputPanel.vala',
  'src/OutputPanel.vala',
  'src/PulseAudioManager.vala',
  'src/SoundFuse.vala',
)

shared_module(
  'fuse-sound',
  fuse_files,
  dependencies: [
    meson.get_compiler('vala').find_library('posix'),
    libfusebox_dep,
    dependency('libhelium-1'),
    dependency('libbismuth-1', version: '>=1.0.0'),
    dependency('glib-2.0', version: '>=2.34'),
    dependency('gio-2.0', version: '>=2.34'),
    dependency('gee-0.8'),
    dependency('gobject-2.0', version: '>=2.34'),
    dependency('libpulse', version: '>=1.0'),
    dependency('libpulse-mainloop-glib', version: '>=1.0'),
    meson.get_compiler('vala').find_library('libpulse-ext', dirs: join_paths(meson.current_source_dir(), 'vapi')),
  ],
  install: true,
  install_dir: join_paths(fuses_dir, 'system'),
)
