using Gee;

public class ColorGenerator {
    private const int SCHEME_COUNT = 6; // 6 entries on the He.SchemeVariant enum
    private const int COLORS_PER_SCHEME = 4;
    private const int DEFAULT_COLOR = 0x8C56BF; // Tau Purple as fallback

    private int[] argb_ints;
    private ArrayList<int> generated_colors;

    public ColorGenerator(int[] argb_ints) {
        this.argb_ints = argb_ints;
        this.generated_colors = new ArrayList<int>();
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
                        generated_colors.add(hex_to_int(dyn_scheme.get_secondary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_tertiary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_surface()));
                        break;
                    case He.SchemeVariant.MUTED:
                        var scheme = new He.MutedScheme();
                        var dyn_scheme = scheme.generate(hct, false, 0.0);
                        generated_colors.add(hex_to_int(dyn_scheme.get_primary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_secondary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_tertiary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_surface()));
                        break;
                    case He.SchemeVariant.VIBRANT:
                        var scheme = new He.VibrantScheme();
                        var dyn_scheme = scheme.generate(hct, false, 0.0);
                        generated_colors.add(hex_to_int(dyn_scheme.get_primary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_secondary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_tertiary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_surface()));
                        break;
                    case He.SchemeVariant.SALAD:
                        var scheme = new He.SaladScheme();
                        var dyn_scheme = scheme.generate(hct, false, 0.0);
                        generated_colors.add(hex_to_int(dyn_scheme.get_primary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_secondary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_tertiary()));
                        generated_colors.add(hex_to_int(dyn_scheme.get_surface()));
                        break;
                }
            }
        }
    }

    // Converts a hex color string to an int
    private int hex_to_int(string hex_color) {
        try {
            int res;
            int.try_parse(hex_color.replace("#", ""), out res, null, 16);
            return res;
        } catch (Error e) {
            warning("Error parsing hex color '%s': %s. Using default color.", hex_color, e.message);
            return DEFAULT_COLOR;
        }
    }

    // Retrieves the generated colors for a specified scheme
    public ArrayList<int> get_generated_colors(He.SchemeVariant scheme_variant) {
        int scheme_index = (int) scheme_variant;
        if (scheme_index < 0 || scheme_index >= SCHEME_COUNT) {
            warning("Scheme index %d is out of range. Returning default colors.", scheme_index);
            return get_default_colors();
        }

        var colors = new ArrayList<int>();
        int base_index = scheme_index * COLORS_PER_SCHEME;

        for (int i = 0; i < argb_ints.length; i++) {
            int offset = i * SCHEME_COUNT * COLORS_PER_SCHEME + base_index;
            debug("Calculated offset: %d for ARGB int index: %d, scheme index: %d", offset, i, scheme_index);

            // Safety check to avoid out-of-bounds access
            if (offset < 0 || offset + COLORS_PER_SCHEME > generated_colors.size) {
                warning("Offset out of bounds: %d. Returning default colors.", offset);
                return get_default_colors();
            }

            colors.add(generated_colors.get(offset));
            colors.add(generated_colors.get(offset + 1));
            colors.add(generated_colors.get(offset + 2));
            colors.add(generated_colors.get(offset + 3));
        }

        return colors;
    }

    // Retrieves the colors for a specific ARGB int and scheme
    public ArrayList<int> get_colors_for_argb(int index, He.SchemeVariant scheme_variant) {
        if (index < 0 || index >= argb_ints.length) {
            warning("Index %d out of range for ARGB values. Returning default colors.", index);
            return get_default_colors();
        }

        int scheme_index = (int) scheme_variant;
        if (scheme_index < 0 || scheme_index >= SCHEME_COUNT) {
            warning("Scheme index %d is out of range. Returning default colors.", scheme_index);
            return get_default_colors();
        }

        var colors = new ArrayList<int>();
        int base_index = index * SCHEME_COUNT * COLORS_PER_SCHEME + scheme_index * COLORS_PER_SCHEME;

        for (int i = 0; i < COLORS_PER_SCHEME; i++) {
            colors.add(generated_colors.get(base_index + i));
        }

        return colors;
    }

    // Provides a default set of colors
    private ArrayList<int> get_default_colors() {
        var default_colors = new ArrayList<int>();
        for (int i = 0; i <= COLORS_PER_SCHEME; i++) {
            default_colors.add(DEFAULT_COLOR);
        }
        return default_colors;
    }
}