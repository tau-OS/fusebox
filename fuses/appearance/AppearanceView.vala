public class AppearanceView : Gtk.Box {
    private static GLib.Settings interface_settings;
    private static GLib.Settings tau_appearance_settings;
    private static GLib.Settings fusebox_appearance_settings;
    private static GLib.Settings bg_settings;

    public Fusebox.Fuse fuse { get; construct set; }

    private He.SegmentedButton color_type_button;
    private Gtk.ToggleButton basic_type_button;
    private Gtk.Stack color_stack;
    private Bis.Carousel color_carousel;
    private PrefersAccentColorButton red;
    private PrefersAccentColorButton yellow;
    private PrefersAccentColorButton green;
    private PrefersAccentColorButton blue;
    private PrefersAccentColorButton purple;
    private PrefersAccentColorButton pink;
    private PrefersAccentColorButton multi;
    private Gtk.FlowBoxChild defavlt; // default is a Vala keyword, deal with it
    private Gtk.FlowBoxChild muted;
    private Gtk.FlowBoxChild vibrant;
    private Gtk.FlowBoxChild salad;
    private Gtk.CheckButton prefer_light_radio;
    private Gtk.CheckButton prefer_default_radio;
    private Gtk.CheckButton prefer_dark_radio;
    private Gtk.Box accent_box;
    private Gtk.FlowBox ensor_flowbox;
    private Gtk.FlowBoxChild current_emb;

    public He.ContentBlockImage wallpaper_preview;
    public He.ContentBlockImage wallpaper_lock_preview;
    public Appearance.WallpaperGrid wallpaper_view;
    public Gtk.ToggleButton wallpaper_type_button;
    public Gtk.ScrolledWindow sw;
    public Gtk.Stack contrast_stack;
    public Gtk.Stack wallpaper_stack;
    public Gtk.Stack main_stack;

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
        // var edit_button = new He.Button ("document-edit-symbolic", "") {
        //  hexpand = true,
        //  vexpand = true,
        //  halign = Gtk.Align.END,
        //  valign = Gtk.Align.END,
        //  margin_end = 12,
        //  margin_bottom = 12,
        //  is_disclosure = true,
        //  tooltip_text = _("Customize Lock Screen…")
        // };

        // var wallpaper_lock_button_overlay = new Gtk.Overlay ();
        // wallpaper_lock_button_overlay.set_child (wallpaper_lock_preview_overlay);
        // wallpaper_lock_button_overlay.add_overlay (edit_button);

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

        // Accent Block
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

        multi = new PrefersAccentColorButton ("multi", "", purple);
        multi.tooltip_text = _("Set By Apps");

        accent_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
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

        defavlt = new Gtk.FlowBoxChild ();
        defavlt.child = new EnsorModeButton ("default");
        defavlt.tooltip_text = _("Default Scheme");
        muted = new Gtk.FlowBoxChild ();
        muted.child = new EnsorModeButton ("muted");
        muted.tooltip_text = _("Muted Scheme");
        vibrant = new Gtk.FlowBoxChild ();
        vibrant.child = new EnsorModeButton ("vibrant");
        vibrant.tooltip_text = _("Vibrant Scheme");
        salad = new Gtk.FlowBoxChild ();
        salad.child = new EnsorModeButton ("salad");
        salad.tooltip_text = _("Fruit Salad Scheme");

        ensor_flowbox = new Gtk.FlowBox () {
            hexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            column_spacing = 12,
            homogeneous = true,
            min_children_per_line = 4,
            max_children_per_line = 4
        };
        ensor_flowbox.add_css_class ("ensor-box");
        ensor_flowbox.append (defavlt);
        ensor_flowbox.append (muted);
        ensor_flowbox.append (vibrant);
        ensor_flowbox.append (salad);
        ensor_flowbox.child_activated.connect (child_activated_cb);

        ensor_refresh ();
        tau_appearance_settings.notify["changed::ensor-scheme"].connect (() => {
            ensor_refresh ();
        });

        wallpaper_type_button = new Gtk.ToggleButton () {
            active = fusebox_appearance_settings.get_boolean ("wallpaper-accent") == true
        };
        wallpaper_type_button.label = "Wallpaper Colors";
        basic_type_button = new Gtk.ToggleButton ();
        basic_type_button.label = "Basic Colors";
        basic_type_button.group = wallpaper_type_button;

        color_type_button = new He.SegmentedButton () {
            hexpand = true,
            homogeneous = true
        };
        color_type_button.add_css_class ("pill-segment");
        color_type_button.append (wallpaper_type_button);
        color_type_button.append (basic_type_button);

        color_carousel = new Bis.Carousel ();
        color_carousel.append (ensor_flowbox);

        color_stack = new Gtk.Stack ();
        color_stack.add_titled (accent_box, "basic", "Basic Colors");
        color_stack.add_titled (color_carousel, "wallpaper", "Wallpaper Colors");

        if (wallpaper_type_button.active) {
            color_stack.set_visible_child_name ("wallpaper");
            accent_setup.begin ();
            accent_box.sensitive = false;

            multi.set_active (false);
            red.set_active (false);
            yellow.set_active (false);
            green.set_active (false);
            blue.set_active (false);
            purple.set_active (false);
            pink.set_active (false);
        } else {
            color_stack.set_visible_child_name ("basic");
            select_ensor (defavlt);
            accent_box.sensitive = true;
        }

        basic_type_button.toggled.connect (() => {
            color_stack.set_visible_child_name ("basic");
            fusebox_appearance_settings.set_boolean ("wallpaper-accent", false);
            select_ensor (defavlt);
            accent_box.sensitive = true;
        });
        wallpaper_type_button.toggled.connect (() => {
            color_stack.set_visible_child_name ("wallpaper");
            fusebox_appearance_settings.set_boolean ("wallpaper-accent", true);
            accent_setup.begin ();
            accent_box.sensitive = false;

            multi.set_active (false);
            red.set_active (false);
            yellow.set_active (false);
            green.set_active (false);
            blue.set_active (false);
            purple.set_active (false);
            pink.set_active (false);
        });

        tau_appearance_settings.notify["changed::accent-color"].connect (() => {
            accent_setup.begin ();
        });

        // Contrast Block
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

        // Roundness Block
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

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_start = 18,
            margin_end = 18,
            margin_bottom = 18
        };
        main_box.append (wallpaper_main_box);
        main_box.append (color_type_button);
        main_box.append (color_stack);

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

        // Contrast View
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

                if (result.index (0) != null) {
                    int[] argb_ints = { result.index (0) };
                    ColorGenerator color_gen = new ColorGenerator (argb_ints);
                    Gee.ArrayList<int> resd = color_gen.get_generated_colors (He.SchemeVariant.DEFAULT);
                    ((EnsorModeButton)defavlt.get_first_child ()).colors = resd;
                    Gee.ArrayList<int> resm = color_gen.get_generated_colors (He.SchemeVariant.MUTED);
                    ((EnsorModeButton)muted.get_first_child ()).colors = resm;
                    Gee.ArrayList<int> resv = color_gen.get_generated_colors (He.SchemeVariant.VIBRANT);
                    ((EnsorModeButton)vibrant.get_first_child ()).colors = resv;
                    Gee.ArrayList<int> ress = color_gen.get_generated_colors (He.SchemeVariant.SALAD);
                    ((EnsorModeButton)salad.get_first_child ()).colors = ress;

                    tau_appearance_settings.set_string ("accent-color", He.hexcode_argb (result.index (0)));
                }
                if (result.index (1) != null) {
                    int[] argb_ints = { result.index (0), result.index (1) };
                    ColorGenerator color_gen = new ColorGenerator (argb_ints);
                    Gee.ArrayList<int> resd = color_gen.get_generated_colors (He.SchemeVariant.DEFAULT);
                    ((EnsorModeButton)defavlt.get_first_child ()).colors = resd;
                    Gee.ArrayList<int> resm = color_gen.get_generated_colors (He.SchemeVariant.MUTED);
                    ((EnsorModeButton)muted.get_first_child ()).colors = resm;
                    Gee.ArrayList<int> resv = color_gen.get_generated_colors (He.SchemeVariant.VIBRANT);
                    ((EnsorModeButton)vibrant.get_first_child ()).colors = resv;
                    Gee.ArrayList<int> ress = color_gen.get_generated_colors (He.SchemeVariant.SALAD);
                    ((EnsorModeButton)salad.get_first_child ()).colors = ress;
                }
                if (result.index (1) != null && result.index (2) != null) {
                    int[] argb_ints = { result.index (0), result.index (1), result.index (2) };
                    ColorGenerator color_gen = new ColorGenerator (argb_ints);
                    Gee.ArrayList<int> resd = color_gen.get_generated_colors (He.SchemeVariant.DEFAULT);
                    ((EnsorModeButton)defavlt.get_first_child ()).colors = resd;
                    Gee.ArrayList<int> resm = color_gen.get_generated_colors (He.SchemeVariant.MUTED);
                    ((EnsorModeButton)muted.get_first_child ()).colors = resm;
                    Gee.ArrayList<int> resv = color_gen.get_generated_colors (He.SchemeVariant.VIBRANT);
                    ((EnsorModeButton)vibrant.get_first_child ()).colors = resv;
                    Gee.ArrayList<int> ress = color_gen.get_generated_colors (He.SchemeVariant.SALAD);
                    ((EnsorModeButton)salad.get_first_child ()).colors = ress;
                }
                if (result.index (1) != null && result.index (2) != null && result.index (3) != null) {
                    int[] argb_ints = { result.index (0), result.index (1), result.index (2), result.index (3) };
                    ColorGenerator color_gen = new ColorGenerator (argb_ints);
                    Gee.ArrayList<int> resd = color_gen.get_generated_colors (He.SchemeVariant.DEFAULT);
                    ((EnsorModeButton)defavlt.get_first_child ()).colors = resd;
                    Gee.ArrayList<int> resm = color_gen.get_generated_colors (He.SchemeVariant.MUTED);
                    ((EnsorModeButton)muted.get_first_child ()).colors = resm;
                    Gee.ArrayList<int> resv = color_gen.get_generated_colors (He.SchemeVariant.VIBRANT);
                    ((EnsorModeButton)vibrant.get_first_child ()).colors = resv;
                    Gee.ArrayList<int> ress = color_gen.get_generated_colors (He.SchemeVariant.SALAD);
                    ((EnsorModeButton)salad.get_first_child ()).colors = ress;
                }

                loop.quit ();
            });
            loop.run ();
        } catch (Error e) {
            print (e.message);
        }
    }

    private void child_activated_cb (Gtk.FlowBoxChild child) {
        select_ensor (child);
    }

    private void select_ensor (Gtk.FlowBoxChild emb) {
        current_emb = emb;
        _ensor = ((EnsorModeButton)emb.get_first_child ()).mode;
        tau_appearance_settings.set_string ("ensor-scheme", _ensor);
        ensor_flowbox.select_child (current_emb);
    }

    private void ensor_refresh () {
        string value = tau_appearance_settings.get_string ("ensor-scheme");

        if (value == "default") {
            select_ensor (defavlt);
        } else if (value == "muted") {
            select_ensor (muted);
        } else if (value == "vibrant") {
            select_ensor (vibrant);
        } else if (value == "salad") {
            select_ensor (salad);
        }
    }

    private class EnsorModeButton : Gtk.Box {
        public string mode { get; construct; }
        public Gee.ArrayList<int> colors;

        public EnsorModeButton (string mode) {
            Object (
                mode: mode
            );
            overflow = HIDDEN;
            add_css_class ("circle-radius");
        }

        public override void snapshot (Gtk.Snapshot snapshot) {
            int w = get_width ();
            int h = get_height ();

            float r = 999;

            snapshot.translate ({ w / 2, h / 2 });

            Gsk.RoundedRect rect = {};
            rect.init_from_rect ({ { -r, -r }, { r* 2, r* 2 } }, r);
            snapshot.push_rounded_clip (rect);
            snapshot.append_color (color_to_rgba (0), { { -r, -r }, { r, r } });
            snapshot.append_color (color_to_rgba (1), { { -r, 0 }, { r, r } });
            snapshot.append_color (color_to_rgba (2), { { 0, 0 }, { r, r } });
            snapshot.append_color (color_to_rgba (3), { { 0, -r }, { r, r } });
            snapshot.pop ();
            snapshot.append_inset_shadow (rect, { 0, 0, 0 }, 0, 0, 1, 0);
        }

        private Gdk.RGBA color_to_rgba (int index) {
            int rgb = colors.get (index);
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
                    color : color,
                    hex: hex,
                    group: group_member
            );
        }

        construct {
            add_css_class (color.to_string ());
            add_css_class ("accent-mode");

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
}
