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
    private EnsorModeButton defavlt; // default is a Vala keyword, deal with it
    private EnsorModeButton muted;
    private EnsorModeButton vibrant;
    private EnsorModeButton monochrome;
    private EnsorModeButton salad;
    private Gtk.ToggleButton prefer_light_radio;
    private Gtk.ToggleButton prefer_default_radio;
    private Gtk.ToggleButton prefer_dark_radio;
    private Gtk.Box accent_box;
    public He.ContentBlockImage wallpaper_preview;
    public Fusebox.Fuse fuse { get; construct set; }
    public Appearance.WallpaperGrid wallpaper_view;
    public He.Switch accent_switch;
    public He.Switch contrast_switch;
    public Gtk.ScrolledWindow sw;
    public Gtk.Label wallpaper_details_label;
    public Gtk.Label wallpaper_details_sublabel;
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

        var wallpaper_label = new Gtk.Label (_("Wallpaper")) {
            halign = Gtk.Align.START
        };
        wallpaper_label.add_css_class ("cb-title");
        var wallpaper_sublabel = new Gtk.Label (_("Change desktop background picture")) {
            halign = Gtk.Align.START
        };
        wallpaper_sublabel.add_css_class ("cb-subtitle");

        wallpaper_details_label = new Gtk.Label ("") {
            halign = Gtk.Align.START
        };
        wallpaper_details_label.add_css_class ("cb-title");

        wallpaper_details_label.label = wallpaper_view.wallpaper_title;

        wallpaper_details_sublabel = new Gtk.Label ("") {
            halign = Gtk.Align.START
        };
        wallpaper_details_sublabel.add_css_class ("cb-subtitle");

        wallpaper_details_sublabel.label = wallpaper_view.wallpaper_subtitle;

        wallpaper_preview = new He.ContentBlockImage (wallpaper_view.current_wallpaper_path) {
            requested_height = 150,
            requested_width = 230
        };

        var wallpaper_details_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            vexpand = true,
            valign = Gtk.Align.CENTER
        };
        wallpaper_details_box.append (wallpaper_details_label);
        wallpaper_details_box.append (wallpaper_details_sublabel);

        var wallpaper_preview_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 24);
        wallpaper_preview_box.append (wallpaper_preview);
        wallpaper_preview_box.append (wallpaper_details_box);

        var wallpaper_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        wallpaper_box.append (wallpaper_label);
        wallpaper_box.append (wallpaper_sublabel);

        var wallpaper_grid_button = new He.IconicButton ("pan-end-symbolic") {
            hexpand = true,
            vexpand = true,
            halign = Gtk.Align.END,
            valign = Gtk.Align.START
        };

        var wallpaper_header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 24);
        wallpaper_header_box.append (wallpaper_box);
        wallpaper_header_box.append (wallpaper_grid_button);

        var wallpaper_main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        wallpaper_main_box.append (wallpaper_header_box);
        wallpaper_main_box.append (wallpaper_preview_box);
        wallpaper_main_box.add_css_class ("mini-content-block");

        // Color Scheme Block
        var prefer_label = new Gtk.Label (_("Color Scheme")) {
            halign = Gtk.Align.START
        };
        prefer_label.add_css_class ("cb-title");
        var prefer_sublabel = new Gtk.Label (_("Applies to windows, panels and other places")) {
            halign = Gtk.Align.START
        };
        prefer_sublabel.add_css_class ("cb-subtitle");

        var prefer_default_image = new He.ContentBlockImage ("resource:///com/fyralabs/Fusebox/Appearance/by-apps.svg") {
            requested_width = 128,
            requested_height = 128,
            valign = Gtk.Align.START
        };
        prefer_default_image.add_css_class ("large-radius");

        var prefer_default_card = new Gtk.Grid ();
        prefer_default_card.attach (prefer_default_image, 0, 0);

        var prefer_default_grid = new Gtk.Grid () {
            row_spacing = 6,
            halign = Gtk.Align.START
        };
        prefer_default_grid.attach (prefer_default_card, 0, 0);
        prefer_default_grid.attach (new Gtk.Label (_("Auto")) {
            css_classes = {"caption"},
            halign = Gtk.Align.START
        }, 0, 1);

        prefer_default_radio = new Gtk.ToggleButton () {
            hexpand = true,
            tooltip_text = _("Apps will choose their own color scheme.")
        };
        prefer_default_radio.add_css_class ("image-button");
        prefer_default_radio.add_css_class ("flat");
        prefer_default_radio.add_css_class ("color-scheme-button");
        prefer_default_radio.child = (prefer_default_grid);

        var prefer_light_image = new He.ContentBlockImage ("resource:///com/fyralabs/Fusebox/Appearance/light.svg") {
            requested_width = 128,
            requested_height = 128,
            valign = Gtk.Align.START
        };
        prefer_light_image.add_css_class ("large-radius");

        var prefer_light_card = new Gtk.Grid ();
        prefer_light_card.attach (prefer_light_image, 0, 0);

        var prefer_light_grid = new Gtk.Grid () {
            row_spacing = 6,
            halign = Gtk.Align.START
        };
        prefer_light_grid.attach (prefer_light_card, 0, 0);
        prefer_light_grid.attach (new Gtk.Label (_("Light")) {
            css_classes = {"caption"},
            halign = Gtk.Align.START
        }, 0, 1);

        prefer_light_radio = new Gtk.ToggleButton () {
            group = prefer_default_radio,
            tooltip_text = _("Apps will all be light-colored."),
            hexpand = true
        };
        prefer_light_radio.add_css_class ("image-button");
        prefer_light_radio.add_css_class ("flat");
        prefer_light_radio.add_css_class ("color-scheme-button");
        prefer_light_radio.child = (prefer_light_grid);

        var dark_image = new He.ContentBlockImage ("resource:///com/fyralabs/Fusebox/Appearance/dark.svg") {
            requested_width = 128,
            requested_height = 128,
            valign = Gtk.Align.START
        };
        dark_image.add_css_class ("large-radius");

        var dark_card = new Gtk.Grid ();
        dark_card.attach (dark_image, 0, 0);

        var dark_grid = new Gtk.Grid () {
            row_spacing = 6,
            halign = Gtk.Align.START
        };
        dark_grid.attach (dark_card, 0, 0);
        dark_grid.attach (new Gtk.Label (_("Dark")) {
            css_classes = {"caption"},
            halign = Gtk.Align.START
        }, 0, 1);

        prefer_dark_radio = new Gtk.ToggleButton () {
            group = prefer_default_radio,
            tooltip_text = _("Apps will all be dark-colored."),
            hexpand = true
        };
        prefer_dark_radio.add_css_class ("image-button");
        prefer_dark_radio.add_css_class ("flat");
        prefer_dark_radio.add_css_class ("color-scheme-button");
        prefer_dark_radio.child = (dark_grid);

        var prefer_style_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 24) {
            hexpand = true,
            halign = Gtk.Align.START
        };
        prefer_style_box.append (prefer_light_radio);
        prefer_style_box.append (prefer_dark_radio);
        prefer_style_box.append (prefer_default_radio);

        var prefer_label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        prefer_label_box.append (prefer_label);
        prefer_label_box.append (prefer_sublabel);

        var prefer_main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 18);
        prefer_main_box.append (prefer_label_box);
        prefer_main_box.append (prefer_style_box);

        var prefer_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        prefer_box.append (prefer_main_box);

        var grid = new Gtk.Grid () {
            row_spacing = 24,
            margin_bottom = 18,
            vexpand = true,
            valign = Gtk.Align.START
        };

        var accent_label = new Gtk.Label (_("Accent color")) {
            halign = Gtk.Align.START
        };
        accent_label.add_css_class ("cb-title");

        purple = new PrefersAccentColorButton ("purple");
        purple.tooltip_text = _("Purple");

        pink = new PrefersAccentColorButton ("pink", purple);
        pink.tooltip_text = _("Pink");

        red = new PrefersAccentColorButton ("red", purple);
        red.tooltip_text = _("Red");

        yellow = new PrefersAccentColorButton ("yellow", purple);
        yellow.tooltip_text = _("Yellow");

        green = new PrefersAccentColorButton ("green", purple);
        green.tooltip_text = _("Green");

        blue = new PrefersAccentColorButton ("blue", purple);
        blue.tooltip_text = _("Blue");

        mono = new PrefersAccentColorButton ("mono", purple);
        mono.tooltip_text = _("Mono");

        multi = new PrefersAccentColorButton ("multi", purple);
        multi.tooltip_text = _("Set By Apps");

        var accentw_label = new Gtk.Label (_("Wallpaper color")) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        accentw_label.add_css_class ("cb-title");

        accent_switch = new He.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };

        var wallpaper_accent_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        wallpaper_accent_box.append (accentw_label);
        wallpaper_accent_box.append (accent_switch);

        var contrast_label = new Gtk.Label (_("High contrast")) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        contrast_label.add_css_class ("cb-title");

        contrast_switch = new He.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };

        var contrast_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        contrast_box.append (contrast_label);
        contrast_box.append (contrast_switch);

        accent_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            homogeneous = true,
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

        var accent_main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        accent_main_box.append (accent_label);
        accent_main_box.append (accent_box);

        var ensor_label = new Gtk.Label (_("Accent scheme")) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        ensor_label.add_css_class ("cb-title");

        var ensor_info = new Gtk.Image () {
            icon_name = "dialog-information-symbolic",
            tooltip_text = _("The accent color engine sets user interface color tones based on scheme choice.")
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
            column_spacing = 12,
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

        var roundness_label = new Gtk.Label (_("UI Roundness")) {
            halign = Gtk.Align.START
        };
        roundness_label.add_css_class ("cb-title");

        var roundness_info = new Gtk.Image () {
            icon_name = "dialog-information-symbolic",
            tooltip_text = _("Change how round elements are based on this choice.")
        };

        var roundness_adjustment = new Gtk.Adjustment (-1, 0.0, 2.0, 0.5, 0, 0);

        var roundness_scale = new He.Slider () {
            hexpand = true
        };
        roundness_scale.scale.orientation = Gtk.Orientation.HORIZONTAL;
        roundness_scale.scale.adjustment = roundness_adjustment;
        roundness_scale.scale.draw_value = true;
        roundness_scale.scale.value_pos = Gtk.PositionType.LEFT;
        roundness_scale.add_mark (0.5, null);
        roundness_scale.add_mark (1.0, null);
        roundness_scale.add_mark (1.5, null);
        roundness_scale.left_icon = "no-round-symbolic";
        roundness_scale.right_icon = "round-symbolic";

        var roundness_control_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        roundness_control_box.append (roundness_scale);

        var roundness_title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        roundness_title_box.append (roundness_label);
        roundness_title_box.append (roundness_info);

        var roundness_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        roundness_box.append (roundness_title_box);
        roundness_box.append (roundness_control_box);

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

        grid.attach (prefer_box, 0, 0);
        grid.attach (accent_main_box, 0, 1);
        grid.attach (wallpaper_accent_box, 0, 2);
        grid.attach (ensor_main_box, 0, 3);
        grid.attach (contrast_box, 0, 4);
        grid.attach (roundness_box, 0, 5);
        grid.add_css_class ("mini-content-block");

        fusebox_appearance_settings.bind ("wallpaper-accent", accent_switch.iswitch, "active", SettingsBindFlags.DEFAULT);
        fusebox_appearance_settings.bind("wallpaper-accent", accent_box, "sensitive", SettingsBindFlags.INVERT_BOOLEAN);

        accent_switch.iswitch.state_set.connect (() => {
            if (accent_switch.iswitch.active) {
                accent_box.sensitive = false;

                multi.set_active (false);
                red.set_active (false);
                yellow.set_active (false);
                green.set_active (false);
                blue.set_active (false);
                purple.set_active (false);
                pink.set_active (false);

                accent_set.begin ();
            } else {
                multi.set_active (true);
                accent_box.sensitive = true;
            }
            return Gdk.EVENT_PROPAGATE;
        });

        contrast_switch.iswitch.state_set.connect (() => {
            if (contrast_switch.iswitch.active) {
                set_contrast_scheme (He.Desktop.ContrastScheme.HIGH);
            } else {
                set_contrast_scheme (He.Desktop.ContrastScheme.DEFAULT);
            }
            return Gdk.EVENT_PROPAGATE;
        });

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            margin_start = 18,
            margin_end = 18
        };
        main_box.append (wallpaper_main_box);
        main_box.append (grid);

        sw = new Gtk.ScrolledWindow ();
        sw.hscrollbar_policy = (Gtk.PolicyType.NEVER);
        sw.set_child (main_box);

        var wmain_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            margin_start = 18,
            margin_end = 18
        };
        wmain_box.append (wallpaper_view);

        var wsw = new Gtk.ScrolledWindow ();
        wsw.hscrollbar_policy = (Gtk.PolicyType.NEVER);
        wsw.set_child (wmain_box);

        var window_view = new Appearance.WindowView ();
        var text_view = new Appearance.TextView ();

        var main_stack = new Gtk.Stack () {
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
            margin_bottom = 12,
            viewtitle_widget = stack_switcher
        };

        var wallpaper_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
            transition_duration = 400
        };
        wallpaper_stack.add_titled (main_stack, "appearance", _("Appearance"));
        wallpaper_stack.add_titled (wsw, "wallpaper", _("Wallpaper"));

        var wallpaper_mlabel = new Gtk.Label (_("Wallpaper")) {
            halign = Gtk.Align.START,
            css_classes = {"view-title"}
        };

        wallpaper_grid_button.clicked.connect (() => {
            wallpaper_stack.set_visible_child (wsw);
            appbar.show_back = true;
            appbar.viewtitle_widget.unparent ();
            appbar.viewtitle_widget = wallpaper_mlabel;
        });

        appbar.back_button.clicked.connect (() => {
            wallpaper_stack.set_visible_child (main_stack);
            appbar.show_back = false;
            appbar.viewtitle_widget.unparent ();
            appbar.viewtitle_widget = stack_switcher;
        });

        orientation = Gtk.Orientation.VERTICAL;
        append (appbar);
        append (wallpaper_stack);

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

        contrast_refresh ();
        tau_appearance_settings.notify["changed::contrast"].connect (() => {
            contrast_refresh ();
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

    private void set_contrast_scheme (He.Desktop.ContrastScheme contrast_scheme) {
        tau_appearance_settings.set_enum ("contrast", contrast_scheme);
    }

    private void contrast_refresh () {
        int value = tau_appearance_settings.get_enum ("contrast");

        if (value == He.Desktop.ContrastScheme.DEFAULT) {
            contrast_switch.iswitch.active = false;
        } else if (value == He.Desktop.ContrastScheme.HIGH) {
            contrast_switch.iswitch.active = true;
        } else if (value == He.Desktop.ContrastScheme.LOW) {
            contrast_switch.iswitch.active = false;
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
                    }
                });
            });
        }
    }
}
