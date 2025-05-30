public class ColorGenerator : Object {
    private const int SCHEME_COUNT = 4; // Only process schemes we actually use
    private const int COLORS_PER_SCHEME = 4;
    private const int DEFAULT_COLOR = 0x8C56BF; // Tau Purple as fallback

    private int[] argb_ints;
    private Gee.ArrayList<int> generated_colors;
    private bool colors_generated = false;

    public ColorGenerator(int[] argb_ints) {
        this.argb_ints = argb_ints;
        this.generated_colors = new Gee.ArrayList<int> ();
    }

    private void ensure_colors_generated() {
        if (colors_generated) {
            return;
        }

        generate_colors();
        colors_generated = true;
    }

    private void generate_colors() {
        foreach (var argb_int in argb_ints) {
            var hct = He.hct_from_int(argb_int);

            // Process only the schemes we actually use
            add_scheme_colors(hct, He.SchemeVariant.DEFAULT);
            add_scheme_colors(hct, He.SchemeVariant.MUTED);
            add_scheme_colors(hct, He.SchemeVariant.VIBRANT);
            add_scheme_colors(hct, He.SchemeVariant.SALAD);
        }
    }

    private void add_scheme_colors(He.HCTColor hct, He.SchemeVariant variant) {
        He.DynamicScheme? dyn_scheme = create_scheme(hct, variant);
        if (dyn_scheme == null) {
            for (int i = 0; i < COLORS_PER_SCHEME; i++) {
                generated_colors.add(DEFAULT_COLOR);
            }
            return;
        }

        generated_colors.add(hex_to_int_optimized(dyn_scheme.get_primary()));
        generated_colors.add(hex_to_int_optimized(dyn_scheme.get_secondary_container()));
        generated_colors.add(hex_to_int_optimized(dyn_scheme.get_tertiary_container()));
        generated_colors.add(hex_to_int_optimized(dyn_scheme.get_primary()));
    }

    private He.DynamicScheme? create_scheme(He.HCTColor hct, He.SchemeVariant variant) {
        switch (variant) {
        default :
        case He.SchemeVariant.DEFAULT :
            var scheme = new He.DefaultScheme();
            return scheme.generate(hct, false, 0.0);
        case He.SchemeVariant.MUTED:
            var scheme = new He.MutedScheme();
            return scheme.generate(hct, false, 0.0);
        case He.SchemeVariant.VIBRANT:
            var scheme = new He.VibrantScheme();
            return scheme.generate(hct, false, 0.0);
        case He.SchemeVariant.SALAD:
            var scheme = new He.SaladScheme();
            return scheme.generate(hct, false, 0.0);
        }
    }

    // Optimized hex parsing
    private int hex_to_int_optimized(string hex_color) {
        if (hex_color.length == 0) {
            return DEFAULT_COLOR;
        }

        string clean_hex = hex_color;
        if (hex_color.has_prefix("#")) {
            clean_hex = hex_color[1 : hex_color.length];
        }

        int result;
        if (int.try_parse(clean_hex, out result, null, 16)) {
            return result;
        }

        return DEFAULT_COLOR;
    }

    // Retrieves the generated colors for a specified scheme
    public Gee.ArrayList<int> get_generated_colors(He.SchemeVariant scheme_variant) {
        ensure_colors_generated(); // Lazy generation

        int scheme_index = (int) scheme_variant;
        if (scheme_index >= SCHEME_COUNT) {
            warning("Invalid scheme variant: %d", scheme_index);
            return new Gee.ArrayList<int> ();
        }

        var colors = new Gee.ArrayList<int> ();
        int base_index = scheme_index * COLORS_PER_SCHEME;

        for (int i = 0; i < argb_ints.length; i++) {
            int offset = i * SCHEME_COUNT * COLORS_PER_SCHEME + base_index;

            // Bounds checking
            if (offset + 3 < generated_colors.size) {
                colors.add(generated_colors.get(offset));
                colors.add(generated_colors.get(offset + 1));
                colors.add(generated_colors.get(offset + 2));
                colors.add(generated_colors.get(offset + 3));
            } else {
                warning("Color index out of bounds");
                // Add fallback colors
                for (int j = 0; j < COLORS_PER_SCHEME; j++) {
                    colors.add(DEFAULT_COLOR);
                }
            }
        }

        return colors;
    }

    // Helper method to check if colors are ready
    public bool has_generated_colors() {
        return colors_generated;
    }
}
