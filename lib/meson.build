config_vapi = meson.get_compiler('vala').find_library('config', dirs: meson.current_source_dir())

config_data = configuration_data()
config_data.set_quoted('FUSES_DIR', fuses_dir)

config_header = configure_file(
    configuration: config_data,
    output: 'config.h'
)

libfusebox_deps = [
    glib_dep,
    gio_dep,
    gio_unix_dep,
    gmodule_dep,
    gee_dep,
    gtk_dep,
]

libfusebox_lib = library('fusebox-1',
    'FusesManager.vala',
    'Fuse.vala',
    config_header,
    dependencies: [libfusebox_deps, config_vapi],
    vala_header: 'fusebox.h',
    soversion: '0',
    version: lib_version,
    install: true,
    install_dir: [true, join_paths(get_option('includedir'), 'fusebox-1'), true]
)

pkg.generate(
    filebase: 'fusebox-1',
    name: 'Fusebox',
    description: 'Fusebox API',
    version: meson.project_version(),
    subdirs: 'fusebox-1',
    variables: ['Fusesdir=${libdir}/fusebox-1'],
    libraries: libfusebox_lib,
    requires: libfusebox_deps
)

install_data(
    'fusebox-1.deps',
    install_dir: join_paths(get_option('datadir'), 'vala', 'vapi')
)

libfusebox_dir = include_directories('.')
libfusebox_dep = declare_dependency(
    link_with: libfusebox_lib,
    dependencies: [libfusebox_deps, config_vapi],
    include_directories: libfusebox_dir
)
