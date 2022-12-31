project(
    'co.tauos.Fusebox',
    'c', 'vala',
    version: '0.1.0',
)

lib_version = '1.0'
gnome = import('gnome')

add_project_arguments([
        '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
        '-DG_LOG_DOMAIN="co.tauos.Fusebox"'
    ],
    language: 'c'
)
vapi_dir = join_paths(meson.current_source_dir(), 'vapi')
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

conf_data = configuration_data()
conf_data.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: conf_data
)

fuses_dir = get_option('prefix') / get_option('libdir') / 'fusebox-1'

i18n = import('i18n')
pkg = import('pkgconfig')

glib_dep = dependency('glib-2.0', version: '>=2.32')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
gmodule_dep = dependency('gmodule-2.0')
gtk_dep = dependency('gtk4', version: '>=3.10')
gee_dep = dependency('gee-0.8')
helium_dep = meson.get_compiler('c').find_library('libhelium', required: false)
bismuth_dep = meson.get_compiler('c').find_library('libbismuth', required: false)
m_dep = meson.get_compiler('c').find_library('m', required : false)

subdir('data')
subdir('lib')
subdir('src')
if get_option('example')
    subdir('sample')
endif

subdir('fuses')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)