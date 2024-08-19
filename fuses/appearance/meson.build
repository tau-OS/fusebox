fuse_files = files(
    'AppearanceFuse.vala',
    'Utils/ColorGenerator.vala',
    'Views/AppearanceView.vala',
    'Views/ContrastView.vala',
    'Views/TextView.vala',
    'Views/WindowView.vala',
    'Widgets/AccentColorButton.vala',
    'Widgets/EnsorFlowBox.vala',
    'Widgets/EnsorModeButton.vala',
    'Widgets/WallpaperGrid.vala',
    # 'Views/DockView.vala',
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
