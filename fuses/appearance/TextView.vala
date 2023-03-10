public class Appearance.TextView : Gtk.Box {
    private const string FONT_KEY = "font-name";
    private const string DOCUMENT_FONT_KEY = "document-font-name";
    private const string REG_FONT = "Manrope 10";
    private const string DOC_FONT = "Manrope 10";
    private const string OD_REG_FONT = "OpenDyslexic Regular 9";
    private const string OD_DOC_FONT = "OpenDyslexic Regular 10";
    private static GLib.Settings tau_appearance_settings;

    private uint scale_timeout;
    private uint fwscale_timeout;

    static construct {
        tau_appearance_settings = new GLib.Settings ("com.fyralabs.desktop.appearance");
    }

    construct {
        var size_label = new Gtk.Label (_("Size")) {
            halign = Gtk.Align.START
        };
        size_label.add_css_class ("cb-title");

        var size_adjustment = new Gtk.Adjustment (-1, 0.75, 1.5, 0.05, 0, 0);

        var size_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, size_adjustment) {
            draw_value = false,
            hexpand = true
        };
        size_scale.add_mark (1, Gtk.PositionType.TOP, null);
        size_scale.add_mark (1.25, Gtk.PositionType.TOP, null);

        var size_spinbutton = new Gtk.SpinButton (size_adjustment, 0.25, 2) {
            valign = Gtk.Align.CENTER
        };

        var size_control_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        size_control_box.append (size_scale);
        size_control_box.append (size_spinbutton);

        var size_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        size_box.append (size_label);
        size_box.append (size_control_box);
        size_box.add_css_class ("mini-content-block");

        var font_weight_label = new Gtk.Label (_("Weight")) {
            halign = Gtk.Align.START
        };
        font_weight_label.add_css_class ("cb-title");

        var font_weight_adjustment = new Gtk.Adjustment (-1, 0.75, 2.0, 0.0858, 0, 0);

        var font_weight_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, font_weight_adjustment) {
            draw_value = false,
            hexpand = true
        };
        font_weight_scale.add_mark (1.0, Gtk.PositionType.TOP, null);
        font_weight_scale.add_mark (1.5, Gtk.PositionType.TOP, null);
        font_weight_scale.add_mark (2.0, Gtk.PositionType.TOP, null);

        var font_weight_spinbutton = new Gtk.SpinButton (font_weight_adjustment, 0.25, 2) {
            valign = Gtk.Align.CENTER
        };

        var font_weight_control_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        font_weight_control_box.append (font_weight_scale);
        font_weight_control_box.append (font_weight_spinbutton);

        var font_weight_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        font_weight_box.append (font_weight_label);
        font_weight_box.append (font_weight_control_box);
        font_weight_box.add_css_class ("mini-content-block");

        var dyslexia_font_label = new Gtk.Label (_("Dyslexia-friendly")) {
            halign = Gtk.Align.START
        };
        dyslexia_font_label.add_css_class ("cb-title");

        var dyslexia_font_switch = new Gtk.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };

        var dyslexia_font_description_label = new Gtk.Label (
                                                             _("Bottom-heavy letters and improved spacing can help with legibility and readability.")
            ) {
            wrap = true,
            xalign = 0
        };
        dyslexia_font_description_label.add_css_class ("dim-label");

        var dyslexia_control_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        dyslexia_control_box.append (dyslexia_font_label);
        dyslexia_control_box.append (dyslexia_font_description_label);

        var dyslexia_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        dyslexia_box.append (dyslexia_control_box);
        dyslexia_box.append (dyslexia_font_switch);
        dyslexia_box.add_css_class ("mini-content-block");

        var grid = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        grid.append (size_box);
        grid.append (font_weight_box);
        grid.append (dyslexia_box);

        var clamp = new Bis.Latch ();
        clamp.set_child (grid);

        append (clamp);

        var interface_settings = new Settings ("org.gnome.desktop.interface");
        interface_settings.bind ("text-scaling-factor", size_adjustment, "value", SettingsBindFlags.GET);

        // Setting scale is slow, so we wait while pressed to keep UI responsive
        size_adjustment.value_changed.connect (() => {
            if (scale_timeout != 0) {
                GLib.Source.remove (scale_timeout);
            }

            scale_timeout = Timeout.add (300, () => {
                scale_timeout = 0;
                interface_settings.set_double ("text-scaling-factor", size_adjustment.value);
                return false;
            });
        });

        tau_appearance_settings.bind ("font-weight", font_weight_adjustment, "value", SettingsBindFlags.GET);

        // Setting scale is slow, so we wait while pressed to keep UI responsive
        font_weight_adjustment.value_changed.connect (() => {
            if (fwscale_timeout != 0) {
                GLib.Source.remove (fwscale_timeout);
            }

            fwscale_timeout = Timeout.add (300, () => {
                fwscale_timeout = 0;
                tau_appearance_settings.set_double ("font-weight", font_weight_adjustment.value);
                return false;
            });
        });

        var interface_font = interface_settings.get_string (FONT_KEY);
        var document_font = interface_settings.get_string (DOCUMENT_FONT_KEY);

        if (interface_font == OD_REG_FONT) {
            dyslexia_font_switch.active = true;
        } else {
            dyslexia_font_switch.active = false;
        }
        dyslexia_font_switch.notify["active"].connect (() => {
            if (dyslexia_font_switch.active) {
                interface_settings.set_string (FONT_KEY, OD_REG_FONT);
                interface_settings.set_string (DOCUMENT_FONT_KEY, OD_DOC_FONT);
            } else {
                interface_settings.set_string (FONT_KEY, REG_FONT);
                interface_settings.set_string (DOCUMENT_FONT_KEY, DOC_FONT);
            }
        });
    }
}