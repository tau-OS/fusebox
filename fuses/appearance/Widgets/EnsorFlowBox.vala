public class EnsorFlowBox : He.Bin {
    private Gtk.FlowBox flowbox;
    public int current_selection;

    private static GLib.Settings tau_appearance_settings;
    private static GLib.Settings fusebox_appearance_settings;
    static construct {
        tau_appearance_settings = new GLib.Settings ("com.fyralabs.desktop.appearance");
        fusebox_appearance_settings = new GLib.Settings ("com.fyralabs.Fusebox");
    }

    public EnsorFlowBox (int[] color) {
        flowbox = new Gtk.FlowBox () {
            hexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            column_spacing = 12,
            homogeneous = true,
            min_children_per_line = 20,
            max_children_per_line = 20,
            margin_start = 6,
            margin_end = 6,
            margin_bottom = 18
        };
        flowbox.add_css_class ("ensor-box");
        flowbox.child_activated.connect (child_activated_cb);

        var sel = fusebox_appearance_settings.get_int ("wallpaper-accent-choice");
        flowbox.select_child (flowbox.get_child_at_index ((sel < 0 || sel > (color.length * 4)) ? 0 : sel));

        for (int i = 0; i < color.length; i++) {
            make_ensor_set (color[i]);
        }

        this.child = flowbox;
    }

    private void child_activated_cb (Gtk.FlowBoxChild child) {
        var ensor_mode = ((EnsorModeButton) child.get_first_child ()).mode;
        var ensor_color = ((EnsorModeButton) child.get_first_child ()).colors[0];
        tau_appearance_settings.set_string ("ensor-scheme", ensor_mode);
        tau_appearance_settings.set_string ("accent-color", He.hexcode_argb (ensor_color));

        current_selection = flowbox.get_selected_children ().nth_data (0).get_index ();
        fusebox_appearance_settings.set_int ("wallpaper-accent-choice", current_selection);
    }

    private void make_ensor_set (int color) {
        var defavlt = new Gtk.FlowBoxChild ();
        defavlt.child = new EnsorModeButton (color, "default");
        defavlt.tooltip_text = _("Default Scheme");
        var muted = new Gtk.FlowBoxChild ();
        muted.child = new EnsorModeButton (color, "muted");
        muted.tooltip_text = _("Muted Scheme");
        var vibrant = new Gtk.FlowBoxChild ();
        vibrant.child = new EnsorModeButton (color, "vibrant");
        vibrant.tooltip_text = _("Vibrant Scheme");
        var salad = new Gtk.FlowBoxChild ();
        salad.child = new EnsorModeButton (color, "salad");
        salad.tooltip_text = _("Fruit Salad Scheme");

        flowbox.append (defavlt);
        flowbox.append (muted);
        flowbox.append (vibrant);
        flowbox.append (salad);
    }
}