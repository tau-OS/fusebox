public class AppearanceView : Gtk.Box {
    private static GLib.Settings interface_settings;
    private static GLib.Settings tau_appearance_settings;
    private static GLib.Settings fusebox_appearance_settings;
    private static GLib.Settings bg_settings;
    private PrefersAccentColorButton red;
    private PrefersAccentColorButton yellow;
    private PrefersAccentColorButton green;
    private PrefersAccentColorButton blue;
    private PrefersAccentColorButton purple;
    private PrefersAccentColorButton pink;
    private PrefersAccentColorButton mono;
    private PrefersAccentColorButton multi;
    private PrefersAccentColorButton first_accent;
    private PrefersAccentColorButton second_accent;
    private PrefersAccentColorButton third_accent;
    private PrefersAccentColorButton fourth_accent;
    private EnsorModeButton defavlt; // default is a Vala keyword, deal with it
    private EnsorModeButton muted;
    private EnsorModeButton vibrant;
    private EnsorModeButton monochrome;
    private EnsorModeButton salad;
    private Gtk.CheckButton prefer_light_radio;
    private Gtk.CheckButton prefer_default_radio;
    private Gtk.CheckButton prefer_dark_radio;
    private Gtk.Box accent_box;
    private Gtk.Box wallpaper_accent_choices_box;
    public He.ContentBlockImage wallpaper_preview;
    public He.ContentBlockImage wallpaper_lock_preview;
    public Fusebox.Fuse fuse { get; construct set; }
    public Appearance.WallpaperGrid wallpaper_view;
    public He.Switch wp_switch;
    public Gtk.ScrolledWindow sw;
    public Gtk.Stack contrast_stack;
    public Gtk.Stack wallpaper_stack;
    public Gtk.Stack main_stack;
    private Gtk.FlowBox main_flowbox;
    private EnsorModeButton current_emb;
    private uint rscale_timeout;

    private string _ensor;
    public string ensor {
        get { return _ensor; }
        set {
            if (value == "default") {
                select_ensor (defavlt);
                return;
            }

            if (value == "muted") {
                select_ensor (muted);
                return;
            }

            if (value == "vibrant") {
                select_ensor (vibrant);
                return;
            }

            if (value == "mono") {
                select_ensor (monochrome);
                return;
            }

            _ensor = value;
            critical ("Unknown palette ID: %s", value);
        }
    }


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
        // Wallpaper Block
        wallpaper_view = new Appearance.WallpaperGrid (fuse, this);

        wallpaper_preview = new He.ContentBlockImage (wallpaper_view.current_wallpaper_path) {
            requested_height = 200,
            requested_width = 300
        };

        wallpaper_lock_preview = new He.ContentBlockImage (wallpaper_view.current_lock_wallpaper_path) {
            requested_height = 200,
            requested_width = 300
        };

        var clock = new Gtk.Label ("09\n41");
        clock.add_css_class ("display");
        clock.add_css_class ("numeric");
        clock.add_css_class ("lock-text");

        var wallpaper_lock_preview_overlay = new Gtk.Overlay ();
        wallpaper_lock_preview_overlay.set_child (wallpaper_lock_preview);
        wallpaper_lock_preview_overlay.add_overlay (clock);

        // XXX: UNCOMMENT WHEN KIRI LOCK SCREEN IS IMPL'D
        //
        //  var edit_button = new He.Button ("document-edit-symbolic", "") {
        //      hexpand = true,
        //      vexpand = true,
        //      halign = Gtk.Align.END,
        //      valign = Gtk.Align.END,
        //      margin_end = 12,
        //      margin_bottom = 12,
        //      is_disclosure = true,
        //      tooltip_text = _("Customize Lock Screen…")
        //  };

        //  var wallpaper_lock_button_overlay = new Gtk.Overlay ();
        //  wallpaper_lock_button_overlay.set_child (wallpaper_lock_preview_overlay);
        //  wallpaper_lock_button_overlay.add_overlay (edit_button);

        var wallpaper_preview_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            hexpand = true,
            vexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.START
        };
        wallpaper_preview_box.add_css_class ("lock-box");
        wallpaper_preview_box.append (wallpaper_lock_preview_overlay);
        wallpaper_preview_box.append (wallpaper_preview);

        var wallpaper_grid_button = new He.Button ("", "") {
            hexpand = true,
            vexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.START,
            is_textual = true,
            child = new He.ButtonContent () {
                icon = "image-x-generic-symbolic",
                label = _("Change Wallpaper…")
            }
        };

        var wallpaper_main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        wallpaper_main_box.append (wallpaper_preview_box);
        wallpaper_main_box.append (wallpaper_grid_button);
        wallpaper_main_box.add_css_class ("mini-content-block");

        // Color Scheme Block
        var prefer_label = new Gtk.Label (_("Color Scheme")) {
            halign = Gtk.Align.START
        };
        prefer_label.add_css_class ("cb-title");

        prefer_default_radio = new Gtk.CheckButton () {
            hexpand = true,
            tooltip_text = _("Enable apps to select their color scheme.")
        };
        prefer_default_radio.add_css_class ("selection-mode");
        prefer_default_radio.add_css_class ("color-scheme-button");
        prefer_default_radio.add_css_class ("set-apps");

        prefer_light_radio = new Gtk.CheckButton () {
            group = prefer_default_radio,
            tooltip_text = _("Set all apps to use a light theme."),
            hexpand = true
        };
        prefer_light_radio.add_css_class ("selection-mode");
        prefer_light_radio.add_css_class ("color-scheme-button");
        prefer_light_radio.add_css_class ("light");

        prefer_dark_radio = new Gtk.CheckButton () {
            group = prefer_default_radio,
            tooltip_text = _("Set all apps to use a dark theme."),
            hexpand = true
        };
        prefer_dark_radio.add_css_class ("selection-mode");
        prefer_dark_radio.add_css_class ("color-scheme-button");
        prefer_dark_radio.add_css_class ("dark");

        var prefer_style_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            hexpand = true,
            halign = Gtk.Align.END
        };
        prefer_style_box.append (prefer_light_radio);
        prefer_style_box.append (prefer_dark_radio);
        prefer_style_box.append (prefer_default_radio);

        var prefer_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        prefer_box.append (prefer_label);
        prefer_box.append (prefer_style_box);
        prefer_box.add_css_class ("mini-content-block");

        var accent_label = new Gtk.Label (_("Accent color")) {
            halign = Gtk.Align.START
        };
        accent_label.add_css_class ("cb-title");

        purple = new PrefersAccentColorButton ("purple", "");
        purple.tooltip_text = _("Purple");

        pink = new PrefersAccentColorButton ("pink", "", purple);
        pink.tooltip_text = _("Pink");

        red = new PrefersAccentColorButton ("red", "", purple);
        red.tooltip_text = _("Red");

        yellow = new PrefersAccentColorButton ("yellow", "", purple);
        yellow.tooltip_text = _("Yellow");

        green = new PrefersAccentColorButton ("green", "", purple);
        green.tooltip_text = _("Green");

        blue = new PrefersAccentColorButton ("blue", "", purple);
        blue.tooltip_text = _("Blue");

        mono = new PrefersAccentColorButton ("mono", "", purple);
        mono.tooltip_text = _("Mono");

        multi = new PrefersAccentColorButton ("multi", "", purple);
        multi.tooltip_text = _("Set By Apps");

        var accentw_label = new Gtk.Label (_("Wallpaper Color")) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        accentw_label.add_css_class ("cb-title");

        wp_switch = new He.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
        };

        wallpaper_accent_choices_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };
        first_accent = new PrefersAccentColorButton ("wallpaper1", null, null) {
            visible = false,
            tooltip_text = _("Wallpaper Accent #1")
        };
        second_accent = new PrefersAccentColorButton ("wallpaper2", null, first_accent) {
            visible = false,
            tooltip_text = _("Wallpaper Accent #2")
        };
        third_accent = new PrefersAccentColorButton ("wallpaper3", null, first_accent) {
            visible = false,
            tooltip_text = _("Wallpaper Accent #3")
        };
        fourth_accent = new PrefersAccentColorButton ("wallpaper4", null, first_accent) {
            visible = false,
            tooltip_text = _("Wallpaper Accent #4")
        };
        wallpaper_accent_choices_box.append (first_accent);
        wallpaper_accent_choices_box.append (second_accent);
        wallpaper_accent_choices_box.append (third_accent);
        wallpaper_accent_choices_box.append (fourth_accent);

        var dummy_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };

        var wallpaper_accent_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        wallpaper_accent_box.append (accentw_label);
        wallpaper_accent_box.append (dummy_box);
        wallpaper_accent_box.append (wallpaper_accent_choices_box);
        wallpaper_accent_box.append (wp_switch);

        accent_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            halign = Gtk.Align.END,
            hexpand = true
        };
        accent_box.append (multi);
        accent_box.append (purple);
        accent_box.append (pink);
        accent_box.append (red);
        accent_box.append (yellow);
        accent_box.append (green);
        accent_box.append (blue);
        accent_box.append (mono);

        var accent_main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        accent_main_box.append (accent_label);
        accent_main_box.append (accent_box);

        var ensor_label = new Gtk.Label (_("Accent Scheme")) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        ensor_label.add_css_class ("cb-title");

        var ensor_info = new Gtk.Image () {
            icon_name = "dialog-information-symbolic",
            tooltip_text = _("Pick a scheme to set the color tones for your user interface.")
        };

        defavlt = new EnsorModeButton ("default");
        defavlt.tooltip_text = _("Default Scheme");
        muted = new EnsorModeButton ("muted");
        muted.tooltip_text = _("Muted Scheme");
        vibrant = new EnsorModeButton ("vibrant");
        vibrant.tooltip_text = _("Vibrant Scheme");
        monochrome = new EnsorModeButton ("mono");
        monochrome.tooltip_text = _("Monochromatic Scheme");
        salad = new EnsorModeButton ("salad");
        salad.tooltip_text = _("Fruit Salad Scheme");

        main_flowbox = new Gtk.FlowBox () {
            hexpand = true,
            halign = Gtk.Align.END,
            column_spacing = 24,
            homogeneous = true,
            min_children_per_line = 5,
            max_children_per_line = 5
        };
        main_flowbox.append (defavlt);
        main_flowbox.append (muted);
        main_flowbox.append (vibrant);
        main_flowbox.append (salad);
        main_flowbox.append (monochrome);
        main_flowbox.child_activated.connect (child_activated_cb);

        ensor_refresh ();
        tau_appearance_settings.notify["changed::ensor-scheme"].connect (() => {
            ensor_refresh ();
        });

        var ensor_main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        ensor_main_box.append (ensor_label);
        ensor_main_box.append (ensor_info);
        ensor_main_box.append (main_flowbox);
        ensor_main_box.add_css_class ("ensor-box");

        var contrast_label = new Gtk.Label (_("Contrast Settings")) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        contrast_label.add_css_class ("cb-title");

        var contrast_grid_button = new He.Button ("pan-end-symbolic", "") {
            hexpand = true,
            vexpand = true,
            halign = Gtk.Align.END,
            valign = Gtk.Align.START,
            is_disclosure = true
        };

        var contrast_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        contrast_box.append (contrast_label);
        contrast_box.append (contrast_grid_button);
        contrast_box.add_css_class ("mini-content-block");

        var roundness_label = new Gtk.Label (_("Interface Roundness")) {
            halign = Gtk.Align.START
        };
        roundness_label.add_css_class ("cb-title");

        var roundness_info = new Gtk.Image () {
            icon_name = "dialog-information-symbolic",
            tooltip_text = _("Adjust the roundness of your user interface.")
        };

        var roundness_adjustment = new Gtk.Adjustment (-1, 0.5, 2.0, 0.5, 0, 0);

        var roundness_scale = new He.Slider () {
            hexpand = true
        };
        roundness_scale.scale.orientation = Gtk.Orientation.HORIZONTAL;
        roundness_scale.scale.adjustment = roundness_adjustment;
        roundness_scale.scale.draw_value = true;
        roundness_scale.scale.value_pos = Gtk.PositionType.LEFT;
        roundness_scale.add_mark (1.0, "");

        var roundness_title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        roundness_title_box.append (roundness_label);
        roundness_title_box.append (roundness_info);

        var roundness_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        roundness_box.append (roundness_title_box);
        roundness_box.append (roundness_scale);
        roundness_box.add_css_class ("mini-content-block");

        tau_appearance_settings.bind ("roundness", roundness_adjustment, "value", SettingsBindFlags.GET);

        // Setting scale is slow, so we wait while pressed to keep UI responsive
        roundness_adjustment.value_changed.connect (() => {
            if (rscale_timeout != 0) {
                GLib.Source.remove (rscale_timeout);
            }

            rscale_timeout = Timeout.add (300, () => {
                rscale_timeout = 0;
                tau_appearance_settings.set_double ("roundness", roundness_adjustment.value);
                return false;
            });
        });


        var grid = new Gtk.Grid () {
            row_spacing = 18,
            vexpand = true,
            valign = Gtk.Align.START
        };

        grid.attach (accent_main_box, 0, 0);
        grid.attach (wallpaper_accent_box, 0, 1);
        grid.attach (ensor_main_box, 0, 2);
        grid.add_css_class ("mini-content-block");

        fusebox_appearance_settings.bind ("wallpaper-accent", wp_switch.iswitch, "active", SettingsBindFlags.DEFAULT);
        fusebox_appearance_settings.bind ("wallpaper-accent", accent_box, "sensitive", SettingsBindFlags.INVERT_BOOLEAN);
        fusebox_appearance_settings.bind ("wallpaper-accent", wallpaper_accent_choices_box, "visible", SettingsBindFlags.DEFAULT);
        fusebox_appearance_settings.bind ("wallpaper-accent", dummy_box, "visible", SettingsBindFlags.INVERT_BOOLEAN);

        accent_setup.begin ();
        wp_switch.iswitch.state_set.connect (() => {
            if (wp_switch.iswitch.active) {
                accent_box.sensitive = false;

                multi.set_active (false);
                red.set_active (false);
                yellow.set_active (false);
                green.set_active (false);
                blue.set_active (false);
                purple.set_active (false);
                pink.set_active (false);

                accent_setup.begin ();
            } else {
                multi.set_active (true);
                accent_box.sensitive = true;
            }
            return Gdk.EVENT_PROPAGATE;
        });

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_start = 18,
            margin_end = 18,
            margin_bottom = 18
        };
        main_box.append (wallpaper_main_box);
        main_box.append (grid);

        var sub_box = new Gtk.ListBox ();
        sub_box.append (prefer_box);
        sub_box.append (roundness_box);
        sub_box.append (contrast_box);
        sub_box.add_css_class ("content-list");

        main_box.append (sub_box);

        sw = new Gtk.ScrolledWindow ();
        sw.hscrollbar_policy = (Gtk.PolicyType.NEVER);
        sw.set_child (main_box);

        var window_view = new Appearance.WindowView ();
        var text_view = new Appearance.TextView ();

        main_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
            transition_duration = 400
        };
        main_stack.add_titled (sw, "desktop", _("Desktop"));
        main_stack.add_titled (window_view, "windows", _("Windows"));
        main_stack.add_titled (text_view, "text", _("Text"));

        var stack_switcher = new He.ViewSwitcher ();
        stack_switcher.stack = main_stack;

        var appbar = new He.AppBar () {
            show_back = false,
            show_left_title_buttons = false,
            show_right_title_buttons = true,
            viewtitle_widget = stack_switcher
        };

        var abox = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        abox.append (appbar);
        abox.append (main_stack);

        wallpaper_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
            transition_duration = 400
        };
        wallpaper_stack.add_titled (abox, "appearance", _("Appearance"));
        wallpaper_stack.add_titled (wallpaper_view, "wallpaper", _("Wallpaper"));

        wallpaper_grid_button.clicked.connect (() => {
            wallpaper_stack.set_visible_child_name ("wallpaper");
        });

        var contrast_view = new Appearance.ContrastView (fuse, this);

        contrast_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
            transition_duration = 400
        };
        contrast_stack.add_titled (wallpaper_stack, "appearance", _("Appearance"));
        contrast_stack.add_titled (contrast_view, "contrast", _("Contrast"));

        contrast_grid_button.clicked.connect (() => {
            contrast_stack.set_visible_child_name ("contrast");
        });

        orientation = Gtk.Orientation.VERTICAL;
        append (contrast_stack);

        prefer_default_radio.toggled.connect (() => {
            set_color_scheme (He.Desktop.ColorScheme.NO_PREFERENCE);
        });
        prefer_light_radio.toggled.connect (() => {
            set_color_scheme (He.Desktop.ColorScheme.LIGHT);
        });
        prefer_dark_radio.toggled.connect (() => {
            set_color_scheme (He.Desktop.ColorScheme.DARK);
        });

        color_scheme_refresh ();
        interface_settings.notify["changed::color-scheme"].connect (() => {
            color_scheme_refresh ();
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

    public async void accent_setup () {
        try {
            GLib.File file = File.new_for_uri (bg_settings.get_string ("picture-uri"));
            Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file (file.get_path ());

            var loop = new MainLoop ();
            He.Ensor.accent_from_pixels_async.begin (pixbuf.get_pixels_with_length (), pixbuf.get_has_alpha (), (obj, res) => {
                GLib.Array<int?> result = He.Ensor.accent_from_pixels_async.end (res);

                if (fusebox_appearance_settings.get_int ("wallpaper-accent-choice") == 0) {
                    tau_appearance_settings.set_string ("accent-color", He.hexcode_argb (result.index (0)));
                    first_accent.active = true;
                } else if (fusebox_appearance_settings.get_int ("wallpaper-accent-choice") == 1 && result.index (1) != null) {
                    tau_appearance_settings.set_string ("accent-color", He.hexcode_argb (result.index (1)));
                    second_accent.active = true;
                } else if (fusebox_appearance_settings.get_int ("wallpaper-accent-choice") == 2 && result.index (1) != null && result.index (2) != null) {
                    tau_appearance_settings.set_string ("accent-color", He.hexcode_argb (result.index (2)));
                    third_accent.active = true;
                } else if (fusebox_appearance_settings.get_int ("wallpaper-accent-choice") == 3 && result.index (1) != null && result.index (2) != null && result.index (3) != null) {
                    tau_appearance_settings.set_string ("accent-color", He.hexcode_argb (result.index (3)));
                    fourth_accent.active = true;
                }

                if (result.index (0) != null) {
                    first_accent.hex = He.hexcode_argb (result.index (0));
                    first_accent.visible = true;
                    second_accent.visible = false;
                    third_accent.visible = false;
                    fourth_accent.visible = false;
                }
                if (result.index (0) != null && result.index (1) != null) {
                    first_accent.hex = He.hexcode_argb (result.index (0));
                    second_accent.hex = He.hexcode_argb (result.index (1));
                    first_accent.visible = true;
                    second_accent.visible = true;
                    third_accent.visible = false;
                    fourth_accent.visible = false;
                }
                if (result.index (0) != null && result.index (1) != null && result.index (2) != null) {
                    first_accent.hex = He.hexcode_argb (result.index (0));
                    second_accent.hex = He.hexcode_argb (result.index (1));
                    third_accent.hex = He.hexcode_argb (result.index (2));
                    first_accent.visible = true;
                    second_accent.visible = true;
                    third_accent.visible = true;
                    fourth_accent.visible = false;
                }
                if (result.index (0) != null && result.index (1) != null && result.index (2) != null && result.index (3) != null) {
                    first_accent.hex = He.hexcode_argb (result.index (0));
                    second_accent.hex = He.hexcode_argb (result.index (1));
                    third_accent.hex = He.hexcode_argb (result.index (2));
                    fourth_accent.hex = He.hexcode_argb (result.index (3));
                    first_accent.visible = true;
                    second_accent.visible = true;
                    third_accent.visible = true;
                    fourth_accent.visible = true;
                }

                loop.quit ();
            });
            loop.run ();

        } catch (Error e) {
            print (e.message);
        }
    }

    private void child_activated_cb (Gtk.FlowBoxChild child) {
        select_ensor (child as EnsorModeButton);
    }

    private void select_ensor (EnsorModeButton emb) {
        current_emb = emb;
        _ensor = emb.mode;
        tau_appearance_settings.set_string ("ensor-scheme", emb.mode);
        main_flowbox.select_child (current_emb);
    }

    private void ensor_refresh () {
        string value = tau_appearance_settings.get_string ("ensor-scheme");

        if (value == "default") {
            select_ensor (defavlt);
        } else if (value == "muted") {
            select_ensor (muted);
        } else if (value == "vibrant") {
            select_ensor (vibrant);
        } else if (value == "mono") {
            select_ensor (monochrome);
        } else if (value == "salad") {
            select_ensor (salad);
        }
    }

    private class EnsorModeButton : Gtk.FlowBoxChild {
        public string mode { get; construct; }
        public int[] colors;

        public EnsorModeButton (string mode) {
            Object (
                    mode: mode
            );
            width_request = 42;
            height_request = 42;
            overflow = HIDDEN;
            add_css_class ("x-large-radius");
        }

        construct {
            if (mode == "default") {
                colors = {0x6F528B, 0x665A6F, 0xFFFBFF, 0x815157};
            } else if (mode == "muted") {
                colors = {0x645B6A, 0x635C66, 0xFEF8FA, 0x765659};
            } else if (mode == "vibrant") {
                colors = {0x8900E9, 0x705576, 0xFFF7FE, 0x7D4F76};
            } else if (mode == "mono") {
                colors = {0x5E5E5E, 0x5E5E5E, 0xF9F9F9, 0x5E5E5E};
            } else if (mode == "salad") {
                colors = {0x1F5FA8, 0x3C5F91, 0xFFFBFF, 0x6F528B};
            }
        }

        public override void snapshot (Gtk.Snapshot snapshot) {
            int w = get_width ();
            int h = get_height ();

            float r = 999;

            snapshot.translate ({ w / 2, h / 2 });

            Gsk.RoundedRect rect = {};
            rect.init_from_rect ({{ -r, -r }, { r * 2, r * 2 }}, r);
            snapshot.push_rounded_clip (rect);
            snapshot.append_color (color_to_rgba (0), {{ -r, -r }, { r, r }});
            snapshot.append_color (color_to_rgba (1), {{ -r, 0 }, { r, r }});
            snapshot.append_color (color_to_rgba (2), {{ 0, 0 }, { r, r }});
            snapshot.append_color (color_to_rgba (3), {{ 0, -r }, { r, r }});
            snapshot.pop ();
            snapshot.append_inset_shadow (rect, {0, 0, 0}, 0, 0, 1, 0);
        }
        private Gdk.RGBA color_to_rgba (int index) {
            int rgb = colors[index];
            float r = ((rgb >> 16) & 0xFF) / 255.0f;
            float g = ((rgb >> 8) & 0xFF) / 255.0f;
            float b = (rgb & 0xFF) / 255.0f;

            return { r, g, b, 1.0f };
        }
    }

    private class PrefersAccentColorButton : Gtk.CheckButton {
        public string color { get; construct; }
        public string hex { get; construct set; }

        public PrefersAccentColorButton (string color, string? hex = null, Gtk.CheckButton? group_member = null) {
            Object (
                    color: color,
                    hex: hex,
                    group: group_member
            );
        }

        construct {
            add_css_class (color.to_string ());
            add_css_class ("selection-mode");

            active = color == tau_appearance_settings.get_string ("accent-color");

            toggled.connect (() => {
                if (color == "purple") {
                    tau_appearance_settings.set_string ("accent-color", "purple");
                } else if (color == "pink") {
                    tau_appearance_settings.set_string ("accent-color", "pink");
                } else if (color == "red") {
                    tau_appearance_settings.set_string ("accent-color", "red");
                } else if (color == "orange") {
                    tau_appearance_settings.set_string ("accent-color", "orange");
                } else if (color == "brown") {
                    tau_appearance_settings.set_string ("accent-color", "brown");
                } else if (color == "yellow") {
                    tau_appearance_settings.set_string ("accent-color", "yellow");
                } else if (color == "green") {
                    tau_appearance_settings.set_string ("accent-color", "green");
                } else if (color == "mint") {
                    tau_appearance_settings.set_string ("accent-color", "mint");
                } else if (color == "blue") {
                    tau_appearance_settings.set_string ("accent-color", "blue");
                } else if (color == "multi") {
                    tau_appearance_settings.set_string ("accent-color", "multi");
                } else if (color == "mono") {
                    tau_appearance_settings.set_string ("accent-color", "mono");
                } else if (color == "wallpaper1") {
                    fusebox_appearance_settings.set_int ("wallpaper-accent-choice", 0);
                    tau_appearance_settings.set_string ("accent-color", hex);
                } else if (color == "wallpaper2") {
                    fusebox_appearance_settings.set_int ("wallpaper-accent-choice", 1);
                    tau_appearance_settings.set_string ("accent-color", hex);
                } else if (color == "wallpaper3") {
                    fusebox_appearance_settings.set_int ("wallpaper-accent-choice", 2);
                    tau_appearance_settings.set_string ("accent-color", hex);
                } else if (color == "wallpaper4") {
                    fusebox_appearance_settings.set_int ("wallpaper-accent-choice", 3);
                    tau_appearance_settings.set_string ("accent-color", hex);
                }
            });
        }
    }
}
