project(
  'com.fyralabs.Fusebox',
  'c',
  'vala',
  version: '1.0.0',
)

gnome = import('gnome')

add_project_arguments(
  [
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    '-DG_LOG_DOMAIN="com.fyralabs.Fusebox"',
    '-DGNOME_DESKTOP_USE_UNSTABLE_API',
    '-w',
  ],
  language: 'c',
)
vapi_dir = join_paths(meson.current_source_dir(), 'vapi')
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

conf_data = configuration_data()
conf_data.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_file = configure_file(input: 'src/Config.vala.in', output: '@BASENAME@', configuration: conf_data)

fuses_dir = get_option('prefix') / get_option('libdir') / 'fusebox-1'

i18n = import('i18n')
pkg = import('pkgconfig')

glib_min_version = '2.50'

glib_dep = dependency('glib-2.0', version: '>=2.72')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
gmodule_dep = dependency('gmodule-2.0')
gtk_dep = dependency('gtk4')
helium_dep = dependency('libhelium-1')
bismuth_dep = dependency('libbismuth-1', version: '>=1.0.0', required: true)
m_dep = meson.get_compiler('c').find_library('m', required: false)

subdir('data')
subdir('lib')
subdir('src')
if get_option('example')
  subdir('sample')
endif

subdir('fuses')

if get_option('documentation')
  subdir('doc')
endif

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)

devenv = environment()
devenv.set('FUSES_DIR', meson.current_build_dir() / 'fuses')
meson.add_devenv(devenv)
