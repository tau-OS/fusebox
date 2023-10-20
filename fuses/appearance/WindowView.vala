 public class Appearance.WindowView : Gtk.Box {
     private static GLib.Settings wm_settings;
     private Gtk.ComboBoxText wm_layout_cb;
     private Gtk.ComboBoxText wm_dc_cb;
     private Gtk.ComboBoxText wm_sc_cb;
     private Gtk.ComboBoxText wm_focus_cb;
     private He.ContentBlockImage wm_layout_preview;

     public WindowView () {
     }

     static construct {
         wm_settings = new GLib.Settings ("org.gnome.desktop.wm.preferences");
     }

     construct {
        wm_layout_preview = new He.ContentBlockImage ("resource:///com/fyralabs/Fusebox/Appearance/kiri-l.svg") {
            requested_width = 550,
            requested_height = 200,
            halign = Gtk.Align.CENTER
        };

        wm_layout_cb = new Gtk.ComboBoxText () {
            valign = Gtk.Align.CENTER
        };
        wm_layout_cb.append_text ("Kiri");
        wm_layout_cb.append_text ("Aqua");
        wm_layout_cb.append_text ("Fluent");
        wm_layout_cb.append_text ("Granite");
        wm_layout_cb.append_text ("Adwaita");
        wm_layout_cb.append_text ("Breeze");
        wm_layout_cb.active = 0;

        var wm_layout_box_cb = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        wm_layout_box_cb.append (
            new Gtk.Label (_("Window Controls Layout")) {
                css_classes = { "cb-title" },
                xalign = 0
            }
        );
        wm_layout_box_cb.append (
            new Gtk.Label (_("This changes the button placement of close, maximize and minimize")) {
                css_classes = { "cb-subtitle", "dim-label" },
                xalign = 0,
                lines = 2,
                max_width_chars = 40,
                ellipsize = Pango.EllipsizeMode.END,
                hexpand = true,
                halign = Gtk.Align.START
            }
        );

        var wm_layout_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        wm_layout_box.append (wm_layout_box_cb);
        wm_layout_box.append (wm_layout_cb);
        wm_layout_box.hexpand = true;
        wm_layout_box.add_css_class ("mini-content-block");

        var wm_title_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        wm_title_box.append (
            new Gtk.Label (_("Titlebar Actions")) {
                css_classes = { "cb-title" },
                xalign = 0
            }
        );
        wm_title_box.append (
            new Gtk.Label (_("Change what the mouse does when interacting with the  titlebar")) {
                css_classes = { "cb-subtitle", "dim-label" },
                xalign = 0,
                hexpand = true,
                halign = Gtk.Align.START
            }
        );

        wm_dc_cb = new Gtk.ComboBoxText () {
            valign = Gtk.Align.CENTER
        };
        wm_dc_cb.append_text (_("Toggle Maximize"));
        wm_dc_cb.append_text (_("Minimize"));
        wm_dc_cb.append_text (_("Menu"));
        wm_dc_cb.append_text (_("None"));
        wm_dc_cb.active = 0;

        var wm_dc_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        wm_dc_box.append (
            new Gtk.Label (_("Double Click")) {
                css_classes = { "cb-title" },
                xalign = 0,
                hexpand = true,
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.START
            }
        );
        wm_dc_box.append (wm_dc_cb);
        wm_dc_box.hexpand = true;
        wm_dc_box.add_css_class ("mini-content-block");

        wm_title_box.append (wm_dc_box);

        wm_sc_cb = new Gtk.ComboBoxText () {
            valign = Gtk.Align.CENTER
        };
        wm_sc_cb.append_text (_("Toggle Maximize"));
        wm_sc_cb.append_text (_("Minimize"));
        wm_sc_cb.append_text (_("Menu"));
        wm_sc_cb.append_text (_("None"));
        wm_sc_cb.active = 2;

        var wm_sc_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        wm_sc_box.append (
            new Gtk.Label (_("Secondary Click")) {
                css_classes = { "cb-title" },
                xalign = 0,
                hexpand = true,
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.START
            }
        );
        wm_sc_box.append (wm_sc_cb);
        wm_sc_box.hexpand = true;
        wm_sc_box.add_css_class ("mini-content-block");

        wm_title_box.append (wm_sc_box);

        wm_focus_cb = new Gtk.ComboBoxText () {
            valign = Gtk.Align.CENTER
        };
        wm_focus_cb.append_text ("Click to Focus");
        wm_focus_cb.append_text ("Focus on Hover");
        wm_focus_cb.active = 0;

        var wm_focus_box_cb = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        wm_focus_box_cb.append (
            new Gtk.Label (_("Focusing")) {
                css_classes = { "cb-title" },
                xalign = 0
            }
        );
        wm_focus_box_cb.append (
            new Gtk.Label (_("This changes the way to focus windows to make them the active window")) {
                css_classes = { "cb-subtitle", "dim-label" },
                xalign = 0,
                lines = 2,
                max_width_chars = 40,
                ellipsize = Pango.EllipsizeMode.END,
                hexpand = true,
                halign = Gtk.Align.START
            }
        );

        var wm_focus_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        wm_focus_box.append (wm_focus_box_cb);
        wm_focus_box.append (wm_focus_cb);
        wm_focus_box.hexpand = true;
        wm_focus_box.add_css_class ("mini-content-block");

        var grid = new Gtk.Grid () {
         row_spacing = 18,
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

        var lapel = new Bis.Latch ();
        lapel.set_child (sw);

        append (lapel);
        hexpand = true;

        wm_layout_refresh ();
        wm_settings.notify["changed:button-layout"].connect (() => {
            wm_layout_refresh ();
        });

        wm_dc_refresh ();
        wm_settings.notify["changed:action-double-click-titlebar"].connect (() => {
            wm_dc_refresh ();
        });

        wm_sc_refresh ();
        wm_settings.notify["changed:action-right-click-titlebar"].connect (() => {
            wm_sc_refresh ();
        });

        wm_focus_refresh ();
        wm_settings.notify["changed:focus-mode"].connect (() => {
            wm_focus_refresh ();
        });
    }

    private void wm_layout_refresh () {
        string title = wm_settings.get_string ("button-layout");
        switch (title) {
            case "close,minimize,maximize:":
                wm_layout_cb.set_active (0);
                wm_layout_preview.file = "resource:///com/fyralabs/Fusebox/Appearance/kiri-l.svg";
                break;
            case ":minimize,maximize,close":
                wm_layout_cb.set_active (2);
                wm_layout_preview.file = "resource:///com/fyralabs/Fusebox/Appearance/fluent-l.svg";
                break;
            case "close:maximize":
                wm_layout_cb.set_active (3);
                wm_layout_preview.file = "resource:///com/fyralabs/Fusebox/Appearance/granite-l.svg";
                break;
            case ":close":
                wm_layout_cb.set_active (4);
                wm_layout_preview.file = "resource:///com/fyralabs/Fusebox/Appearance/adwaita-l.svg";
                break;
            case "appmenu:minimize,maximize,close":
                wm_layout_cb.set_active (5);
                wm_layout_preview.file = "resource:///com/fyralabs/Fusebox/Appearance/breeze-l.svg";
                break;
        }

        wm_layout_cb.changed.connect (() => {
            int choice = wm_layout_cb.get_active ();
            switch (choice) {
                case 0:
                case 1:
                    wm_settings.set_string ("button-layout", "close,minimize,maximize:");
                    wm_layout_preview.file = "resource:///com/fyralabs/Fusebox/Appearance/kiri-l.svg";
                    break;
                case 2:
                    wm_settings.set_string ("button-layout", ":minimize,maximize,close");
                    wm_layout_preview.file = "resource:///com/fyralabs/Fusebox/Appearance/fluent-l.svg";
                    break;
                case 3:
                    wm_settings.set_string ("button-layout", "close:maximize");
                    wm_layout_preview.file = "resource:///com/fyralabs/Fusebox/Appearance/granite-l.svg";
                    break;
                case 4:
                    wm_settings.set_string ("button-layout", ":close");
                    wm_layout_preview.file = "resource:///com/fyralabs/Fusebox/Appearance/adwaita-l.svg";
                    break;
                case 5:
                    wm_settings.set_string ("button-layout", "appmenu:minimize,maximize,close");
                    wm_layout_preview.file = "resource:///com/fyralabs/Fusebox/Appearance/breeze-l.svg";
                    break;
            }
        });
    }

    private void wm_dc_refresh () {
        int title = wm_settings.get_enum ("action-double-click-titlebar");
        switch (title) {
            case 1:
                wm_dc_cb.set_active (0);
                break;
            case 4:
                wm_dc_cb.set_active (1);
                break;
            case 7:
                wm_dc_cb.set_active (2);
                break;
            case 5:
                wm_dc_cb.set_active (3);
                break;
        }

        wm_dc_cb.changed.connect (() => {
            int choice = wm_dc_cb.get_active ();
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
        int title = wm_settings.get_enum ("action-right-click-titlebar");
        switch (title) {
            case 1:
                wm_sc_cb.set_active (0);
                break;
            case 4:
                wm_sc_cb.set_active (1);
                break;
            case 7:
                wm_sc_cb.set_active (2);
                break;
            case 5:
                wm_sc_cb.set_active (3);
                break;
        }

        wm_sc_cb.changed.connect (() => {
            int choice = wm_sc_cb.get_active ();
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
        int title = wm_settings.get_enum ("focus-mode");
        switch (title) {
            case 0:
                wm_focus_cb.set_active (0);
                break;
            case 1:
                wm_focus_cb.set_active (1);
                break;
        }

        wm_focus_cb.changed.connect (() => {
            int choice = wm_focus_cb.get_active ();
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
