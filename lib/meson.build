config_vapi = meson.get_compiler('vala').find_library('config', dirs: meson.current_source_dir())

config_data = configuration_data()
config_data.set_quoted('FUSES_DIR', fuses_dir)

config_header = configure_file(
    configuration: config_data,
    output: 'config.h'
)

fusebox_sources = files(
    'FusesManager.vala',
    'Fuse.vala',
)

libfusebox_deps = [
    glib_dep,
    gio_dep,
    gio_unix_dep,
    gmodule_dep,
    gtk_dep,
]

# define all the names and versions
fusebox_gi_name = 'fusebox'
fusebox_gi_version = '1'

fusebox_gi = fusebox_gi_name + '-' + fusebox_gi_version
fusebox_gir = fusebox_gi + '.gir'
fusebox_typelib = fusebox_gi + '.typelib'

include_dir = join_paths(
    get_option('prefix'),
    get_option('includedir')
)

# compile shared library, generate GIR, header, and vapi file
datadir    = get_option('datadir')
libdir     = get_option('libdir')
typelibdir = get_option('libdir')  / 'girepository-1.0'

libfusebox_lib = library('fusebox-1',
    fusebox_sources,
    dependencies: [libfusebox_deps, config_vapi],

    vala_gir: fusebox_gir,
    vala_header: 'fusebox-1.h',
    vala_vapi: 'fusebox-1.vapi',

    version: fusebox_gi_version,
    install: true,
    install_dir: [true, include_dir, true, true],
)

pkg.generate(
    libfusebox_lib,
    filebase: 'fusebox-1',
    name: 'Fusebox',
    description: 'Fusebox API',
    version: meson.project_version(),
    subdirs: 'fusebox-1',
    variables: ['Fusesdir=${libdir}/fusebox-1'],
)

if get_option('introspection')
    # typelib generation isn't automated yet
    g_ir_compiler = find_program('g-ir-compiler')
    custom_target(
        fusebox_typelib,
        command: [
            g_ir_compiler,
            '--shared-library=@PLAINNAME@',
            '--output=@OUTPUT@',
            join_paths(meson.current_build_dir(), fusebox_gir),
        ],
        input: libfusebox_lib,
        output: fusebox_typelib,
        depends: libfusebox_lib,
        install: true,
        install_dir: join_paths(get_option('libdir'), 'girepository-1.0'),
    )
endif

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
