fuse_files = files(
    'AccountsFuse.vala',
    'AccountsView.vala',
    'AccountRow.vala',
    'Utils.vala',
    'EditAccount.vala',
)

shared_module('fuse-accounts',
    fuse_files,
    dependencies: [
        meson.get_compiler('vala').find_library('posix'),
        libfusebox_dep,
        dependency('libhelium-1'),
        dependency('libbismuth-1', version: '>=1.0.0'),
        dependency('accountsservice')
    ],
    install: true,
    install_dir: join_paths(fuses_dir, 'system')
)
