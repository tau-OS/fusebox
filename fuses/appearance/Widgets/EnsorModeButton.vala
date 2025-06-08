public class EnsorModeButton : Gtk.Box {
    private const int DEFAULT_COLOR = 0x8C56BF; // Tau Purple as fallback

    public Gee.ArrayList<int> colors;
    ColorGenerator generator;

    private string _mode;
    public string mode {
        get { return _mode; }
        set {
            if (_mode != value) {
                _mode = value;
                update_colors();
                queue_draw();
            }
        }
    }

    public EnsorModeButton(int color, string initial_mode) {
        string validated_mode = is_valid_mode(initial_mode) ? initial_mode : "default";
        if (validated_mode != initial_mode) {
            warning("Invalid initial mode '%s'. Using default mode.", initial_mode);
        }

        this.mode = validated_mode;
        generator = new ColorGenerator({ color });

        var generated_colors = generator.get_generated_colors(get_scheme_variant(mode));
        if (generated_colors.size < 4) {
            warning("Generated colors are insufficient. Using default colors.");
            generated_colors = new Gee.ArrayList<int> ();
            for (int i = 0; i < 4; i++) {
                generated_colors.add(DEFAULT_COLOR);
            }
        }

        this.colors = generated_colors;

        overflow = HIDDEN;
        add_css_class("circle-radius");
    }

    private void update_colors() {
        if (!is_valid_mode(mode)) {
            warning("Invalid mode '%s'. Using default colors.", mode);
            mode = "default";
        }

        var updated_colors = generator.get_generated_colors(get_scheme_variant(mode));
        if (updated_colors.size < 4) {
            warning("Updated colors are insufficient. Using default colors.");
            updated_colors = new Gee.ArrayList<int> ();
            for (int i = 0; i < 4; i++) {
                updated_colors.add(DEFAULT_COLOR);
            }
        }

        this.colors = updated_colors;
        queue_draw();
    }

    public void set_colors(Gee.ArrayList<int> colors) {
        if (colors.size < 4) {
            warning("EnsorModeButton requires at least 4 colors. Ignoring update.");
            return;
        }

        this.colors = colors;
        queue_draw();
    }

    private He.SchemeVariant get_scheme_variant(string mode) {
        switch (mode) {
        default:
        case "default":
            return He.SchemeVariant.DEFAULT;
        case "muted":
            return He.SchemeVariant.MUTED;
        case "vibrant":
            return He.SchemeVariant.VIBRANT;
        case "salad":
            return He.SchemeVariant.SALAD;
        }
    }

    private bool is_valid_mode(string mode) {
        return mode == "default" || mode == "muted" || mode == "vibrant" || mode == "salad";
    }

    public override void snapshot(Gtk.Snapshot snapshot) {
        int w = get_width();
        int h = get_height();

        float r = 999;

        snapshot.translate({ w / 2, h / 2 });

        Gsk.RoundedRect rect = {};
        rect.init_from_rect({ { -r, -r }, { r* 2, r* 2 } }, r);
        snapshot.push_rounded_clip(rect);
        snapshot.append_color(color_to_rgba(0), { { -r, -r }, { r, r } });
        snapshot.append_color(color_to_rgba(1), { { -r, 0 }, { r, r } });
        snapshot.append_color(color_to_rgba(2), { { 0, 0 }, { r, r } });
        snapshot.append_color(color_to_rgba(3), { { 0, -r }, { r, r } });
        snapshot.pop();
        snapshot.append_inset_shadow(rect, { 0, 0, 0 }, 0, 0, 1, 0);
    }

    private Gdk.RGBA color_to_rgba(int index) {
        if (index < 0 || index >= colors.size) {
            warning("Color index %d is out of bounds. Using default color.", index);
            return { 0.5f, 0.5f, 0.5f, 1.0f }; // Default gray color
        }

        int rgb = colors.get(index);
        float r = ((rgb >> 16) & 0xFF) / 255.0f;
        float g = ((rgb >> 8) & 0xFF) / 255.0f;
        float b = (rgb & 0xFF) / 255.0f;

        return { r, g, b, 1.0f };
    }
}