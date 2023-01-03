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
    private Gtk.ToggleButton prefer_light_radio;
    private Gtk.ToggleButton prefer_default_radio;
    private Gtk.ToggleButton prefer_dark_radio;
    private Gtk.ToggleButton prefer_soft_radio;
    private Gtk.ToggleButton prefer_medium_radio;
    private Gtk.ToggleButton prefer_harsh_radio;

    public Fusebox.Fuse fuse { get; construct set; }

    private enum ColorScheme {
        NO_PREFERENCE,
        PREFER_DARK,
        PREFER_LIGHT;

        public int to_int () {
            switch (this) {
                case NO_PREFERENCE:
                    return 0;
                case PREFER_DARK:
                    return 1;
                case PREFER_LIGHT:
                    return 2;
            }

            return 0;
        }
    }

    private enum DarkModeStrength {
        MEDIUM,
        HARSH,
        SOFT;

        public int to_int () {
            switch (this) {
                case MEDIUM:
                    return 0;
                case HARSH:
                    return 1;
                case SOFT:
                    return 2;
            }

            return 0;
        }
    }

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

    public AppearanceView (Fusebox.Fuse _fuse) {
        Object (fuse: _fuse);
    }

    static construct {
        tau_appearance_settings = new GLib.Settings ("co.tauos.desktop.appearance");
        interface_settings = new GLib.Settings ("org.gnome.desktop.interface");
        theme_settings = new GLib.Settings ("org.gnome.shell.extensions.user-theme");
    }

    construct {
        var main_label = new Gtk.Label (_("Appearance")) {
            halign = Gtk.Align.START,
            margin_bottom = 6
        };
        main_label.add_css_class ("view-title");

        var prefer_label = new Gtk.Label (_("Color Scheme")) {
            halign = Gtk.Align.START
        };
        prefer_label.add_css_class ("cb-title");

        var prefer_default_image = new Gtk.Image.from_icon_name ("dark-mode-symbolic") {
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
        prefer_default_grid.attach (new Gtk.Label (_("Auto")), 0, 1);

        prefer_default_radio = new Gtk.ToggleButton () {
            hexpand = true,
            tooltip_text = _("Apps will choose their own color scheme.")
        };
        prefer_default_radio.add_css_class ("image-button");
        prefer_default_radio.child = (prefer_default_grid);

        var prefer_light_image = new Gtk.Image.from_icon_name ("weather-clear-symbolic") {
            pixel_size = 32
        };

        var prefer_light_card = new Gtk.Grid () {
            margin_top = 6,
            margin_bottom = 6,
            margin_end = 6,
            margin_start = 6
        };
        prefer_light_card.attach (prefer_light_image, 0, 0);

        var prefer_light_grid = new Gtk.Grid () {
            row_spacing = 6
        };
        prefer_light_grid.attach (prefer_light_card, 0, 0);
        prefer_light_grid.attach (new Gtk.Label (_("Light")), 0, 1);

        prefer_light_radio = new Gtk.ToggleButton () {
            group = prefer_default_radio,
            tooltip_text = _("Apps will all be light-colored."),
            hexpand = true
        };
        prefer_light_radio.add_css_class ("image-button");
        prefer_light_radio.child = (prefer_light_grid);

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

        prefer_dark_radio = new Gtk.ToggleButton () {
            group = prefer_default_radio,
            tooltip_text = _("Apps will all be dark-colored."),
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
        prefer_style_box.append (prefer_light_radio);
        prefer_style_box.append (prefer_dark_radio);

        var prefer_dm_sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            visible = false
        };

        var prefer_dm_label = new Gtk.Label (_("Dark Mode Strength")) {
            halign = Gtk.Align.START,
            visible = false
        };
        prefer_dm_label.add_css_class ("cb-title");

        var prefer_soft_image = new Gtk.Image.from_resource ("/co/tauos/Fusebox/Appearance/soft.svg") {
            pixel_size = 96
        };

        var prefer_soft_card = new Gtk.Grid () {
            margin_top = 6,
            margin_bottom = 6,
            margin_end = 6,
            margin_start = 6
        };
        prefer_soft_card.attach (prefer_soft_image, 0, 0);

        var prefer_soft_grid = new Gtk.Grid () {
            row_spacing = 6,
            hexpand = true,
            halign = Gtk.Align.CENTER
        };
        prefer_soft_grid.attach (prefer_soft_card, 0, 0);
        prefer_soft_grid.attach (new Gtk.Label (_("Soft")), 0, 1);

        prefer_soft_radio = new Gtk.ToggleButton () {
            hexpand = true,
            tooltip_text = _("The intensity of the dark mode will be softer.")
        };
        prefer_soft_radio.add_css_class ("image-button");
        prefer_soft_radio.child = (prefer_soft_grid);

        var prefer_medium_image = new Gtk.Image.from_resource ("/co/tauos/Fusebox/Appearance/medium.svg") {
            pixel_size = 96
        };

        var prefer_medium_card = new Gtk.Grid () {
            margin_top = 6,
            margin_bottom = 6,
            margin_end = 6,
            margin_start = 6
        };
        prefer_medium_card.attach (prefer_medium_image, 0, 0);

        var prefer_medium_grid = new Gtk.Grid () {
            row_spacing = 6,
            hexpand = true,
            halign = Gtk.Align.CENTER
        };
        prefer_medium_grid.attach (prefer_medium_card, 0, 0);
        prefer_medium_grid.attach (new Gtk.Label (_("Medium")), 0, 1);

        prefer_medium_radio = new Gtk.ToggleButton () {
            group = prefer_soft_radio,
            tooltip_text = _("The intensity of the dark mode will be the default."),
            hexpand = true
        };
        prefer_medium_radio.add_css_class ("image-button");
        prefer_medium_radio.child = (prefer_medium_grid);

        var prefer_harsh_image = new Gtk.Image.from_resource ("/co/tauos/Fusebox/Appearance/harsh.svg") {
            pixel_size = 96
        };

        var prefer_harsh_card = new Gtk.Grid () {
            margin_top = 6,
            margin_bottom = 6,
            margin_end = 6,
            margin_start = 6
        };
        prefer_harsh_card.attach (prefer_harsh_image, 0, 0);

        var prefer_harsh_grid = new Gtk.Grid () {
            row_spacing = 6,
            hexpand = true,
            halign = Gtk.Align.CENTER
        };
        prefer_harsh_grid.attach (prefer_harsh_card, 0, 0);
        prefer_harsh_grid.attach (new Gtk.Label (_("Harsh")), 0, 1);

        prefer_harsh_radio = new Gtk.ToggleButton () {
            group = prefer_soft_radio,
            tooltip_text = _("The intensity of the dark mode will be harsher."),
            hexpand = true
        };
        prefer_harsh_radio.add_css_class ("image-button");
        prefer_harsh_radio.child = (prefer_harsh_grid);

        var prefer_dm_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            spacing = 12,
            hexpand = true,
            homogeneous = true,
            visible = false
        };
        prefer_dm_box.append (prefer_soft_radio);
        prefer_dm_box.append (prefer_medium_radio);
        prefer_dm_box.append (prefer_harsh_radio);

        var prefer_main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            spacing = 12,
            hexpand = true
        };
        prefer_main_box.add_css_class ("mini-content-block");
        prefer_main_box.append (prefer_label);
        prefer_main_box.append (prefer_style_box);
        prefer_main_box.append (prefer_dm_sep);
        prefer_main_box.append (prefer_dm_label);
        prefer_main_box.append (prefer_dm_box);

        var grid = new Gtk.Grid () {
            row_spacing = 6,
            margin_start = 18,
            margin_end = 18,
            margin_bottom = 18
        };

        grid.attach (main_label, 0, 0);
        grid.attach (prefer_main_box, 0, 1);

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
            row_homogeneous = true,
            margin_bottom = 6
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

        var wallpaper_view = new Appearance.WallpaperGrid (fuse);
        grid.attach (wallpaper_view, 0, 3);
        wallpaper_view.update_wallpaper_folder.begin ();

        var clamp = new Bis.Latch ();
        clamp.set_child (grid);

        append (clamp);
  
        accent_refresh ();
        tau_appearance_settings.notify["changed::accent-color"].connect (() => {
            accent_refresh ();
        });

        prefer_default_radio.toggled.connect (() => {
            set_color_scheme (ColorScheme.NO_PREFERENCE);
            prefer_dm_sep.visible = false;
            prefer_dm_label.visible = false;
            prefer_dm_box.visible = false;
        });
        prefer_light_radio.toggled.connect (() => {
            set_color_scheme (ColorScheme.PREFER_LIGHT);
            prefer_dm_sep.visible = false;
            prefer_dm_label.visible = false;
            prefer_dm_box.visible = false;
        });
        prefer_dark_radio.toggled.connect (() => {
            set_color_scheme (ColorScheme.PREFER_DARK);
            prefer_dm_sep.visible = true;
            prefer_dm_label.visible = true;
            prefer_dm_box.visible = true;
        });

        color_scheme_refresh ();
        interface_settings.notify["changed::color-scheme"].connect (() => {
            color_scheme_refresh ();
        });

        prefer_soft_radio.toggled.connect (() => {
            set_dark_mode_strength (DarkModeStrength.SOFT);
        });
        prefer_medium_radio.toggled.connect (() => {
            set_dark_mode_strength (DarkModeStrength.MEDIUM);
        });
        prefer_harsh_radio.toggled.connect (() => {
            set_dark_mode_strength (DarkModeStrength.HARSH);
        });

        dark_mode_strength_refresh ();
        tau_appearance_settings.notify["changed::dark-mode-strength"].connect (() => {
            dark_mode_strength_refresh ();
        });
    }

    private void set_color_scheme (ColorScheme color_scheme) {
        if (color_scheme == ColorScheme.NO_PREFERENCE) {
            interface_settings.set_string ("gtk-theme", "Adwaita");
            theme_settings.set_string ("name", "Helium");
        } else if (color_scheme == ColorScheme.PREFER_LIGHT) {
            interface_settings.set_string ("gtk-theme", "Adwaita");
            theme_settings.set_string ("name", "Helium");
        } else if (color_scheme == ColorScheme.PREFER_DARK) {
            interface_settings.set_string ("gtk-theme", "Adwaita-dark");
            theme_settings.set_string ("name", "Helium-dark");
        }

        interface_settings.set_enum ("color-scheme", color_scheme.to_int ());
    }

    private void color_scheme_refresh () {
        int value = interface_settings.get_enum ("color-scheme");

        if (value == ColorScheme.NO_PREFERENCE) {
            prefer_default_radio.set_active (true);
            prefer_light_radio.set_active (false);
            prefer_dark_radio.set_active (false);
        } else if (value == ColorScheme.PREFER_LIGHT) {
            prefer_default_radio.set_active (false);
            prefer_light_radio.set_active (true);
            prefer_dark_radio.set_active (false);
        } else if (value == ColorScheme.PREFER_DARK) {
            prefer_default_radio.set_active (false);
            prefer_light_radio.set_active (false);
            prefer_dark_radio.set_active (true);
        }
    }

    private void set_dark_mode_strength (DarkModeStrength strength) {
        tau_appearance_settings.set_enum ("dark-mode-strength", strength.to_int ());
    }

    private void dark_mode_strength_refresh () {
        int value = tau_appearance_settings.get_enum ("dark-mode-strength");

        if (value == DarkModeStrength.SOFT) {
            prefer_soft_radio.set_active (true);
            prefer_medium_radio.set_active (false);
            prefer_harsh_radio.set_active (false);
        } else if (value == DarkModeStrength.MEDIUM) {
            prefer_soft_radio.set_active (false);
            prefer_medium_radio.set_active (true);
            prefer_harsh_radio.set_active (false);
        } else if (value == DarkModeStrength.HARSH) {
            prefer_soft_radio.set_active (false);
            prefer_medium_radio.set_active (false);
            prefer_harsh_radio.set_active (true);
        }
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
