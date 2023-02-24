public class AppearanceView : Gtk.Box {
    private static GLib.Settings interface_settings;
    private static GLib.Settings tau_appearance_settings;
    private static GLib.Settings fusebox_appearance_settings;
    private static GLib.Settings bg_settings;
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
    private EnsorModeButton defavlt; // default is a Vala keyword, deal with it
    private EnsorModeButton muted;
    private EnsorModeButton vibrant;
    private EnsorModeButton monochrome;
    private Gtk.ToggleButton prefer_light_radio;
    private Gtk.ToggleButton prefer_default_radio;
    private Gtk.ToggleButton prefer_dark_radio;
    private Gtk.ToggleButton prefer_soft_radio;
    private Gtk.ToggleButton prefer_medium_radio;
    private Gtk.ToggleButton prefer_harsh_radio;
    private Gtk.Box accent_box;

    public Fusebox.Fuse fuse { get; construct set; }
    public Appearance.WallpaperGrid wallpaper_view;
    public Gtk.Switch accent_switch;
    public Gtk.ScrolledWindow sw;
    private Gtk.Box ensor_box;

    public AppearanceView (Fusebox.Fuse _fuse) {
        Object (fuse: _fuse);
    }

    static construct {
        tau_appearance_settings = new GLib.Settings ("com.fyralabs.desktop.appearance");
        fusebox_appearance_settings = new GLib.Settings ("com.fyralabs.Fusebox");
        interface_settings = new GLib.Settings ("org.gnome.desktop.interface");
        bg_settings = new GLib.Settings ("org.gnome.desktop.background");
    }

    construct {
        var prefer_label = new Gtk.Label (_("Color Scheme")) {
            halign = Gtk.Align.START
        };
        prefer_label.add_css_class ("cb-title");

        var prefer_default_image = new Gtk.Image.from_resource ("/com/fyralabs/Fusebox/Appearance/by-apps.svg") {
            pixel_size = 64,
            hexpand = true,
            halign = Gtk.Align.CENTER
        };

        var prefer_default_card = new Gtk.Grid ();
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

        var prefer_light_image = new Gtk.Image.from_resource ("/com/fyralabs/Fusebox/Appearance/light.svg") {
            pixel_size = 64
        };

        var prefer_light_card = new Gtk.Grid ();
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

        var dark_image = new Gtk.Image.from_resource ("/com/fyralabs/Fusebox/Appearance/dark.svg") {
            pixel_size = 64
        };

        var dark_card = new Gtk.Grid ();
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

        var prefer_style_box = new He.SegmentedButton () {
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

        var prefer_soft_image = new Gtk.Image.from_resource ("/com/fyralabs/Fusebox/Appearance/soft.svg") {
            pixel_size = 64
        };
        prefer_soft_image.add_css_class ("icon-dropshadow");

        var prefer_soft_card = new Gtk.Grid ();
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

        var prefer_medium_image = new Gtk.Image.from_resource ("/com/fyralabs/Fusebox/Appearance/medium.svg") {
            pixel_size = 64
        };
        prefer_medium_image.add_css_class ("icon-dropshadow");

        var prefer_medium_card = new Gtk.Grid ();
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

        var prefer_harsh_image = new Gtk.Image.from_resource ("/com/fyralabs/Fusebox/Appearance/harsh.svg") {
            pixel_size = 64
        };
        prefer_harsh_image.add_css_class ("icon-dropshadow");

        var prefer_harsh_card = new Gtk.Grid ();
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

        var prefer_dm_box = new He.SegmentedButton () {
            hexpand = true,
            homogeneous = true,
            visible = false
        };
        prefer_dm_box.append (prefer_soft_radio);
        prefer_dm_box.append (prefer_medium_radio);
        prefer_dm_box.append (prefer_harsh_radio);

        var prefer_main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        prefer_main_box.append (prefer_label);
        prefer_main_box.append (prefer_style_box);

        var prefer_main_dm_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        prefer_main_dm_box.append (prefer_dm_label);
        prefer_main_dm_box.append (prefer_dm_box);

        var prefer_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        prefer_box.append (prefer_main_box);
        prefer_box.append (prefer_dm_sep);
        prefer_box.append (prefer_main_dm_box);
        prefer_box.add_css_class ("mini-content-block");

        var grid = new Gtk.Grid () {
            row_spacing = 6,
            margin_start = 18,
            margin_end = 18,
            margin_bottom = 18,
            margin_top = 18
        };
        grid.attach (prefer_box, 0, 0);

        var accent_label = new Gtk.Label (_("Accent Color")) {
            halign = Gtk.Align.START
        };
        accent_label.add_css_class ("cb-title");

        purple = new PrefersAccentColorButton ("purple");
        purple.tooltip_text = _("Purple");

        pink = new PrefersAccentColorButton ("pink", purple);
        pink.tooltip_text = _("Pink");

        red = new PrefersAccentColorButton ("red", purple);
        red.tooltip_text = _("Red");

        orange = new PrefersAccentColorButton ("orange", purple);
        orange.tooltip_text = _("Orange");

        yellow = new PrefersAccentColorButton ("yellow", purple);
        yellow.tooltip_text = _("Yellow");

        green = new PrefersAccentColorButton ("green", purple);
        green.tooltip_text = _("Green");

        blue = new PrefersAccentColorButton ("blue", purple);
        blue.tooltip_text = _("Blue");

        mint = new PrefersAccentColorButton ("mint", purple);
        mint.tooltip_text = _("Mint");

        mono = new PrefersAccentColorButton ("mono", purple);
        mono.tooltip_text = _("Mono");

        multi = new PrefersAccentColorButton ("multi", purple);
        multi.tooltip_text = _("Set By Apps");

        var accentw_label = new Gtk.Label (_("Accent Color From Wallpaper")) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        accentw_label.add_css_class ("cb-subtitle");

        accent_switch = new Gtk.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };

        var wallpaper_accent_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        wallpaper_accent_box.append (accentw_label);
        wallpaper_accent_box.append (accent_switch);

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

        var ensor_label = new Gtk.Label (_("Accent Color Scheme")) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        ensor_label.add_css_class ("cb-subtitle");

        var ensor_info = new Gtk.Image () {
            icon_name = "dialog-information-symbolic",
            tooltip_text = _("The accent color engine sets user interface color tones based on scheme choice.")
        };

        defavlt = new EnsorModeButton ("default");
        defavlt.tooltip_text = _("Default Scheme");
        muted = new EnsorModeButton ("muted", defavlt);
        muted.tooltip_text = _("Muted Scheme");
        vibrant = new EnsorModeButton ("vibrant", defavlt);
        vibrant.tooltip_text = _("Vibrant Scheme");
        monochrome = new EnsorModeButton ("mono", defavlt);
        monochrome.tooltip_text = _("Monochromatic Scheme");

        ensor_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 23);
        ensor_box.hexpand = true;
        ensor_box.halign = Gtk.Align.END;
        ensor_box.append (defavlt);
        ensor_box.append (muted);
        ensor_box.append (vibrant);
        ensor_box.append (monochrome);

        var ensor_main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        ensor_main_box.append (ensor_label);
        ensor_main_box.append (ensor_info);
        ensor_main_box.append (ensor_box);

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
        accent_grid.attach (ensor_main_box, 0, 3);
        accent_grid.add_css_class ("mini-content-block");

        grid.attach (accent_grid, 0, 3);

        wallpaper_view = new Appearance.WallpaperGrid (fuse, this);
        grid.attach (wallpaper_view, 0, 4);

        fusebox_appearance_settings.bind ("wallpaper-accent", accent_switch, "active", SettingsBindFlags.DEFAULT);
        fusebox_appearance_settings.bind("wallpaper-accent", accent_box, "sensitive", SettingsBindFlags.INVERT_BOOLEAN);

        accent_switch.state_set.connect (() => {
            if (accent_switch.active) {
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
            } else {
                multi.set_active (true);
                accent_box.sensitive = true;
            }
            return Gdk.EVENT_PROPAGATE;
        });

        sw = new Gtk.ScrolledWindow ();
        sw.hscrollbar_policy = (Gtk.PolicyType.NEVER);
        sw.set_child (grid);

        var clamp = new Bis.Latch ();
        clamp.set_child (sw);

        append (clamp);

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

    public async void accent_set () {
        try {
            GLib.File file = File.new_for_uri (bg_settings.get_string ("picture-uri"));
            Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file (file.get_path ());

            var loop = new MainLoop ();
            He.Ensor.accent_from_pixels_async.begin (pixbuf.get_pixels_with_length (), pixbuf.get_has_alpha (), (obj, res) => {
                GLib.Array<int?> result = He.Ensor.accent_from_pixels_async.end (res);
                int top = result.index (0);
                print ("FIRST FUSEBOX ARGB RESULT (should be the same as Ensor's): %d\n".printf (top));
    
                if (top != 0) {
                    tau_appearance_settings.set_string ("accent-color", He.Color.hexcode_argb (top));
                } else {
                    tau_appearance_settings.set_string ("accent-color", "#8C56BF");
                }
                loop.quit ();
            });
            loop.run ();

        } catch (Error e) {
            print (e.message);
        }
    }

    private class EnsorModeButton : Gtk.CheckButton {
        public string mode { get; construct; }

        public EnsorModeButton (string mode, Gtk.CheckButton? group_member = null) {
            Object (
                    mode: mode,
                    group: group_member
            );
        }

        construct {
            if (mode == "mono") {
                add_css_class ("mono2");
            } else {
                add_css_class (mode.to_string ());
            }

            add_css_class ("selection-mode");

            active = mode == tau_appearance_settings.get_string ("ensor-scheme");

            realize.connect (() => {
                toggled.connect (() => {
                    if (mode == "default") {
                        tau_appearance_settings.set_string ("ensor-scheme", "default");
                    } else if (mode == "muted") {
                        tau_appearance_settings.set_string ("ensor-scheme", "muted");
                    } else if (mode == "vibrant") {
                        tau_appearance_settings.set_string ("ensor-scheme", "vibrant");
                    } else if (mode == "mono") {
                        tau_appearance_settings.set_string ("ensor-scheme", "mono");
                    }
                });
            });
        }
    }

    private class PrefersAccentColorButton : Gtk.CheckButton {
        public string color { get; construct; }

        public PrefersAccentColorButton (string color, Gtk.CheckButton? group_member = null) {
            Object (
                    color: color,
                    group: group_member
            );
        }

        construct {
            add_css_class (color.to_string ());
            add_css_class ("selection-mode");

            active = color == tau_appearance_settings.get_string ("accent-color");

            realize.connect (() => {
                toggled.connect (() => {
                    if (color == "purple") {
                        tau_appearance_settings.set_string ("accent-color", "purple");
                    } else if (color == "pink") {
                        tau_appearance_settings.set_string ("accent-color", "pink");
                    } else if (color == "red") {
                        tau_appearance_settings.set_string ("accent-color", "red");
                    } else if (color == "orange") {
                        tau_appearance_settings.set_string ("accent-color", "orange");
                    } else if (color == "yellow") {
                        tau_appearance_settings.set_string ("accent-color", "yellow");
                    } else if (color == "green") {
                        tau_appearance_settings.set_string ("accent-color", "green");
                    } else if (color == "mint") {
                        tau_appearance_settings.set_string ("accent-color", "mint");
                    } else if (color == "blue") {
                        tau_appearance_settings.set_string ("accent-color", "blue");
                    } else if (color == "mono") {
                        tau_appearance_settings.set_string ("accent-color", "mono");
                    } else if (color == "multi") {
                        tau_appearance_settings.set_string ("accent-color", "multi");
                    }
                });
            });
        }
    }
}
