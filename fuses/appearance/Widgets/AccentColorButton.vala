private class AccentColorButton : Gtk.CheckButton {
    public string color { get; construct; }

    private static GLib.Settings tau_appearance_settings;
    static construct {
        tau_appearance_settings = new GLib.Settings ("com.fyralabs.desktop.appearance");
    }

    public AccentColorButton (string color, Gtk.CheckButton? group_member = null) {
        Object (
                color : color,
                group: group_member
        );

        add_css_class (color.to_string ());
        add_css_class ("accent-mode");
    }

    construct {
        active = color == tau_appearance_settings.get_string ("accent-color");
        toggled.connect (() => {
            if (color == "purple") {
                tau_appearance_settings.set_string ("accent-color", "purple");
            } else if (color == "pink") {
                tau_appearance_settings.set_string ("accent-color", "pink");
            } else if (color == "red") {
                tau_appearance_settings.set_string ("accent-color", "red");
            } else if (color == "yellow") {
                tau_appearance_settings.set_string ("accent-color", "yellow");
            } else if (color == "green") {
                tau_appearance_settings.set_string ("accent-color", "green");
            } else if (color == "blue") {
                tau_appearance_settings.set_string ("accent-color", "blue");
            } else if (color == "multi") {
                tau_appearance_settings.set_string ("accent-color", "multi");
            }
        });
    }
}