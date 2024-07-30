public class Appearance.ContrastView : Gtk.Box {
    public Fusebox.Fuse fuse { get; construct set; }
    public AppearanceView appearance_view { get; construct set; }
    private Gtk.Box contrast_preview;

    private static GLib.Settings tau_appearance_settings;

    public Gtk.ToggleButton contrast_button_1;
    public Gtk.ToggleButton contrast_button_2;
    public Gtk.ToggleButton contrast_button_3;
    public Gtk.ToggleButton contrast_button_4;
    public He.AppBar cappbar;

    static construct {
        tau_appearance_settings = new GLib.Settings ("com.fyralabs.desktop.appearance");
    }

    public ContrastView (Fusebox.Fuse _fuse, AppearanceView _appearance_view) {
        Object (fuse: _fuse, appearance_view: _appearance_view);
    }

    construct {
        var contrast_mlabel = new He.ViewTitle () {
            label = (_("Contrast"))
        };

        cappbar = new He.AppBar () {
            show_back = true,
            show_left_title_buttons = false,
            show_right_title_buttons = true,
            viewtitle_widget = contrast_mlabel
        };

        var contrast_info = new Gtk.Label (_("Higher contrast makes text, buttons and icons stand out more. Choose the contrast that looks best for you.")) {
            xalign = 0,
            lines = 2,
            max_width_chars = 45,
            ellipsize = Pango.EllipsizeMode.END,
            hexpand = true,
            halign = Gtk.Align.START
        };

        var contrast_preview_label = new He.ViewTitle () {
            label = (_("View"))
        };
        var contrast_preview_bar = new He.AppBar () {
            can_target = false,
            viewtitle_widget = contrast_preview_label
        };
        var contrast_preview_box = new He.MiniContentBlock () {
            title = _("Title"),
            subtitle = _("Subtitle"),
            can_target = false,
            margin_start = margin_end = 18
        };
        var contrast_preview_button = new He.Button (null, _("Action")) {
            can_target = false,
            is_pill = true
        };
        contrast_preview_box.primary_button = (contrast_preview_button);
        var contrast_preview_mbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            margin_bottom = 24,
            margin_top = 24,
            margin_start = 48,
            margin_end = 48
        };
        contrast_preview_mbox.append (contrast_preview_bar);
        contrast_preview_mbox.append (contrast_preview_box);
        contrast_preview_mbox.add_css_class ("medium-radius");
        contrast_preview_mbox.add_css_class ("surface-bg-color");
        var contrast_preview_overlay_button = new He.OverlayButton ("list-add-symbolic", null, null) {
            typeb = He.OverlayButton.TypeButton.PRIMARY,
            can_target = false,
            vexpand = false,
            margin_top = 64
        };
        contrast_preview_mbox.append (contrast_preview_overlay_button);
        contrast_preview = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
        };
        contrast_preview.add_css_class ("circle-radius");
        contrast_preview.add_css_class ("surface-container-bg-color");
        contrast_preview.append (contrast_preview_mbox);

        contrast_button_2 = new Gtk.ToggleButton () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            child = new He.ButtonContent () {
                label = "Default",
                icon = "eye-open-negative-filled-symbolic"
            }
        };
        contrast_button_1 = new Gtk.ToggleButton () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            group = contrast_button_2,
            child = new He.ButtonContent () {
                label = "Low",
                icon = "eye-open-negative-filled-symbolic"
            }
        };
        contrast_button_3 = new Gtk.ToggleButton () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            group = contrast_button_2,
            child = new He.ButtonContent () {
                label = "Medium",
                icon = "eye-open-negative-filled-symbolic"
            }
        };
        contrast_button_4 = new Gtk.ToggleButton () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            group = contrast_button_2,
            child = new He.ButtonContent () {
                label = "High",
                icon = "eye-open-negative-filled-symbolic"
            }
        };

        var contrast_seg_button = new He.SegmentedButton () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };
        contrast_seg_button.append (contrast_button_1);
        contrast_seg_button.append (contrast_button_2);
        contrast_seg_button.append (contrast_button_3);
        contrast_seg_button.append (contrast_button_4);

        var contrast_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        contrast_box.append (contrast_seg_button);
        contrast_box.add_css_class ("mini-content-block");

        var contrast_info_image = new Gtk.Image () {
            icon_name = "dialog-information-symbolic",
            pixel_size = 24
        };

        var contrast_info_label = new Gtk.Label (_("Some apps may not support all color and text contrast settings."));

        var contrast_info_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        contrast_info_box.append (contrast_info_image);
        contrast_info_box.append (contrast_info_label);

        var contrast_main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            spacing = 12,
            hexpand = true,
            margin_start = 18,
            margin_end = 18
        };
        contrast_main_box.append (contrast_info);
        contrast_main_box.append (contrast_preview);
        contrast_main_box.append (contrast_box);
        contrast_main_box.append (contrast_info_box);

        var csw = new Gtk.ScrolledWindow () {
            vexpand = true,
            margin_bottom = 18
        };
        csw.hscrollbar_policy = (Gtk.PolicyType.NEVER);
        csw.set_child (contrast_main_box);

        this.append (cappbar);
        this.append (csw);
        this.orientation = Gtk.Orientation.VERTICAL;

        cappbar.back_button.clicked.connect (() => {
            appearance_view.contrast_stack.set_visible_child_name ("appearance");
        });

        contrast_button_1.toggled.connect (() => {
            on_contrast_button_toggled (contrast_button_1);
        });
        contrast_button_2.toggled.connect (() => {
            on_contrast_button_toggled (contrast_button_2);
        });
        contrast_button_3.toggled.connect (() => {
            on_contrast_button_toggled (contrast_button_3);
        });
        contrast_button_4.toggled.connect (() => {
            on_contrast_button_toggled (contrast_button_4);
        });

        contrast_refresh ();
        tau_appearance_settings.notify["changed::contrast"].connect (() => {
            contrast_refresh ();
        });
    }

    private void contrast_refresh () {
        double value = tau_appearance_settings.get_double ("contrast");

        if (value == 1.0) {
            contrast_button_1.active = true;
            contrast_button_2.active = false;
            contrast_button_3.active = false;
            contrast_button_4.active = false;
        } else if (value == 2.0) {
            contrast_button_2.active = true;
            contrast_button_1.active = false;
            contrast_button_3.active = false;
            contrast_button_4.active = false;
        } else if (value == 3.0) {
            contrast_button_3.active = true;
            contrast_button_2.active = false;
            contrast_button_1.active = false;
            contrast_button_4.active = false;
        } else if (value == 4.0) {
            contrast_button_4.active = true;
            contrast_button_2.active = false;
            contrast_button_3.active = false;
            contrast_button_1.active = false;
        } else {
            contrast_button_2.active = true;
            contrast_button_1.active = false;
            contrast_button_3.active = false;
            contrast_button_4.active = false;
        }
    }

    private void on_contrast_button_toggled (Gtk.ToggleButton contrast_button) {
        if (contrast_button == contrast_button_1) {
            set_contrast (1.0);
        } else if (contrast_button == contrast_button_2) {
            set_contrast (2.0);
        } else if (contrast_button == contrast_button_3) {
            set_contrast (3.0);
        } else if (contrast_button == contrast_button_4) {
            set_contrast (4.0);
        } else {
            set_contrast (2.0);
        }
    }
    private void set_contrast (double contrast) {
        tau_appearance_settings.set_double ("contrast", contrast);
    }
}