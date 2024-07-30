public class Mouse.TouchpadView : Gtk.Box {
    private static GLib.Settings touchpad_settings;
    private Gtk.Box main_box;

    static construct {
        touchpad_settings = new GLib.Settings ("org.gnome.desktop.peripherals.touchpad");
    }

    construct {
        var touchpad_enable_box = new He.SwitchBar () {
            title = (_("Touchpad")),
            sensitive_widget = main_box
        };

        var pointer_speed_adjustment = new Gtk.Adjustment (0, -1, 1, 0.1, 0, 0);

        var pointer_speed_scale = new He.Slider () {
            hexpand = true,
            width_request = 240,
        };
        pointer_speed_scale.scale.set_adjustment (pointer_speed_adjustment);
        pointer_speed_scale.add_mark (-1, (_("Slower")));
        pointer_speed_scale.add_mark (0, (_("Default")));
        pointer_speed_scale.add_mark (1, (_("Faster")));
        for (double x = -0.5; x < 1; x += 0.5) {
            pointer_speed_scale.add_mark (x, null);
        }

        var pointer_speed_box = new He.SettingsRow () {
            title = (_("Pointer Speed")),
            subtitle = (_("Cursor movement rate"))
        };
        pointer_speed_box.primary_button = (He.Button)pointer_speed_scale;

        var pointer_acceleration_switch = new He.Switch () {
            valign = Gtk.Align.CENTER
        };

        var pointer_acceleration_box = new He.SettingsRow () {
            title = (_("Pointer Acceleration")),
            subtitle = (_("Makes touchpad use more comfortable")),
            activatable_widget = pointer_acceleration_switch
        };
        pointer_acceleration_box.primary_button = (He.Button)pointer_acceleration_switch;

        var default_scroll_image = new Gtk.Image.from_icon_name ("default-touch-scroll-symbolic") {
            pixel_size = 128,
            hexpand = true,
            halign = Gtk.Align.CENTER
        };

        var default_scroll_card = new Gtk.Grid ();
        default_scroll_card.attach (default_scroll_image, 0, 0);

        var default_check = new Gtk.CheckButton () {
            halign = Gtk.Align.START
        };

        var default_scroll_grid = new Gtk.Grid () {
            row_spacing = 6,
            hexpand = true
        };
        default_scroll_grid.attach (default_scroll_card, 0, 0, 2);
        default_scroll_grid.attach (default_check, 0, 1);
        default_scroll_grid.attach (new Gtk.Label (_("Standard")){
            halign = Gtk.Align.START,
            css_classes = {"cb-title"}
        }, 1, 1);
        default_scroll_grid.attach (new Gtk.Label (_("Scrolling moves view")){
            halign = Gtk.Align.START
        }, 1, 2);

        var default_scroll = new Gtk.ToggleButton ();
        default_scroll.add_css_class ("card-option");
        default_scroll.set_child (default_scroll_grid);

        var natural_scroll_image = new Gtk.Image.from_icon_name ("natural-touch-scroll-symbolic") {
            pixel_size = 128,
            hexpand = true,
            halign = Gtk.Align.CENTER
        };

        var natural_scroll_card = new Gtk.Grid ();
        natural_scroll_card.attach (natural_scroll_image, 0, 0);

        var natural_check = new Gtk.CheckButton () {
            halign = Gtk.Align.START,
            group = default_check
        };

        var natural_scroll_grid = new Gtk.Grid () {
            row_spacing = 6,
            hexpand = true
        };
        natural_scroll_grid.attach (natural_scroll_card, 0, 0, 2);
        natural_scroll_grid.attach (natural_check, 0, 1);
        natural_scroll_grid.attach (new Gtk.Label (_("Natural")) {
            halign = Gtk.Align.START,
            css_classes = {"cb-title"}
        }, 1, 1);
        natural_scroll_grid.attach (new Gtk.Label (_("Scrolling moves content")){
            halign = Gtk.Align.START
        }, 1, 2);

        var natural_scroll = new Gtk.ToggleButton () {
            group = default_scroll
        };
        natural_scroll.set_child (natural_scroll_grid);
        natural_scroll.add_css_class ("card-option");

        var scroll_label = new Gtk.Label (_("Scrolling Direction")) {
            halign = Gtk.Align.START
        };
        scroll_label.add_css_class ("cb-title");

        var scrolling_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        scrolling_box.append (default_scroll);
        scrolling_box.append (natural_scroll);

        var main_scrolling_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        main_scrolling_box.append (scroll_label);
        main_scrolling_box.append (scrolling_box);
        main_scrolling_box.add_css_class ("mini-content-block");

        var tap_click_switch = new He.Switch () {
            valign = Gtk.Align.CENTER
        };

        var tap_click_box = new He.SettingsRow () {
            title = (_("Tap To Click")),
            subtitle = (_("Quick tap to do clicks")),
            activatable_widget = tap_click_switch
        };
        tap_click_box.primary_button = (He.Button)tap_click_switch;

        main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            sensitive = touchpad_enable_box.main_switch.iswitch.active
        };
        main_box.append (pointer_speed_box);
        main_box.append (pointer_acceleration_box);
        main_box.append (tap_click_box);
        main_box.append (main_scrolling_box);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        box.append (touchpad_enable_box);
        box.append (main_box);

        var clamp = new Bis.Latch () {
            hexpand = true
        };

        clamp.set_child (box);
        this.append (clamp);
        orientation = Gtk.Orientation.VERTICAL;

        touchpad_enable_box.main_switch.iswitch.notify["active"].connect (() => {
            if (touchpad_enable_box.main_switch.iswitch.active) {
                main_box.sensitive = true;
            } else {
                main_box.sensitive = false;
            }
        });
        touchpad_settings.bind ("send-events", touchpad_enable_box.main_switch.iswitch, "active", GLib.SettingsBindFlags.DEFAULT);
        touchpad_settings.bind ("speed", pointer_speed_scale, "value", GLib.SettingsBindFlags.DEFAULT);

        touchpad_settings.bind ("tap-to-click", tap_click_switch.iswitch, "active", GLib.SettingsBindFlags.DEFAULT);

        switch (touchpad_settings.get_enum ("accel-profile")) {
            case 1:
                pointer_acceleration_switch.iswitch.active = false;
                break;
            case 2:
            case 0:
            default:
                pointer_acceleration_switch.iswitch.active = true;
                break;
        }

        pointer_acceleration_switch.iswitch.notify["state-set"].connect (() => {
            if (pointer_acceleration_switch.iswitch.active) {
                touchpad_settings.set_enum ("accel-profile", 2);
            } else {
                touchpad_settings.set_enum ("accel-profile", 1);
            }
        });

        if (touchpad_settings.get_boolean ("natural-scroll")) {
            natural_scroll.active = true;
            natural_check.active = true;
        } else {
            default_scroll.active = true;
            default_check.active = true;
        }

        natural_scroll.toggled.connect (() => {
            touchpad_settings.set_boolean ("natural-scroll", true);
            default_scroll.active = false;
            default_check.active = false;
            natural_check.active = true;
        });

        default_scroll.toggled.connect (() => {
            touchpad_settings.set_boolean ("natural-scroll", false);
            natural_scroll.active = false;
            natural_check.active = false;
            default_check.active = true;
        });
    }
}