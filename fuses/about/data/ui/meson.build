blueprint_sources = ['OSView.blp']

blueprints = custom_target('blueprints',
    input: files(blueprint_sources),
    output: '.',
    command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTDIR@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

# This is a temporary workaround to fix a bug with the Vala compiler
blueprints_workaround = custom_target('blueprints_workaround',
  input: blueprints,
  output: 'blueprints_workaround.vala',
  command: [find_program('touch'), '@OUTPUT@'],
)
