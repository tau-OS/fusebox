public class EnsorModeButton : Gtk.Box {
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
        this.mode = initial_mode;
        generator = new ColorGenerator({ color });
        set_colors(generator.get_generated_colors(get_scheme_variant(mode)));

        overflow = HIDDEN;
        add_css_class("circle-radius");
    }

    private void update_colors() {
        if (!is_valid_mode(mode)) {
            debug("Invalid mode '%s'. Using default colors.", mode);
            mode = "default";
        }

        set_colors(generator.get_generated_colors(get_scheme_variant(mode)));
        queue_draw();
    }

    public void set_colors(Gee.ArrayList<int> colors) {
        if (colors != null) {
            if (colors.size == 0) {
                debug("EnsorModeButton requires colors, using default");
                this.colors = new Gee.ArrayList<int> ();
                this.colors.add(0x8C56BF); // Default color
                this.colors.add(0x8C56BF);
                this.colors.add(0x8C56BF);
                this.colors.add(0x8C56BF);
            } else {
                this.colors = colors;
            }
            queue_draw();
        } else {
            debug("EnsorModeButton requires colors, using default");
            this.colors = new Gee.ArrayList<int> ();
            this.colors.add(0x8C56BF); // Default color
            this.colors.add(0x8C56BF);
            this.colors.add(0x8C56BF);
            this.colors.add(0x8C56BF);
            queue_draw();
        }
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

        if (w <= 0 || h <= 0) {
            return; // Don't draw if widget has no size
        }

        float r = float.min(w, h) / 2.0f;

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
        if (colors == null || index >= colors.size) {
            // Return default color if index is out of bounds
            return { 0.549f, 0.337f, 0.749f, 1.0f }; // Default purple
        }

        int rgb = colors.get(index);
        float r = ((rgb >> 16) & 0xFF) / 255.0f;
        float g = ((rgb >> 8) & 0xFF) / 255.0f;
        float b = (rgb & 0xFF) / 255.0f;

        return { r, g, b, 1.0f };
    }
}
