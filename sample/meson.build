shared_module('fuse-sample',
    'SampleFuse.vala',
    dependencies: [
        libfusebox_dep,
        dependency('libhelium-1', fallback: [ 'libhelium', 'helium_dep' ])
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)
