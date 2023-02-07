public class StartupView : Gtk.Box {

    public Fusebox.Fuse fuse { get; construct; }

    public StartupView (Fusebox.Fuse _fuse) {
        Object (fuse: _fuse);
    }

    // TODO: load gsettings to show system apps
    public bool show_system_apps { get; set construct; }

    construct {
        // the actual list to contain the startup apps
        var list = new Gtk.ListBox ();
        list.add_css_class ("content-list");
        list.show_separators = true;

        // set spacing between rows
        // gtk4
        list.set_header_func ((row, before) => {
            if (before != null) {
                row.set_margin_top (6);
            } else {
                row.set_margin_bottom (6);
            }
        });

        list.set_selection_mode (Gtk.SelectionMode.SINGLE);
        var approw = get_startup_apps ();

        foreach (var row in approw) {
            list.append (row);
        }


        var lbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        lbox.append (list);

        var sw = new Gtk.ScrolledWindow ();
        sw.hscrollbar_policy = (Gtk.PolicyType.NEVER);
        sw.set_child (lbox);

        var overlay = new He.OverlayButton ("", null, null) {
            margin_start = 18,
            margin_end = 18,
            margin_bottom = 18,
            icon = "list-add-symbolic",
            child = (sw),
            label = _("Create"),
            typeb = PRIMARY
        };

        var clamp = new Bis.Latch () {
            child = (overlay)
        };

        // return the thing
        append (clamp);
        orientation = Gtk.Orientation.VERTICAL;
    }
    private Gtk.ListBoxRow[] get_startup_apps () {
        Gtk.ListBoxRow[] rows = {};

        // get the app list
        foreach (unowned string path in Startup.Utils.get_autostart_files ()) {
            debug ("path: %s\n", path);

            // load keyfile from path

            var key_file = new Startup.Backend.KeyFile (path);

            var appinfo = key_file.create_app_info ();

            debug ("name: %s\n", appinfo.name);

            var app = new AppEntry (key_file);
            var row = app.into_row ();
            rows += row;
        }
        return rows;
    }
}


private class AppEntry : Gtk.Box {
    public Startup.Backend.KeyFile keyfile { get; set construct; }
    private string app_name { get; set; }
    private string app_desc { get; set; }
    private string app_icon { get; set; }
    private bool app_enabled { get; set; }

    public string create_icon (string iconname) {
        var icon_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
        if (icon_theme.has_icon (iconname)) {
            return iconname;
        } else {
            return "application-default-icon";
        }
    }

    public AppEntry (Startup.Backend.KeyFile _keyfile) {
        Object (keyfile: _keyfile);
    }

    construct {
        app_name = keyfile.keyfile_get_string (KeyFileDesktop.KEY_NAME);
        app_desc = keyfile.keyfile_get_string (KeyFileDesktop.KEY_COMMENT);
        app_icon = keyfile.keyfile_get_string (KeyFileDesktop.KEY_ICON);
        app_enabled = keyfile.active;

        orientation = Gtk.Orientation.HORIZONTAL;
        spacing = 6;
        add_css_class ("mini-content-block");

        var label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            halign = Gtk.Align.START
        };

        var icon = new Gtk.Image () {
            icon_name = app_icon,
            pixel_size = 48
        };
        append (icon);
        notify["app-icon"].connect (() => {
            icon.icon_name = create_icon (app_icon);
        });

        var name = new Gtk.Label (app_name) {
            xalign = 0,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD_CHAR,
            ellipsize = Pango.EllipsizeMode.END
        };
        name.add_css_class ("cb-title");
        label_box.append (name);
        notify["app-name"].connect (() => {
            name.label = app_name;
        });

        var desc = new Gtk.Label (app_desc) {
            xalign = 0,
            wrap = true
        };
        desc.wrap_mode = Pango.WrapMode.WORD_CHAR;
        desc.ellipsize = Pango.EllipsizeMode.END;
        desc.add_css_class ("cb-subtitle");
        label_box.append (desc);
        notify["app-desc"].connect (() => {
            desc.label = app_desc;
        });
        append (label_box);

        // toggle switch at the end of the box
        var app_switch = new Gtk.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            margin_end = 6,
            hexpand = true,
            active = app_enabled,
            tooltip_text = _("Turn on/off this app autostart entry.")
        };
        append (app_switch);
        app_switch.notify["active"].connect (() => {
            toggle_active (app_switch.active);
            save ();
        });

        // edit button
        // TODO: move to overlay
        var edit_button = new He.DisclosureButton ("") {
            icon = "document-edit-symbolic",
            tooltip_text = _("Edit this app autostart entry.")
        };
        append (edit_button);
        edit_button.clicked.connect (() => {
            new StartupAppDialog (keyfile.get_instance (keyfile.path),
                                  He.Misc.find_ancestor_of_type<He.ApplicationWindow> (this)
            ).show ();
        });


        // delete button
        var delete_button = new He.DisclosureButton ("") {
            icon = "user-trash-symbolic",
            tooltip_text = _("Delete this app autostart entry.")
        };
        delete_button.add_css_class ("meson-red");
        append (delete_button);
        delete_button.clicked.connect (delete);


        notify["app-enabled"].connect (() => {
            app_switch.active = app_enabled;
        });
    }

    public void toggle_active (bool state) {
        keyfile.active = state;
        app_enabled = state;
        print ("toggle_active: %b\n", app_enabled);
        // notify
        // return app_enabled;
    }

    // function to wrap in a row
    public Gtk.ListBoxRow into_row () {
        var row = new Gtk.ListBoxRow ();
        row.set_child (this);
        return row;
    }

    public void save () {
        keyfile.write_to_file ();
    }

    public void delete () {
        // get keyfile path
        var path = keyfile.path;
        // delete the file
        File file = File.new_for_path (path);
        try {
            file.delete ();
        } catch (Error e) {
            warning ("Error deleting file: %s", e.message);
        }
        // remove the row
        print ("delete\n");
        var row = (Gtk.ListBoxRow) get_parent ();
        var list = (Gtk.ListBox) row.get_parent ();
        list.remove (row);
    }
}