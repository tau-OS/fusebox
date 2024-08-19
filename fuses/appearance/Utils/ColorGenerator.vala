public class ColorGenerator : Object {
    private const int SCHEME_COUNT = 6; // 6 entries on the He.SchemeVariant enum
    private const int COLORS_PER_SCHEME = 4;
    private const int DEFAULT_COLOR = 0x8C56BF; // Tau Purple as fallback

    private int[] argb_ints;
    private Gee.ArrayList<int> generated_colors;

    public ColorGenerator(int[] argb_ints) {
        this.argb_ints = argb_ints;
        this.generated_colors = new Gee.ArrayList<int>();

        generate_colors();
    }

    // Generates colors for each ARGB int using the specified schemes
    private void generate_colors() {
        foreach (var argb_int in argb_ints) {
            var hct = He.hct_from_int(argb_int);

            for (int j = 0; j < SCHEME_COUNT; j++) {
                switch (j) {
                    default:
                    case He.SchemeVariant.DEFAULT:
                        var scheme = new He.DefaultScheme();
                        var dyn_scheme = scheme.generate(hct, false, 0.0);
                        generated_colors.add(hex_to_int(dyn_scheme.get_primary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_secondary_container()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_tertiary_container()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_primary()));
                        break;
                    case He.SchemeVariant.MUTED:
                        var scheme = new He.MutedScheme();
                        var dyn_scheme = scheme.generate(hct, false, 0.0);
                        generated_colors.add(hex_to_int(dyn_scheme.get_primary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_secondary_container()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_tertiary_container()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_primary()));
                        break;
                    case He.SchemeVariant.VIBRANT:
                        var scheme = new He.VibrantScheme();
                        var dyn_scheme = scheme.generate(hct, false, 0.0);
                        generated_colors.add(hex_to_int(dyn_scheme.get_primary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_secondary_container()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_tertiary_container()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_primary()));
                        break;
                    case He.SchemeVariant.SALAD:
                        var scheme = new He.SaladScheme();
                        var dyn_scheme = scheme.generate(hct, false, 0.0);
                        generated_colors.add(hex_to_int(dyn_scheme.get_primary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_secondary_container()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_tertiary_container()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_primary()));
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
    public Gee.ArrayList<int> get_generated_colors(He.SchemeVariant scheme_variant) {
        int scheme_index = (int) scheme_variant;

        var colors = new Gee.ArrayList<int>();
        int base_index = scheme_index * COLORS_PER_SCHEME;

        for (int i = 0; i < argb_ints.length; i++) {
            int offset = i * 4 * COLORS_PER_SCHEME + base_index;

            colors.add(generated_colors.get(offset));
            colors.add(generated_colors.get(offset + 1));
            colors.add(generated_colors.get(offset + 2));
            colors.add(generated_colors.get(offset + 3));
        }

        return colors;
    }
}