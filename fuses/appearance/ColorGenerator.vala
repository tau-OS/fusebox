public class ColorGenerator {
    private const int SCHEME_COUNT = 4;
    private const int COLORS_PER_SCHEME = 4;
    private const int DEFAULT_COLOR = 0x8C56BF; // tau purple as fallback

    private int[] argb_ints;
    private int[] generated_colors;

    public ColorGenerator(int[] argb_ints) {
        this.argb_ints = argb_ints;
        this.generated_colors = new int[argb_ints.length * SCHEME_COUNT * COLORS_PER_SCHEME];
        generate_colors();
    }

    // Generates colors for each ARGB int using the specified schemes
    private void generate_colors() {
        for (int i = 0; i < argb_ints.length; i++) {
            var hct = He.hct_from_int(argb_ints[i]);

            for (int j = 0; j < SCHEME_COUNT; j++) {
                switch (j) {
                    default:
                    case He.SchemeVariant.DEFAULT:
                        var scheme = new He.DefaultScheme();
                        var dyn_scheme = scheme.generate(hct, false, 0.0);
                        int base_index = i * SCHEME_COUNT * COLORS_PER_SCHEME + j * COLORS_PER_SCHEME;
                        generated_colors[base_index] = hex_to_int(dyn_scheme.get_primary());
                        generated_colors[base_index + 1] = hex_to_int(dyn_scheme.get_secondary());
                        generated_colors[base_index + 2] = hex_to_int(dyn_scheme.get_tertiary());
                        generated_colors[base_index + 3] = hex_to_int(dyn_scheme.get_surface());
                        break;
                    case He.SchemeVariant.MUTED:
                        var scheme = new He.MutedScheme();
                        var dyn_scheme = scheme.generate(hct, false, 0.0);
                        int base_index = i * SCHEME_COUNT * COLORS_PER_SCHEME + j * COLORS_PER_SCHEME;
                        generated_colors[base_index] = hex_to_int(dyn_scheme.get_primary());
                        generated_colors[base_index + 1] = hex_to_int(dyn_scheme.get_secondary());
                        generated_colors[base_index + 2] = hex_to_int(dyn_scheme.get_tertiary());
                        generated_colors[base_index + 3] = hex_to_int(dyn_scheme.get_surface());
                        break;
                    case He.SchemeVariant.VIBRANT:
                        var scheme = new He.VibrantScheme();
                        var dyn_scheme = scheme.generate(hct, false, 0.0);
                        int base_index = i * SCHEME_COUNT * COLORS_PER_SCHEME + j * COLORS_PER_SCHEME;
                        generated_colors[base_index] = hex_to_int(dyn_scheme.get_primary());
                        generated_colors[base_index + 1] = hex_to_int(dyn_scheme.get_secondary());
                        generated_colors[base_index + 2] = hex_to_int(dyn_scheme.get_tertiary());
                        generated_colors[base_index + 3] = hex_to_int(dyn_scheme.get_surface());
                        break;
                    case He.SchemeVariant.SALAD:
                        var scheme = new He.SaladScheme();
                        var dyn_scheme = scheme.generate(hct, false, 0.0);
                        int base_index = i * SCHEME_COUNT * COLORS_PER_SCHEME + j * COLORS_PER_SCHEME;
                        generated_colors[base_index] = hex_to_int(dyn_scheme.get_primary());
                        generated_colors[base_index + 1] = hex_to_int(dyn_scheme.get_secondary());
                        generated_colors[base_index + 2] = hex_to_int(dyn_scheme.get_tertiary());
                        generated_colors[base_index + 3] = hex_to_int(dyn_scheme.get_surface());
                        break;
                }
            }
        }
    }

    // Converts a hex color string to an int
    private int hex_to_int(string hex_color) {
        int res;
        int.try_parse(hex_color.replace("#", ""), out res, null, 16);
        return res;
    }

    // Retrieves the generated colors for a specified scheme
    public int[] get_generated_colors(He.SchemeVariant scheme_variant) {
        int scheme_index = (int) scheme_variant;
        if (scheme_index < 0 || scheme_index >= SCHEME_COUNT) {
            warning("Scheme index %d is out of range. Returning default colors.", scheme_index);
            return get_default_colors();
        }

        int[] colors = new int[argb_ints.length * COLORS_PER_SCHEME];
        int base_index = scheme_index * COLORS_PER_SCHEME;

        for (int i = 0; i < argb_ints.length; i++) {
            int offset = i * COLORS_PER_SCHEME;
            colors[offset] = generated_colors[i * SCHEME_COUNT * COLORS_PER_SCHEME + base_index];
            colors[offset + 1] = generated_colors[i * SCHEME_COUNT * COLORS_PER_SCHEME + base_index + 1];
            colors[offset + 2] = generated_colors[i * SCHEME_COUNT * COLORS_PER_SCHEME + base_index + 2];
            colors[offset + 3] = generated_colors[i * SCHEME_COUNT * COLORS_PER_SCHEME + base_index + 3];
        }

        return colors;
    }

    // Retrieves the colors for a specific ARGB int and scheme
    public int[] get_colors_for_argb(int index, He.SchemeVariant scheme_variant) {
        if (index < 0 || index >= argb_ints.length) {
            warning("Index %d out of range for ARGB values. Returning default colors.", index);
            return get_default_colors();
        }

        int scheme_index = (int) scheme_variant;
        if (scheme_index < 0 || scheme_index >= SCHEME_COUNT) {
            warning("Scheme index %d is out of range. Returning default colors.", scheme_index);
            return get_default_colors();
        }

        int[] colors = new int[COLORS_PER_SCHEME];
        int base_index = scheme_index * COLORS_PER_SCHEME;

        for (int i = 0; i < COLORS_PER_SCHEME; i++) {
            colors[i] = generated_colors[index * SCHEME_COUNT * COLORS_PER_SCHEME + base_index + i];
        }

        return colors;
    }

    // Provides a default set of colors
    private int[] get_default_colors() {
        int[] default_colors = new int[COLORS_PER_SCHEME];
        for (int i = 0; i < COLORS_PER_SCHEME; i++) {
            default_colors[i] = DEFAULT_COLOR;
        }
        return default_colors;
    }
}