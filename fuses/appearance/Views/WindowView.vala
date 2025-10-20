public class Appearance.WindowView : Gtk.Box {
    private static GLib.Settings wm_settings;
    private He.Dropdown wm_layout_cb;
    private He.Dropdown wm_dc_cb;
    private He.Dropdown wm_sc_cb;
    private He.Dropdown wm_focus_cb;
    private Gtk.Box wm_layout_preview;

    private ulong wm_layout_handler = 0;
    private ulong wm_dc_handler = 0;
    private ulong wm_sc_handler = 0;
    private ulong wm_focus_handler = 0;

    public WindowView () {
    }

    static construct {
        wm_settings = new GLib.Settings ("org.gnome.desktop.wm.preferences");
    }

    construct {
        var wm_layout_preview_label = new He.ViewTitle () {
            label = (_("View"))
        };
        var wm_layout_preview_bar = new He.AppBar () {
            can_target = false,
            viewtitle_widget = wm_layout_preview_label
        };
        var wm_layout_preview_mbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_top = 24,
            margin_start = 48,
            margin_end = 48
        };
        wm_layout_preview_mbox.append (wm_layout_preview_bar);
        wm_layout_preview_mbox.add_css_class ("medium-radius");
        wm_layout_preview_mbox.add_css_class ("surface-bg-color");
        wm_layout_preview = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
        };
        wm_layout_preview.add_css_class ("circle-radius");
        wm_layout_preview.add_css_class ("surface-container-bg-color");
        wm_layout_preview.append (wm_layout_preview_mbox);

        wm_layout_cb = new He.Dropdown ();
        wm_layout_cb.append ("Kiri");
        wm_layout_cb.append ("Aqua");
        wm_layout_cb.append ("Fluent");
        wm_layout_cb.append ("Granite");
        wm_layout_cb.append ("Adwaita");
        wm_layout_cb.append ("Breeze");
        wm_layout_cb.valign = Gtk.Align.CENTER;

        var wm_layout_box_cb = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        wm_layout_box_cb.append (
                                 new Gtk.Label (_("Window Controls Layout")) {
            css_classes = { "cb-title" },
            xalign = 0
        });
        wm_layout_box_cb.append (
                                 new Gtk.Label (_("This changes the button placement of close, maximize and minimize")) {
            css_classes = { "cb-subtitle", "dim-label" },
            xalign = 0,
            lines = 2,
            max_width_chars = 40,
            ellipsize = Pango.EllipsizeMode.END,
            hexpand = true,
            halign = Gtk.Align.START
        });

        var wm_layout_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        wm_layout_box.append (wm_layout_box_cb);
        wm_layout_box.append (wm_layout_cb);
        wm_layout_box.hexpand = true;
        wm_layout_box.add_css_class ("mini-content-block");

        var wm_title_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        wm_title_box.append (
                             new Gtk.Label (_("Titlebar Actions")) {
            css_classes = { "cb-title" },
            xalign = 0
        });
        wm_title_box.append (
                             new Gtk.Label (_("Change what the mouse does when interacting with the titlebar")) {
            css_classes = { "cb-subtitle", "dim-label" },
            xalign = 0,
            hexpand = true,
            halign = Gtk.Align.START
        });

        wm_dc_cb = new He.Dropdown ();
        wm_dc_cb.append (_("Toggle Maximize"));
        wm_dc_cb.append (_("Minimize"));
        wm_dc_cb.append (_("Menu"));
        wm_dc_cb.append (_("None"));
        wm_dc_cb.valign = Gtk.Align.CENTER;

        var wm_dc_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        wm_dc_box.append (
                          new Gtk.Label (_("Double Click")) {
            css_classes = { "cb-title" },
            xalign = 0,
            hexpand = true,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.START
        });
        wm_dc_box.append (wm_dc_cb);
        wm_dc_box.hexpand = true;
        wm_dc_box.add_css_class ("mini-content-block");

        wm_title_box.append (wm_dc_box);

        wm_sc_cb = new He.Dropdown ();
        wm_sc_cb.append (_("Toggle Maximize"));
        wm_sc_cb.append (_("Minimize"));
        wm_sc_cb.append (_("Menu"));
        wm_sc_cb.append (_("None"));
        wm_sc_cb.dropdown.selected = 2;
        wm_sc_cb.valign = Gtk.Align.CENTER;

        var wm_sc_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        wm_sc_box.append (
                          new Gtk.Label (_("Secondary Click")) {
            css_classes = { "cb-title" },
            xalign = 0,
            hexpand = true,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.START
        });
        wm_sc_box.append (wm_sc_cb);
        wm_sc_box.hexpand = true;
        wm_sc_box.add_css_class ("mini-content-block");

        wm_title_box.append (wm_sc_box);

        wm_focus_cb = new He.Dropdown ();
        wm_focus_cb.append (_("Click"));
        wm_focus_cb.append (_("Sloppy"));
        wm_focus_cb.valign = Gtk.Align.CENTER;

        var wm_focus_box_cb = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        wm_focus_box_cb.append (
                                new Gtk.Label (_("Focusing")) {
            css_classes = { "cb-title" },
            xalign = 0
        });
        wm_focus_box_cb.append (
                                new Gtk.Label (_("This changes the way to focus windows to make them the active window")) {
            css_classes = { "cb-subtitle", "dim-label" },
            xalign = 0,
            lines = 2,
            max_width_chars = 40,
            ellipsize = Pango.EllipsizeMode.END,
            hexpand = true,
            halign = Gtk.Align.START
        });

        var wm_focus_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        wm_focus_box.append (wm_focus_box_cb);
        wm_focus_box.append (wm_focus_cb);
        wm_focus_box.hexpand = true;
        wm_focus_box.add_css_class ("mini-content-block");

        var grid = new Gtk.Grid () {
            row_spacing = 6,
            margin_start = 18,
            margin_end = 18,
            margin_bottom = 18,
            hexpand = true
        };
        grid.attach (wm_layout_preview, 0, 0);
        grid.attach (wm_layout_box, 0, 1);
        grid.attach (wm_title_box, 0, 2);
        grid.attach (wm_focus_box, 0, 3);

        var sw = new Gtk.ScrolledWindow ();
        sw.set_child (grid);

        append (sw);
        hexpand = true;

        wm_layout_refresh ();
        wm_settings.changed.connect ((key) => {
            if (key == "button-layout") {
                wm_layout_refresh ();
            }
        });

        wm_dc_refresh ();
        wm_settings.changed.connect ((key) => {
            if (key == "action-double-click-titlebar") {
                wm_dc_refresh ();
            }
        });

        wm_sc_refresh ();
        wm_settings.changed.connect ((key) => {
            if (key == "action-right-click-titlebar") {
                wm_sc_refresh ();
            }
        });

        wm_focus_refresh ();
        wm_settings.changed.connect ((key) => {
            if (key == "focus-mode") {
                wm_focus_refresh ();
            }
        });
    }

    private void wm_layout_refresh () {
        // Disconnect existing handlers to prevent duplicates
        if (wm_layout_handler != 0) {
            wm_layout_cb.disconnect (wm_layout_handler);
            wm_layout_handler = 0;
        }

        string title = wm_settings.get_string ("button-layout");
        switch (title) {
        case "close:minimize,maximize":
            wm_layout_cb.dropdown.selected = 0;
            break;
        case "close,minimize,maximize:":
            wm_layout_cb.dropdown.selected = 1;
            break;
        case ":minimize,maximize,close":
            wm_layout_cb.dropdown.selected = 2;
            break;
        case "close:maximize":
            wm_layout_cb.dropdown.selected = 3;
            break;
        case ":close":
            wm_layout_cb.dropdown.selected = 4;
            break;
        case "appmenu:minimize,maximize,close":
            wm_layout_cb.dropdown.selected = 5;
            break;
        }

        wm_layout_handler = wm_layout_cb.changed.connect (() => {
            uint choice = wm_layout_cb.dropdown.selected;
            switch (choice) {
                case 0:
                    wm_settings.set_string ("button-layout", "close:minimize,maximize");
                    break;
                case 1:
                    wm_settings.set_string ("button-layout", "close,minimize,maximize:");
                    break;
                case 2:
                    wm_settings.set_string ("button-layout", ":minimize,maximize,close");
                    break;
                case 3:
                    wm_settings.set_string ("button-layout", "close:maximize");
                    break;
                case 4:
                    wm_settings.set_string ("button-layout", ":close");
                    break;
                case 5:
                    wm_settings.set_string ("button-layout", "appmenu:minimize,maximize,close");
                    break;
            }
        });
    }

    private void wm_dc_refresh () {
        // Disconnect existing handlers to prevent duplicates
        if (wm_dc_handler != 0) {
            wm_dc_cb.disconnect (wm_dc_handler);
            wm_dc_handler = 0;
        }

        int title = wm_settings.get_enum ("action-double-click-titlebar");
        switch (title) {
        case 1:
            wm_dc_cb.dropdown.selected = 0;
            break;
        case 4:
            wm_dc_cb.dropdown.selected = 1;
            break;
        case 7:
            wm_dc_cb.dropdown.selected = 2;
            break;
        case 5:
            wm_dc_cb.dropdown.selected = 3;
            break;
        }

        wm_dc_handler = wm_dc_cb.changed.connect (() => {
            uint choice = wm_dc_cb.dropdown.selected;
            switch (choice) {
                case 0:
                    wm_settings.set_enum ("action-double-click-titlebar", 1);
                    break;
                case 1:
                    wm_settings.set_enum ("action-double-click-titlebar", 4);
                    break;
                case 2:
                    wm_settings.set_enum ("action-double-click-titlebar", 7);
                    break;
                case 3:
                    wm_settings.set_enum ("action-double-click-titlebar", 5);
                    break;
            }
        });
    }

    private void wm_sc_refresh () {
        // Disconnect existing handlers to prevent duplicates
        if (wm_sc_handler != 0) {
            wm_sc_cb.disconnect (wm_sc_handler);
            wm_sc_handler = 0;
        }

        int title = wm_settings.get_enum ("action-right-click-titlebar");
        switch (title) {
        case 1:
            wm_sc_cb.dropdown.selected = 0;
            break;
        case 4:
            wm_sc_cb.dropdown.selected = 1;
            break;
        case 7:
            wm_sc_cb.dropdown.selected = 2;
            break;
        case 5:
            wm_sc_cb.dropdown.selected = 3;
            break;
        }

        wm_sc_handler = wm_sc_cb.changed.connect (() => {
            uint choice = wm_sc_cb.dropdown.selected;
            switch (choice) {
                case 0:
                    wm_settings.set_enum ("action-right-click-titlebar", 1);
                    break;
                case 1:
                    wm_settings.set_enum ("action-right-click-titlebar", 4);
                    break;
                case 2:
                    wm_settings.set_enum ("action-right-click-titlebar", 7);
                    break;
                case 3:
                    wm_settings.set_enum ("action-right-click-titlebar", 5);
                    break;
            }
        });
    }

    private void wm_focus_refresh () {
        // Disconnect existing handlers to prevent duplicates
        if (wm_focus_handler != 0) {
            wm_focus_cb.disconnect (wm_focus_handler);
            wm_focus_handler = 0;
        }

        int title = wm_settings.get_enum ("focus-mode");
        switch (title) {
        case 0:
            wm_focus_cb.dropdown.selected = 0;
            break;
        case 1:
            wm_focus_cb.dropdown.selected = 1;
            break;
        }

        wm_focus_handler = wm_focus_cb.changed.connect (() => {
            uint choice = wm_focus_cb.dropdown.selected;
            switch (choice) {
                case 0:
                    wm_settings.set_enum ("focus-mode", 0);
                    break;
                case 1:
                    wm_settings.set_enum ("focus-mode", 1);
                    break;
            }
        });
    }
}