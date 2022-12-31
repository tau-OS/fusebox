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
    dependency('libhelium-1', fallback: [ 'libhelium', 'helium_dep' ]),
    dependency('libbismuth-1', fallback: [ 'libbismuth', 'bismuth_dep' ]),
    m_dep
]

executable(meson.project_name(),
    fusebox_files,
    asresources,
    conf_file,
    dependencies: fusebox_deps,
    install: true
)
