fuse_files = files(
    'AppearanceFuse.vala',
    'AppearanceView.vala',
    'ContrastView.vala',
    'WallpaperGrid.vala',
    'TextView.vala',
    'WindowView.vala',
    'Utils/ColorGenerator.vala',
    'Widgets/EnsorModeButton.vala',
    'Widgets/EnsorFlowBox.vala',
    # 'DockView.vala',
)

shared_module(
    'fuse-appearance',
    fuse_files,
    dependencies: [
        libfusebox_dep,
        meson.get_compiler('vala').find_library('posix'),
        dependency('libhelium-1'),
        dependency('gee-0.8'),
        dependency('gexiv2'),
        dependency('libbismuth-1', version: '>=1.0.0'),
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'personal')
)
