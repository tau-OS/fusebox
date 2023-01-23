public class AppearanceView : Gtk.Box {
    private static GLib.Settings interface_settings;
    private static GLib.Settings tau_appearance_settings;
    private static GLib.Settings fusebox_appearance_settings;
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
    private Gtk.Box accent_box;
    private Gtk.Switch wallpaper_accent_switch;
    private He.Desktop desktop = new He.Desktop ();

    public Fusebox.Fuse fuse { get; construct set; }
    public Appearance.WallpaperGrid wallpaper_view;
    private Appearance.Utils.Palette palette;

    private enum AccentColor {
        MULTI = 0,
        PURPLE = 1,
        PINK = 2,
        RED = 3,
        ORANGE = 4,
        YELLOW = 5,
        GREEN = 6,
        MINT = 7,
        BLUE = 8,
        MONO = 9;

        public string to_string () {
            switch (this) {
                case PURPLE:
                    return "tau-purple";
                case PINK:
                    return "fermion-pink";
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
                case MINT:
                    return "baryon-mint";
                case MONO:
                    return "graviton-dark";
                case MULTI:
                    return "multi-color";
            }

            return "multi";
        }
    }

    public AppearanceView (Fusebox.Fuse _fuse) {
        Object (fuse: _fuse);
    }

    static construct {
        tau_appearance_settings = new GLib.Settings ("co.tauos.desktop.appearance");
        fusebox_appearance_settings = new GLib.Settings ("co.tauos.Fusebox");
        interface_settings = new GLib.Settings ("org.gnome.desktop.interface");
    }

    construct {
        var prefer_label = new Gtk.Label (_("Color Scheme")) {
            halign = Gtk.Align.START
        };
        prefer_label.add_css_class ("cb-title");

        var prefer_default_image = new Gtk.Image.from_resource ("/co/tauos/Fusebox/Appearance/by-apps.svg") {
            pixel_size = 96
        };

        var prefer_default_card = new Gtk.Grid () {
            margin_top = 6,
            margin_bottom = 6,
            margin_end = 6,
            margin_start = 6
        };
        prefer_default_card.attach (prefer_default_image, 0, 0);

        var prefer_default_grid = new Gtk.Grid () {
            row_spacing = 6,
            halign = Gtk.Align.CENTER
        };
        prefer_default_grid.attach (prefer_default_card, 0, 0);
        prefer_default_grid.attach (new Gtk.Label (_("Set By Apps")), 0, 1);

        prefer_default_radio = new Gtk.ToggleButton () {
            hexpand = true,
            tooltip_text = _("Apps will choose their own color scheme.")
        };
        prefer_default_radio.add_css_class ("image-button");
        prefer_default_radio.child = (prefer_default_grid);

        var prefer_light_image = new Gtk.Image.from_resource ("/co/tauos/Fusebox/Appearance/light.svg") {
            pixel_size = 96
        };

        var prefer_light_card = new Gtk.Grid () {
            margin_top = 6,
            margin_bottom = 6,
            margin_end = 6,
            margin_start = 6,
        };
        prefer_light_card.attach (prefer_light_image, 0, 0);

        var prefer_light_grid = new Gtk.Grid () {
            row_spacing = 6,
            halign = Gtk.Align.CENTER
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

        var dark_image = new Gtk.Image.from_resource ("/co/tauos/Fusebox/Appearance/dark.svg") {
            pixel_size = 96
        };

        var dark_card = new Gtk.Grid () {
            margin_top = 6,
            margin_bottom = 6,
            margin_end = 6,
            margin_start = 6,
        };
        dark_card.attach (dark_image, 0, 0);

        var dark_grid = new Gtk.Grid () {
            row_spacing = 6,
            halign = Gtk.Align.CENTER
        };
        dark_grid.attach (dark_card, 0, 0);
        dark_grid.attach (new Gtk.Label (_("Dark")), 0, 1);

        prefer_dark_radio = new Gtk.ToggleButton () {
            group = prefer_default_radio,
            tooltip_text = _("Apps will all be dark-colored."),
            hexpand = true
        };
        prefer_dark_radio.add_css_class ("image-button");
        prefer_dark_radio.child = (dark_grid);

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
        prefer_soft_image.add_css_class ("icon-dropshadow");

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
        prefer_medium_image.add_css_class ("icon-dropshadow");

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
        prefer_harsh_image.add_css_class ("icon-dropshadow");

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

        grid.attach (prefer_main_box, 0, 0);

        var accent_label = new Gtk.Label (_("Accent Color")) {
            halign = Gtk.Align.START
        };
        accent_label.add_css_class ("cb-title");

        purple = new PrefersAccentColorButton (AccentColor.PURPLE);
        purple.tooltip_text = _("Purple");

        pink = new PrefersAccentColorButton (AccentColor.PINK, purple);
        pink.tooltip_text = _("Pink");

        red = new PrefersAccentColorButton (AccentColor.RED, purple);
        red.tooltip_text = _("Red");

        orange = new PrefersAccentColorButton (AccentColor.ORANGE, purple);
        orange.tooltip_text = _("Orange");

        yellow = new PrefersAccentColorButton (AccentColor.YELLOW, purple);
        yellow.tooltip_text = _("Yellow");

        green = new PrefersAccentColorButton (AccentColor.GREEN, purple);
        green.tooltip_text = _("Green");

        blue = new PrefersAccentColorButton (AccentColor.BLUE, purple);
        blue.tooltip_text = _("Blue");

        mint = new PrefersAccentColorButton (AccentColor.MINT, purple);
        mint.tooltip_text = _("Mint");

        mono = new PrefersAccentColorButton (AccentColor.MONO, purple);
        mono.tooltip_text = _("Mono");

        multi = new PrefersAccentColorButton (AccentColor.MULTI, purple);
        multi.tooltip_text = _("Set By Apps");

        var wallpaper_accent_label = new Gtk.Label (_("Accent Color From Wallpaper")) {
            halign = Gtk.Align.START
        };
        wallpaper_accent_label.add_css_class ("cb-subtitle");

        wallpaper_accent_switch = new Gtk.Switch () {
            halign = Gtk.Align.END,
            hexpand = true
        };

        var wallpaper_accent_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        wallpaper_accent_box.append (wallpaper_accent_label);
        wallpaper_accent_box.append (wallpaper_accent_switch);

        accent_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 23);
        accent_box.append (purple);
        accent_box.append (pink);
        accent_box.append (red);
        accent_box.append (orange);
        accent_box.append (yellow);
        accent_box.append (green);
        accent_box.append (mint);
        accent_box.append (blue);
        accent_box.append (mono);
        accent_box.append (multi);

        var accent_grid = new Gtk.Grid () {
            row_spacing = 12,
            column_homogeneous = true,
            hexpand = true,
            row_homogeneous = true,
            margin_bottom = 6
        };
        accent_grid.attach (accent_label, 0, 0);
        accent_grid.attach (accent_box, 0, 1);
        accent_grid.attach (wallpaper_accent_box, 0, 2);
        accent_grid.add_css_class ("mini-content-block");

        grid.attach (accent_grid, 0, 1);

        wallpaper_view = new Appearance.WallpaperGrid (fuse);
        grid.attach (wallpaper_view, 0, 2);

        fusebox_appearance_settings.bind ("wallpaper-accent", wallpaper_accent_switch, "active", SettingsBindFlags.DEFAULT);
        wallpaper_accent_switch.state_set.connect (() => {
            if (wallpaper_accent_switch.active) {
                accent_box.sensitive = false;

                multi.set_active (false);
                red.set_active (false);
                orange.set_active (false);
                yellow.set_active (false);
                green.set_active (false);
                mint.set_active (false);
                blue.set_active (false);
                purple.set_active (false);
                pink.set_active (false);
                mono.set_active (false);
                accent_set.begin ();
                wallpaper_view.notify["current_wallpaper_path"].connect (() => {
                    accent_set.begin ();
                });
            } else {
                accent_box.sensitive = true;
            }
            return Gdk.EVENT_PROPAGATE;
        });
        wallpaper_view.notify["current_wallpaper_path"].connect (() => {
            accent_set.begin ();
        });

        var sw = new Gtk.ScrolledWindow ();
        sw.hscrollbar_policy = (Gtk.PolicyType.NEVER);
        sw.set_child (grid);

        var clamp = new Bis.Latch ();
        clamp.set_child (sw);

        append (clamp);
  
        accent_refresh ();
        tau_appearance_settings.notify["changed::accent-color"].connect (() => {
            accent_refresh ();
        });

        prefer_default_radio.toggled.connect (() => {
            set_color_scheme (He.Desktop.ColorScheme.NO_PREFERENCE);
            prefer_dm_sep.visible = false;
            prefer_dm_label.visible = false;
            prefer_dm_box.visible = false;
        });
        prefer_light_radio.toggled.connect (() => {
            set_color_scheme (He.Desktop.ColorScheme.LIGHT);
            prefer_dm_sep.visible = false;
            prefer_dm_label.visible = false;
            prefer_dm_box.visible = false;
        });
        prefer_dark_radio.toggled.connect (() => {
            set_color_scheme (He.Desktop.ColorScheme.DARK);
            prefer_dm_sep.visible = true;
            prefer_dm_label.visible = true;
            prefer_dm_box.visible = true;
        });

        color_scheme_refresh ();
        interface_settings.notify["changed::color-scheme"].connect (() => {
            color_scheme_refresh ();
        });

        prefer_soft_radio.toggled.connect (() => {
            set_dark_mode_strength (He.Desktop.DarkModeStrength.SOFT);
        });
        prefer_medium_radio.toggled.connect (() => {
            set_dark_mode_strength (He.Desktop.DarkModeStrength.MEDIUM);
        });
        prefer_harsh_radio.toggled.connect (() => {
            set_dark_mode_strength (He.Desktop.DarkModeStrength.HARSH);
        });

        dark_mode_strength_refresh ();
        tau_appearance_settings.notify["changed::dark-mode-strength"].connect (() => {
            dark_mode_strength_refresh ();
        });
    }

    private void set_color_scheme (He.Desktop.ColorScheme color_scheme) {
        interface_settings.set_enum ("color-scheme", color_scheme);
    }

    private void color_scheme_refresh () {
        int value = interface_settings.get_enum ("color-scheme");

        if (value == He.Desktop.ColorScheme.NO_PREFERENCE) {
            prefer_default_radio.set_active (true);
            prefer_light_radio.set_active (false);
            prefer_dark_radio.set_active (false);
        } else if (value == He.Desktop.ColorScheme.LIGHT) {
            prefer_default_radio.set_active (false);
            prefer_light_radio.set_active (true);
            prefer_dark_radio.set_active (false);
        } else if (value == He.Desktop.ColorScheme.DARK) {
            prefer_default_radio.set_active (false);
            prefer_light_radio.set_active (false);
            prefer_dark_radio.set_active (true);
        }
    }

    private void set_dark_mode_strength (He.Desktop.DarkModeStrength strength) {
        tau_appearance_settings.set_enum ("dark-mode-strength", strength);
    }

    private void dark_mode_strength_refresh () {
        int value = tau_appearance_settings.get_enum ("dark-mode-strength");

        if (value == He.Desktop.DarkModeStrength.SOFT) {
            prefer_soft_radio.set_active (true);
            prefer_medium_radio.set_active (false);
            prefer_harsh_radio.set_active (false);
        } else if (value == He.Desktop.DarkModeStrength.MEDIUM) {
            prefer_soft_radio.set_active (false);
            prefer_medium_radio.set_active (true);
            prefer_harsh_radio.set_active (false);
        } else if (value == He.Desktop.DarkModeStrength.HARSH) {
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
        }
    }

    private async void accent_set () {
        try {
            var file = File.new_for_uri (wallpaper_view.active_wallpaper.uri);
            var pixbuf = new Gdk.Pixbuf.from_file_at_size (file.get_path (), 512, 512);

            var palette = new Appearance.Utils.Palette.from_pixbuf (pixbuf);
            palette.generate_async.begin (() => {
                this.palette = palette;

                // Checking for null avoids getting palette's colors that aren't there.
                if (palette.dark_muted_swatch != null) {
                    Gdk.RGBA color = {palette.dark_muted_swatch.red, palette.dark_muted_swatch.green, palette.dark_muted_swatch.blue, 1};
                    desktop.wallpaper_accent_color = color;
                }
            });
        } catch (Error e) {}
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
                    tau_appearance_settings.set_enum ("accent-color", color);
                });
            });
        }
    }
}

