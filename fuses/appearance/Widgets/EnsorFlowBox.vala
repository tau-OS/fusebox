public class EnsorFlowBox : He.Bin {
    public Gtk.FlowBox flowbox;
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
            min_children_per_line = color.length * 4,
            max_children_per_line = color.length * 4,
            margin_start = 6,
            margin_end = 6,
            margin_bottom = 18
        };
        flowbox.add_css_class ("ensor-box");
        flowbox.child_activated.connect (child_activated_cb);

        for (int i = 0; i < color.length; i++) {
            make_ensor_set (color[i]);
        }

        this.child = flowbox;
    }

    construct {
        var sel = fusebox_appearance_settings.get_int ("wallpaper-accent-choice");
        if (sel >= 0 && sel < flowbox.get_max_children_per_line ()) {
            flowbox.select_child (flowbox.get_child_at_index (sel));
        } else {
            warning ("Saved selection index %d is out of bounds", sel);
        }
    }

    private void child_activated_cb (Gtk.FlowBoxChild child) {
        var first_child = child.get_first_child ();
        if (first_child is EnsorModeButton) {
            var ensor_mode = ((EnsorModeButton) first_child).mode;
            var ensor_color = ((EnsorModeButton) first_child).colors[0];
            tau_appearance_settings.set_string ("ensor-scheme", ensor_mode);
            tau_appearance_settings.set_string ("accent-color", He.hexcode_argb (ensor_color));

            var selected_children = flowbox.get_selected_children ();
            if (selected_children.length () > 0) {
                current_selection = selected_children.nth_data (0).get_index ();
                fusebox_appearance_settings.set_int ("wallpaper-accent-choice", current_selection);
            } else {
                warning ("No child is selected in the flowbox");
            }
        } else {
            warning ("Activated child does not contain an EnsorModeButton");
        }
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