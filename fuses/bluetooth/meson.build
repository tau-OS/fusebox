fuse_files = files(
    'src/PairDialog.vala',
    'src/BluetoothFuse.vala',
    'src/MainView.vala',
    'src/DeviceRow.vala',
    'src/Services/Agent.vala',
    'src/Services/Manager.vala',
    'src/Services/Device.vala',
    'src/Services/Adapter.vala'
)

shared_module(
    'fuse-bluetooth',
    fuse_files,
    dependencies: [
        libfusebox_dep,
        meson.get_compiler('vala').find_library('posix'),
        dependency('libhelium-1'),
        dependency('libbismuth-1', version: '>=1.0.0'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'network')
)