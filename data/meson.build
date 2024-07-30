po_extra_dir = join_paths(meson.project_source_root(), 'po', 'extra')

install_data(
    'settings.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
    rename: meson.project_name() + '.gschema.xml'
)

i18n.merge_file(
    input: 'settings.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: po_extra_dir,
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: 'settings.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: po_extra_dir,
    type: 'xml',
    install: true,
    install_dir: get_option('datadir') / 'metainfo',
)

icon_sizes = ['128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
        rename: meson.project_name() + '.svg'
    )
    install_data(
        join_paths('icons', i + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps'),
        rename: meson.project_name() + '.svg'
    )
endforeach

asresources = gnome.compile_resources(
  'asresources',
  'settings.gresources.xml',
  source_dir: meson.current_build_dir(),
  c_name: 'as',
  install_dir: get_option('datadir') / meson.project_name(),
)