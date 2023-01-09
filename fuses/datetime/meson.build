fuse_files = files(
    'DateTimeFuse.vala',
    'DateTimeView.vala',

    # Helpers
    'WorldLocationFinder.vala',
    'CurrentTimeManager.vala',
    'DatePicker.vala',
    'TimePicker.vala',
)

shared_module(
    'fuse-datetime',
    fuse_files,
    dependencies: [
        libfusebox_dep,
        meson.get_compiler('vala').find_library('posix'),
        dependency('libhelium-1'),
        dependency('gweather4', version: '>= 3.90.0'),
        dependency('libbismuth-1', fallback: [ 'libbismuth', 'bismuth_dep' ], version: '>=1.0.0'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)