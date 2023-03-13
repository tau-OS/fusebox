fuse_files = files(
    'src/Utils.vala',
    'src/SettingsDaemon.vala',
    'src/DisplayFuse.vala',
    'src/Interfaces/NightLightManager.vala',
    'src/Interfaces/MutterDisplayConfig.vala',
    'src/Objects/VirtualMonitor.vala',
    'src/Objects/MonitorMode.vala',
    'src/Objects/MonitorManager.vala',
    'src/Objects/Monitor.vala',
    'src/Views/NightLightView.vala',
    'src/Views/DisplaysView.vala',
    'src/Widgets/DisplayWidget.vala',
    'src/Widgets/DisplaysOverlay.vala',
)

shared_module('fuse-display',
    fuse_files,
    dependencies: [
        meson.get_compiler('vala').find_library('posix'),
        libfusebox_dep,
        dependency('libhelium-1'),
        dependency('libbismuth-1', version: '>=1.0.0'),
        dependency('gee-0.8'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)
