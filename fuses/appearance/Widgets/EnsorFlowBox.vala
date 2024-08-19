public class EnsorFlowBox : He.Bin {
    private int color;

    private static GLib.Settings tau_appearance_settings;

    public EnsorFlowBox (int color) {
        this.color = color;
    }

    static construct {
        tau_appearance_settings = new GLib.Settings ("com.fyralabs.desktop.appearance");
    }

    construct {
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

        var flowbox = new Gtk.FlowBox () {
            hexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            column_spacing = 12,
            homogeneous = true,
            min_children_per_line = 1,
            max_children_per_line = 4,
            margin_start = 6,
            margin_end = 6
        };
        flowbox.add_css_class ("ensor-box");
        flowbox.append (defavlt);
        flowbox.append (muted);
        flowbox.append (vibrant);
        flowbox.append (salad);
        flowbox.child_activated.connect ((flowboxchild) => {
            var ensor = ((EnsorModeButton)flowboxchild.get_first_child ()).mode;
            tau_appearance_settings.set_string ("ensor-scheme", ensor);
            tau_appearance_settings.set_string ("accent-color", He.hexcode_argb (color));
        });

        this.child = flowbox;
    }
}