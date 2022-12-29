fusebox_files = files(
    'Application.vala',
    'FusesSearch.vala',
    'CategoryView.vala',
    'SearchView.vala',
    'Widgets/CategoryIcon.vala',
    'Widgets/CategoryFlowBox.vala',
)

fusebox_deps = [
    libfusebox_dep,
    helium_dep,
    dependency('libbismuth-1', fallback: [ 'libbismuth', 'bismuth_dep' ], version: '>=1.0.0'),
    m_dep
]

executable(meson.project_name(),
    fusebox_files,
    asresources,
    conf_file,
    dependencies: fusebox_deps,
    install: true
)
