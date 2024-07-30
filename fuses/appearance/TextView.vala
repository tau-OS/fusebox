public class Appearance.TextView : Gtk.Box {
    private const string FONT_KEY = "font-name";
    private const string DOCUMENT_FONT_KEY = "document-font-name";
    private const string REG_FONT = "Geist Regular 11";
    private const string DOC_FONT = "Geist Regular 11";
    private const string OD_REG_FONT = "OpenDyslexic Regular 10";
    private const string OD_DOC_FONT = "OpenDyslexic Regular 10";
    private static GLib.Settings tau_appearance_settings;

    private uint scale_timeout;
    private uint fwscale_timeout;

    static construct {
        tau_appearance_settings = new GLib.Settings ("com.fyralabs.desktop.appearance");
    }

    construct {
        var preview_text_block = new Gtk.Label ("");
        preview_text_block.wrap_mode = Pango.WrapMode.WORD_CHAR;
        preview_text_block.valign = Gtk.Align.START;
        preview_text_block.add_css_class ("text-block");
        preview_text_block.add_css_class ("surface-container-lowest-bg-color");
        preview_text_block.add_css_class ("large-radius");
        preview_text_block.label = (_(
"""Whereas disregard and contempt for human rights have resulted in
barbarous acts which have outraged the conscience of mankind, and
the advent of a world in which human beings shall enjoy freedom of
speech and belief and freedom from fear and want has been
proclaimed as the highest aspiration of the common people…"""));

        var size_label = new Gtk.Label (_("Size")) {
            halign = Gtk.Align.START
        };
        size_label.add_css_class ("cb-title");

        var size_adjustment = new Gtk.Adjustment (-1, 0.75, 2.0, 0.1, 0, 0);

        var size_scale = new He.Slider () {
            hexpand = true
        };
        size_scale.scale.orientation = Gtk.Orientation.HORIZONTAL;
        size_scale.scale.adjustment = size_adjustment;
        size_scale.scale.draw_value = true;
        size_scale.scale.value_pos = Gtk.PositionType.LEFT;
        size_scale.stop_indicator_visibility = true;
        size_scale.add_mark (1, null);

        var size_control_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        size_control_box.append (size_scale);

        var size_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        size_box.append (size_label);
        size_box.append (size_control_box);
        size_box.add_css_class ("mini-content-block");

        var font_weight_label = new Gtk.Label (_("Weight")) {
            halign = Gtk.Align.START
        };
        font_weight_label.add_css_class ("cb-title");

        var font_weight_adjustment = new Gtk.Adjustment (-1, 0.75, 2.0, 0.0858, 0, 0);

        var font_weight_scale = new He.Slider () {
            hexpand = true
        };
        font_weight_scale.scale.orientation = Gtk.Orientation.HORIZONTAL;
        font_weight_scale.scale.adjustment = font_weight_adjustment;
        font_weight_scale.scale.draw_value = true;
        font_weight_scale.scale.value_pos = Gtk.PositionType.LEFT;
        font_weight_scale.stop_indicator_visibility = true;
        font_weight_scale.add_mark (1.0, null);

        var font_weight_control_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        font_weight_control_box.append (font_weight_scale);

        var font_weight_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        font_weight_box.append (font_weight_label);
        font_weight_box.append (font_weight_control_box);
        font_weight_box.add_css_class ("mini-content-block");

        var dyslexia_font_label = new Gtk.Label (_("Dyslexia-friendly")) {
            halign = Gtk.Align.START
        };
        dyslexia_font_label.add_css_class ("cb-title");

        var dyslexia_font_switch = new He.Switch () {
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
        grid.append (preview_text_block);
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
            dyslexia_font_switch.iswitch.active = true;
        } else {
            dyslexia_font_switch.iswitch.active = false;
        }
        dyslexia_font_switch.iswitch.notify["active"].connect (() => {
            if (dyslexia_font_switch.iswitch.active) {
                interface_settings.set_string (FONT_KEY, OD_REG_FONT);
                interface_settings.set_string (DOCUMENT_FONT_KEY, OD_DOC_FONT);
            } else {
                interface_settings.set_string (FONT_KEY, REG_FONT);
                interface_settings.set_string (DOCUMENT_FONT_KEY, DOC_FONT);
            }
        });
    }
}