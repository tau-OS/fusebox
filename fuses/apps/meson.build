# Rust crate that outputs a library
# using cargo

# meson project

cargo_bin  = find_program('cargo')
cargo_opt  = [ '--manifest-path', meson.project_source_root() / 'fuses/apps' / 'Cargo.toml' ]
cargo_opt += [ '--target-dir', meson.project_build_root() / 'fuses' / 'apps' ]
cargo_env  = [ 'CARGO_HOME=' + meson.project_build_root()  / 'cargo-home' ]
# meson-private/fusebox-1.pc
cargo_env += [ 'PKG_CONFIG_PATH=' + meson.project_build_root() / 'meson-private' ]
if get_option('buildtype') == 'release'
  cargo_options = [ '--release' ]
  rust_target = 'release'
else
  rust_target = 'debug'
endif

cargo_build = custom_target(
  'cargo-build',
  build_by_default: true,
  build_always_stale: true,
  output: 'fuse-apps.so',
  console: true,
  install: true,
  install_dir: join_paths(fuses_dir, 'system'),
  command: [
    'env', cargo_env,
    cargo_bin, 'build',
    cargo_opt, '&&', 'cp', meson.project_build_root() / 'fuses/apps' / rust_target / 'libfuseapps.so', '@OUTPUT@',
  ],
  depend_files: [
    meson.project_source_root() / 'fuses/apps' / 'Cargo.toml',
    meson.project_source_root() / 'fuses/apps' / 'src' / 'lib.rs',
    meson.project_build_root() / 'meson-private' / 'fusebox-1.pc',
  ],

  depends: [
    libfusebox_lib,
    # libfusebox_pc,
  ],
)


