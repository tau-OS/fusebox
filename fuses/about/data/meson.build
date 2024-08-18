subdir('ui')

gresources = gnome.compile_resources(
    'resources',
    configure_file(
        input: 'gresource.xml.in',
        output: 'com.fyralabs.Fusebox.About.gresource.xml',
        configuration: {
            'APP_ID': 'com.fyralabs.Fusebox.About',
            'APP_PATH': '/com/fyralabs/Fusebox/About',
        },
    ),
    source_dir: meson.current_build_dir(),
    dependencies: blueprints,
    c_name: 'resources',
    install_dir: get_option('datadir') / meson.project_name(),
)

# add_project_arguments(
#     '--gresourcesdir',
#     meson.current_build_dir(),
#     language: ['vala'],
# )
