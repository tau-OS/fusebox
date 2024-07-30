public class Sound.DeviceRow : Gtk.ListBoxRow {
    public signal void set_as_default ();

    public Device device { get; construct; }

    private Gtk.CheckButton activate_radio;
    private bool ignore_default = false;

    public DeviceRow (Device device) {
        Object (device: device);
    }

    construct {
        activate_radio = new Gtk.CheckButton ();

        var image = new Gtk.Image.from_icon_name (device.icon_name + "-symbolic") {
            tooltip_text = device.get_nice_form_factor (),
            use_fallback = true,
            pixel_size = 24
        };

        var name_label = new Gtk.Label (device.display_name) {
            xalign = 0
        };
        name_label.add_css_class ("cb-title");

        var description_label = new Gtk.Label (device.description) {
            xalign = 0
        };
        description_label.add_css_class ("cb-subtitle");

        var grid = new Gtk.Grid () {
            column_spacing = 12,
            orientation = Gtk.Orientation.HORIZONTAL
        };
        grid.attach (image, 1, 0, 1, 2);
        grid.attach (name_label, 2, 0);
        grid.attach (description_label, 2, 1);
        grid.attach (activate_radio, 3, 0, 1, 2);

        add_css_class ("mini-content-block");
        set_child (grid);

        activate.connect (() => {
            activate_radio.active = true;
        });

        activate_radio.toggled.connect (() => {
            if (activate_radio.active && !ignore_default) {
                set_as_default ();
            }
        });

        device.bind_property ("display-name", name_label, "label");
        device.bind_property ("description", description_label, "label");

        device.removed.connect (() => destroy ());
        device.notify["is-default"].connect (() => {
            ignore_default = true;
            activate_radio.active = device.is_default;
            ignore_default = false;
        });
    }

    public void link_to_row (DeviceRow row) {
        activate_radio.group = (row.activate_radio);
        activate_radio.active = device.is_default;
    }
}