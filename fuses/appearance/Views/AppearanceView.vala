public class AppearanceView : Gtk.Box {
    private static GLib.Settings bg_settings;
    private static GLib.Settings fusebox_appearance_settings;
    private static GLib.Settings interface_settings;
    private static GLib.Settings tau_appearance_settings;

    public Fusebox.Fuse fuse { get; construct set; }

    private Gtk.ScrolledWindow color_sw;
    private Gtk.Box accent_box;
    private Gtk.CheckButton prefer_dark_radio;
    private Gtk.CheckButton prefer_default_radio;
    private Gtk.CheckButton prefer_light_radio;
    private Gtk.Stack color_stack;
    private Gtk.ToggleButton basic_type_button;
    private He.SegmentedButton color_type_button;

    private AccentColorButton blue;
    private AccentColorButton green;
    private AccentColorButton multi;
    private AccentColorButton pink;
    private AccentColorButton purple;
    private AccentColorButton red;
    private AccentColorButton yellow;

    public Gtk.ScrolledWindow sw;
    public Gtk.Stack contrast_stack;
    public Gtk.Stack main_stack;
    public Gtk.Stack wallpaper_stack;
    public Gtk.ToggleButton wallpaper_type_button;
    public He.ContentBlockImage wallpaper_lock_preview;
    public He.ContentBlockImage wallpaper_preview;

    public Appearance.WallpaperGrid wallpaper_view;
    public EnsorFlowBox ensor_flowbox;

    private uint rscale_timeout;
    private bool accent_setup_completed = false;

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
        setup_ui ();

        // Defer expensive operations until after UI is shown
        GLib.Idle.add (() => {
            if (wallpaper_type_button.active && !accent_setup_completed) {
                accent_setup_async.begin ();
            }
            return false;
        });
    }

    private void setup_ui () {
        /*
         * Build UI components without expensive operations
         */

        // Wallpaper section - use placeholders initially
        wallpaper_view = new Appearance.WallpaperGrid (fuse, this);

        wallpaper_preview = new He.ContentBlockImage ("") {
            requested_height = 200,
            requested_width = 300
        };

        wallpaper_lock_preview = new He.ContentBlockImage ("") {
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

        // Color scheme section
        setup_color_scheme_ui ();

        // Accent colors section
        setup_accent_colors_ui ();

        // Other UI sections
        setup_contrast_ui ();
        setup_roundness_ui ();

        // Main layout
        setup_main_layout ();

        // Load wallpaper paths asynchronously
        load_wallpaper_paths_async.begin ();
    }

    private void setup_color_scheme_ui () {
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

        // Connect signals
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
        interface_settings.notify["color-scheme"].connect (() => {
            color_scheme_refresh ();
        });
    }

    private void setup_accent_colors_ui () {
        purple = new AccentColorButton ("purple");
        purple.tooltip_text = _("Purple");

        pink = new AccentColorButton ("pink", purple);
        pink.tooltip_text = _("Pink");

        red = new AccentColorButton ("red", purple);
        red.tooltip_text = _("Red");

        yellow = new AccentColorButton ("yellow", purple);
        yellow.tooltip_text = _("Yellow");

        green = new AccentColorButton ("green", purple);
        green.tooltip_text = _("Green");

        blue = new AccentColorButton ("blue", purple);
        blue.tooltip_text = _("Blue");

        multi = new AccentColorButton ("multi", purple);
        multi.tooltip_text = _("Set By Apps");

        accent_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.START,
            homogeneous = true,
            hexpand = true
        };
        accent_box.append (multi);
        accent_box.append (purple);
        accent_box.append (pink);
        accent_box.append (red);
        accent_box.append (yellow);
        accent_box.append (green);
        accent_box.append (blue);

        wallpaper_type_button = new Gtk.ToggleButton () {
            active = fusebox_appearance_settings.get_boolean ("wallpaper-accent") == true,
            label = _("Wallpaper Colors")
        };

        basic_type_button = new Gtk.ToggleButton () {
            label = _("Basic Colors"),
            group = wallpaper_type_button
        };

        color_type_button = new He.SegmentedButton () {
            hexpand = true,
            homogeneous = true
        };
        color_type_button.add_css_class ("pill-segment");
        color_type_button.append (wallpaper_type_button);
        color_type_button.append (basic_type_button);

        color_sw = new Gtk.ScrolledWindow () {
            height_request = 88,
            vscrollbar_policy = Gtk.PolicyType.NEVER
        };

        color_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
            transition_duration = 400
        };
        color_stack.add_titled (accent_box, "basic", "Basic Colors");
        color_stack.add_titled (color_sw, "wallpaper", "Wallpaper Colors");

        // Set initial state without expensive operations
        if (wallpaper_type_button.active) {
            color_stack.set_visible_child_name ("wallpaper");
            accent_box.sensitive = false;
        } else {
            color_stack.set_visible_child_name ("basic");
            accent_box.sensitive = true;
            multi.set_active (true);
        }

        // Connect signals
        basic_type_button.toggled.connect (() => {
            color_stack.set_visible_child_name ("basic");
            fusebox_appearance_settings.set_boolean ("wallpaper-accent", false);
            accent_box.sensitive = true;
            multi.set_active (true);
        });

        wallpaper_type_button.toggled.connect (() => {
            color_stack.set_visible_child_name ("wallpaper");
            fusebox_appearance_settings.set_boolean ("wallpaper-accent", true);
            accent_box.sensitive = false;

            // Trigger async accent setup if not done yet
            if (!accent_setup_completed) {
                accent_setup_async.begin ();
            } else {
                update_wallpaper_accent_selection ();
            }
        });
    }

    private void setup_contrast_ui () {
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
    }

    private void setup_roundness_ui () {
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

        tau_appearance_settings.bind ("roundness", roundness_adjustment, "value", SettingsBindFlags.GET);

        // Debounced setting updates
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
    }

    private void setup_main_layout () {
        // Setup main layout structure
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_start = 18,
            margin_end = 18,
            margin_bottom = 18
        };

        sw = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };
        sw.set_child (main_box);

        // Continue with existing layout setup...
        orientation = Gtk.Orientation.VERTICAL;
        // append (contrast_stack); // Add your final widget here
    }

    // Async wallpaper path loading
    private async void load_wallpaper_paths_async () {
        try {
            string wallpaper_uri = bg_settings.get_string ("picture-uri");
            string lock_wallpaper_uri = bg_settings.get_string ("picture-uri-dark"); // or appropriate key

            // Update previews with actual paths
            wallpaper_preview.file = wallpaper_uri;
            wallpaper_lock_preview.file = lock_wallpaper_uri;
        } catch (Error e) {
            warning ("Failed to load wallpaper paths: %s", e.message);
        }
    }

    // NON-BLOCKING async accent setup
    public async void accent_setup_async () {
        if (accent_setup_completed) {
            return;
        }

        try {
            string wallpaper_uri = bg_settings.get_string ("picture-uri");
            GLib.File file = File.new_for_uri (wallpaper_uri);

            // Load pixbuf asynchronously
            Gdk.Pixbuf? pixbuf = yield load_pixbuf_async (file);

            if (pixbuf == null) {
                return;
            }

            // Process pixels asynchronously without blocking
            GLib.Array<int?> result = yield He.Ensor.accent_from_pixels_async (pixbuf.get_pixels_with_length (),
                pixbuf.get_has_alpha ());

            int[] argb_ints = {};
            for (int i = 0; i < result.length; i++) {
                var value = result.index (i);
                if (value != null) {
                    argb_ints += value;
                }
            }

            // Update UI on main thread
            ensor_flowbox = new EnsorFlowBox (argb_ints);
            color_sw.set_child (ensor_flowbox);

            var sel = ((int) Math.floor (fusebox_appearance_settings.get_int ("wallpaper-accent-choice") / 4));
            if (sel < argb_ints.length) {
                tau_appearance_settings.set_string ("accent-color", He.hexcode_argb (argb_ints[sel]));
            }

            accent_setup_completed = true;

            // Update selection if wallpaper accent is active
            if (wallpaper_type_button.active) {
                update_wallpaper_accent_selection ();
            }
        } catch (Error e) {
            warning ("Accent setup failed: %s", e.message);
        }
    }

    private async Gdk.Pixbuf? load_pixbuf_async (GLib.File file) {
        try {
            // Use async file operations
            uint8[] contents;
            yield file.load_contents_async (null, out contents, null);

            var stream = new MemoryInputStream.from_data (contents);
            return yield new Gdk.Pixbuf.from_stream_async (stream);
        } catch (Error e) {
            warning ("Failed to load pixbuf: %s", e.message);
            return null;
        }
    }

    private void update_wallpaper_accent_selection () {
        if (ensor_flowbox == null) {
            return;
        }

        var sel = fusebox_appearance_settings.get_int ("wallpaper-accent-choice");
        var child = ensor_flowbox.flowbox.get_child_at_index (sel);
        if (child != null) {
            ensor_flowbox.flowbox.select_child (child);

            var mode_button = ((EnsorModeButton) child.get_child ());
            var sels = ((int) Math.floor (sel / 4));
            if (sels < mode_button.colors.size) {
                tau_appearance_settings.set_string ("accent-color", He.hexcode_argb (mode_button.colors.get (sels)));
            }
        }

        // Reset other accent buttons
        multi.set_active (false);
        red.set_active (false);
        yellow.set_active (false);
        green.set_active (false);
        blue.set_active (false);
        purple.set_active (false);
        pink.set_active (false);
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
}
