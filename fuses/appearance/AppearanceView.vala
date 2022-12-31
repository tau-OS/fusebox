public class AppearanceView : Gtk.Box {
    private static GLib.Settings interface_settings;
    private static GLib.Settings theme_settings;
    private static GLib.Settings tau_appearance_settings;
    private PrefersAccentColorButton red;
    private PrefersAccentColorButton orange;
    private PrefersAccentColorButton yellow;
    private PrefersAccentColorButton green;
    private PrefersAccentColorButton mint;
    private PrefersAccentColorButton blue;
    private PrefersAccentColorButton purple;
    private PrefersAccentColorButton pink;
    private PrefersAccentColorButton mono;
    private PrefersAccentColorButton multi;

    private enum AccentColor {
        MULTI,
        RED,
        ORANGE,
        YELLOW,
        GREEN,
        MINT,
        BLUE,
        PURPLE,
        PINK,
        MONO;

        public string to_string () {
            switch (this) {
                case RED:
                    return "meson-red";
                case ORANGE:
                    return "lepton-orange";
                case YELLOW:
                    return "electron-yellow";
                case GREEN:
                    return "muon-green";
                case BLUE:
                    return "proton-blue";
                case PURPLE:
                    return "tau-purple";
                case PINK:
                    return "fermion-pink";
                case MINT:
                    return "baryon-mint";
                case MONO:
                    return "graviton-dark";
                case MULTI:
                    return "multi-color";
            }

            return "multi";
        }

        public int to_int () {
            switch (this) {
                case RED:
                    return 3;
                case ORANGE:
                    return 4;
                case YELLOW:
                    return 5;
                case GREEN:
                    return 6;
                case BLUE:
                    return 8;
                case PURPLE:
                    return 1;
                case PINK:
                    return 2;
                case MINT:
                    return 7;
                case MONO:
                    return 9;
                case MULTI:
                    return 0;
            }

            return 0;
        }
    }

    static construct {
        tau_appearance_settings = new GLib.Settings ("co.tauos.desktop.appearance");
        interface_settings = new GLib.Settings ("org.gnome.desktop.interface");
        theme_settings = new GLib.Settings ("org.gnome.shell.extensions.user-theme");
    }

    construct {
        var main_label = new Gtk.Label (_("Appearance")) {
            halign = Gtk.Align.START
        };
        main_label.add_css_class ("view-title");

        var prefer_default_image = new Gtk.Image.from_icon_name ("weather-clear-symbolic") {
            pixel_size = 32
        };

        var prefer_default_card = new Gtk.Grid () {
            margin_top = 6,
            margin_bottom = 6,
            margin_end = 6,
            margin_start = 6
        };
        prefer_default_card.attach (prefer_default_image, 0, 0);

        var prefer_default_grid = new Gtk.Grid () {
            row_spacing = 6
        };
        prefer_default_grid.attach (prefer_default_card, 0, 0);
        prefer_default_grid.attach (new Gtk.Label (_("Default")), 0, 1);

        var prefer_default_radio = new Gtk.ToggleButton ();
        prefer_default_radio.add_css_class ("image-button");
        prefer_default_radio.child = (prefer_default_grid);

        var prefer_dark_image = new Gtk.Image.from_icon_name ("weather-clear-night-symbolic") {
            pixel_size = 32
        };

        var prefer_dark_card = new Gtk.Grid () {
            margin_top = 6,
            margin_bottom = 6,
            margin_end = 6,
            margin_start = 6
        };
        prefer_dark_card.attach (prefer_dark_image, 0, 0);

        var prefer_dark_grid = new Gtk.Grid () {
            row_spacing = 6
        };
        prefer_dark_grid.attach (prefer_dark_card, 0, 0);
        prefer_dark_grid.attach (new Gtk.Label (_("Dark")), 0, 1);

        var prefer_dark_radio = new Gtk.ToggleButton () {
            group = prefer_default_radio,
            hexpand = true
        };
        prefer_dark_radio.add_css_class ("image-button");
        prefer_dark_radio.child = (prefer_dark_grid);

        var prefer_style_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            spacing = 12,
            hexpand = true,
            homogeneous = true
        };
        prefer_style_box.append (prefer_default_radio);
        prefer_style_box.append (prefer_dark_radio);

        var prefer_label = new Gtk.Label (_("Color Scheme")) {
            halign = Gtk.Align.START
        };
        prefer_label.add_css_class ("cb-title");

        var prefer_main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            spacing = 12,
            hexpand = true
        };
        prefer_main_box.add_css_class ("mini-content-block");
        prefer_main_box.append (prefer_label);
        prefer_main_box.append (prefer_style_box);

        var grid = new Gtk.Grid () {
            column_spacing = 6,
            row_spacing = 12,
            margin_start = 18,
            margin_end = 18,
            margin_bottom = 18
        };

        grid.attach (main_label, 0, 0);
        grid.attach (prefer_main_box, 0, 1);

        prefer_default_radio.toggled.connect (() => {
            set_color_scheme (He.Desktop.ColorScheme.NO_PREFERENCE);
            interface_settings.set_string ("gtk-theme", "Adwaita");
            theme_settings.set_string ("name", "Helium");
        });

        prefer_dark_radio.toggled.connect (() => {
            set_color_scheme (He.Desktop.ColorScheme.DARK);
            interface_settings.set_string ("gtk-theme", "Adwaita-dark");
            theme_settings.set_string ("name", "Helium-dark");
        });

        var accent_label = new Gtk.Label (_("Accent Color")) {
            halign = Gtk.Align.START
        };
        accent_label.add_css_class ("cb-title");

        blue = new PrefersAccentColorButton (AccentColor.BLUE);
        blue.tooltip_text = _("Blue");

        mint = new PrefersAccentColorButton (AccentColor.MINT, blue);
        mint.tooltip_text = _("Mint");

        green = new PrefersAccentColorButton (AccentColor.GREEN, blue);
        green.tooltip_text = _("Green");

        yellow = new PrefersAccentColorButton (AccentColor.YELLOW, blue);
        yellow.tooltip_text = _("Yellow");

        orange = new PrefersAccentColorButton (AccentColor.ORANGE, blue);
        orange.tooltip_text = _("Orange");

        red = new PrefersAccentColorButton (AccentColor.RED, blue);
        red.tooltip_text = _("Red");

        pink = new PrefersAccentColorButton (AccentColor.PINK, blue);
        pink.tooltip_text = _("Pink");

        purple = new PrefersAccentColorButton (AccentColor.PURPLE, blue);
        purple.tooltip_text = _("Purple");

        mono = new PrefersAccentColorButton (AccentColor.MONO, blue);
        mono.tooltip_text = _("Mono");

        multi = new PrefersAccentColorButton (AccentColor.MULTI, blue);
        multi.tooltip_text = _("Automatic");

        var accent_grid = new Gtk.Grid () {
            row_spacing = 12,
            column_spacing = 12,
            hexpand = true,
            row_homogeneous = true
        };
        accent_grid.column_spacing = 6;
        accent_grid.attach (accent_label, 0, 0, 9);
        accent_grid.attach (red, 0, 1);
        accent_grid.attach (orange, 1, 1);
        accent_grid.attach (yellow, 2, 1);
        accent_grid.attach (green, 3, 1);
        accent_grid.attach (mint, 4, 1);
        accent_grid.attach (blue, 5, 1);
        accent_grid.attach (purple, 6, 1);
        accent_grid.attach (pink, 7, 1);
        accent_grid.attach (mono, 8, 1);
        accent_grid.attach (multi, 9, 1);
        accent_grid.add_css_class ("mini-content-block");

        grid.attach (accent_grid, 0, 2);

        var clamp = new Bis.Latch ();
        clamp.set_child (grid);

        append (clamp);
  
        accent_refresh ();

        tau_appearance_settings.notify["changed::accent-color"].connect (() => {
            accent_refresh ();
        });
    }

    private void set_color_scheme (He.Desktop.ColorScheme color_scheme) {
        var scheme = interface_settings.get_enum ("color-scheme");

        if (color_scheme == scheme)
            return;

        interface_settings.set_enum ("color-scheme", color_scheme);
    }

    private void accent_refresh () {
        int value = tau_appearance_settings.get_enum ("accent-color");

        if (value == AccentColor.RED) {
            red.set_active (true);
            orange.set_active (false);
            yellow.set_active (false);
            green.set_active (false);
            mint.set_active (false);
            blue.set_active (false);
            purple.set_active (false);
            pink.set_active (false);
            mono.set_active (false);
            multi.set_active (false);
        } else if (value == AccentColor.ORANGE) {
            red.set_active (false);
            orange.set_active (true);
            yellow.set_active (false);
            green.set_active (false);
            mint.set_active (false);
            blue.set_active (false);
            purple.set_active (false);
            pink.set_active (false);
            mono.set_active (false);
            multi.set_active (false);
        } else if (value == AccentColor.YELLOW) {
            red.set_active (false);
            orange.set_active (false);
            yellow.set_active (true);
            green.set_active (false);
            mint.set_active (false);
            blue.set_active (false);
            purple.set_active (false);
            pink.set_active (false);
            mono.set_active (false);
            multi.set_active (false);
        } else if (value == AccentColor.GREEN) {
            red.set_active (false);
            orange.set_active (false);
            yellow.set_active (false);
            green.set_active (true);
            mint.set_active (false);
            blue.set_active (false);
            purple.set_active (false);
            pink.set_active (false);
            mono.set_active (false);
            multi.set_active (false);
        } else if (value == AccentColor.MINT) {
            red.set_active (false);
            orange.set_active (false);
            yellow.set_active (false);
            green.set_active (false);
            mint.set_active (true);
            blue.set_active (false);
            purple.set_active (false);
            pink.set_active (false);
            mono.set_active (false);
            multi.set_active (false);
        } else if (value == AccentColor.BLUE) {
            red.set_active (false);
            orange.set_active (false);
            yellow.set_active (false);
            green.set_active (false);
            mint.set_active (false);
            blue.set_active (true);
            purple.set_active (false);
            pink.set_active (false);
            mono.set_active (false);
            multi.set_active (false);
        } else if (value == AccentColor.PURPLE) {
            red.set_active (false);
            orange.set_active (false);
            yellow.set_active (false);
            green.set_active (false);
            mint.set_active (false);
            blue.set_active (false);
            purple.set_active (true);
            pink.set_active (false);
            mono.set_active (false);
            multi.set_active (false);
        } else if (value == AccentColor.PINK) {
            red.set_active (false);
            orange.set_active (false);
            yellow.set_active (false);
            green.set_active (false);
            mint.set_active (false);
            blue.set_active (false);
            purple.set_active (false);
            pink.set_active (true);
            mono.set_active (false);
            multi.set_active (false);
        } else if (value == AccentColor.MONO) {
            red.set_active (false);
            orange.set_active (false);
            yellow.set_active (false);
            green.set_active (false);
            mint.set_active (false);
            blue.set_active (false);
            purple.set_active (false);
            pink.set_active (false);
            mono.set_active (true);
            multi.set_active (false);
        } else if (value == AccentColor.MULTI) {
            red.set_active (false);
            orange.set_active (false);
            yellow.set_active (false);
            green.set_active (false);
            mint.set_active (false);
            blue.set_active (false);
            purple.set_active (false);
            pink.set_active (false);
            mono.set_active (false);
            multi.set_active (true);
        } else {
            red.set_active (false);
            orange.set_active (false);
            yellow.set_active (false);
            green.set_active (false);
            mint.set_active (false);
            blue.set_active (false);
            purple.set_active (true);
            pink.set_active (false);
            mono.set_active (false);
            multi.set_active (false);
        }
    }

    private class PrefersAccentColorButton : Gtk.CheckButton {
        public AccentColor color { get; construct; }

        public PrefersAccentColorButton (AccentColor color, Gtk.CheckButton? group_member = null) {
            Object (
                color: color,
                group: group_member
            );
        }

        construct {
            add_css_class (color.to_string ());
            add_css_class ("selection-mode");

            realize.connect (() => {
                toggled.connect (() => {
                    tau_appearance_settings.set_enum ("accent-color", color.to_int ());
                });
            });
        }
    }
}