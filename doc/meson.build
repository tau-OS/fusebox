docgen = find_program('valadoc', required: get_option('documentation'))

dir = 'fusebox'
target = custom_target(
    'valadoc',
    command: [
        docgen,
        '--pkg=glib-2.0',
        '--pkg=gio-2.0',
        '--pkg=gio-unix-2.0',
        '--pkg=gobject-2.0',
        '--pkg=gtk4',
        '--pkg=posix', fusebox_sources,
        config_vapi_file,
        '--target-glib=' + glib_min_version,
        '--package-name=' + meson.project_name(),
        '--package-version=' + meson.project_version(),
        '--verbose',
        '--force',
        '--use-svg-images', # If documentation is true, we'll generate a GIR file with valadoc, independent of the main build
        '--gir', fusebox_gir,
        '-o', join_paths(meson.current_build_dir()),
        '&&',
        'cp',
        join_paths(meson.project_source_root() / 'doc' / 'style.css'),
        meson.current_build_dir(),
    ],

    build_by_default: true,
    output: dir,
    depends: libfusebox_lib,
)
