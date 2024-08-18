fusebox_files = files(
    'Widgets/CategoryFlowBox.vala',
    'Widgets/CategoryIcon.vala',
    'Application.vala',
    'CategoryView.vala',
    'FusesSearch.vala',
    'SearchView.vala',
)

fusebox_deps = [
    libfusebox_dep,
    dependency('libhelium-1'),
    dependency('libbismuth-1'),
    m_dep,
]

executable(
    meson.project_name(),
    fusebox_files,
    asresources,
    conf_file,
    dependencies: fusebox_deps,
    install: true,
)
