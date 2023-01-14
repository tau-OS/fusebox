public class StartupAppDialog : He.Window {
    public Startup.Backend.KeyFile keyFile { get; set construct; }
    private Startup.Backend.KeyFile kf { get; set; }
    private Gtk.Box mainBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);

    public StartupAppDialog (Startup.Backend.KeyFile keyfile, He.ApplicationWindow parent) {
        Object (keyFile: keyfile);
        this.parent = parent;
        this.transient_for = parent;
        this.modal = true;
        this.resizable = false;
        this.set_size_request (440, 450);
    }

    construct {
        var title = new Gtk.Label (_("Edit Startup Entry")) {
            margin_top = 34,
            margin_start = 18,
            halign = Gtk.Align.START
        };
        title.add_css_class ("view-title");
        mainBox.append (title);

        var icon_btn = new He.TintButton ("") {
            width_request = 128,
            height_request = 128,
            halign = Gtk.Align.CENTER
        };
        // TODO: lains: do icon sizing
        var btn_content = new He.ButtonContent () {
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER
        };
        btn_content.image.pixel_size = 96;

        // get icon name
        try {
            var icon_name = keyFile.keyfile_get_string (KeyFileDesktop.KEY_ICON);
            btn_content.icon = icon_name;
        } catch (GLib.KeyFileError e) {
            warning (e.message);
        }
        icon_btn.child = (btn_content);

        mainBox.append (icon_btn);

        // settings content
        var name_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_start = 18,
            margin_end = 18
        };

        var name_label = new Gtk.Label (_("Name")) {
            xalign = 0
        };
        name_label.add_css_class ("cb-title");
        name_view.append (name_label);

        var name_entry = new Gtk.Entry ();
        name_entry.hexpand = true;
        name_view.append (name_entry);

        // connect to keyfile's name
        try {
            var name = keyFile.keyfile_get_string (KeyFileDesktop.KEY_NAME);
            name_entry.text = name;
        } catch (GLib.KeyFileError e) {
            warning (e.message);
        }
        name_entry.notify["text"].connect (() => {
            keyFile.keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NAME, name_entry.text);
        });
        name_view.append (name_entry);

        mainBox.append (name_view);

        // Exec
        var command_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_start = 18,
            margin_end = 18
        };

        var command_label = new Gtk.Label (_("Execute")) {
            xalign = 0
        };
        command_label.add_css_class ("cb-title");
        command_view.append (command_label);

        var command_entry = new Gtk.Entry ();
        command_entry.hexpand = true;
        // connect to keyfile's exec
        try {
            var exec = keyFile.keyfile_get_string (KeyFileDesktop.KEY_EXEC);
            command_entry.text = exec;
        } catch (GLib.KeyFileError e) {
            warning (e.message);
        }
        command_entry.notify["text"].connect (() => {
            keyFile.keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_EXEC, command_entry.text);
        });
        command_view.append (command_entry);
        mainBox.append (command_view);

        var comment_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_start = 18,
            margin_end = 18
        };

        var comment_label = new Gtk.Label (_("Comment")) {
            xalign = 0
        };
        comment_label.add_css_class ("cb-title");
        comment_view.append (comment_label);

        var comment_entry = new Gtk.Entry ();
        comment_entry.hexpand = true;
        // connect to keyfile's comment
        try {
            var comment = keyFile.keyfile_get_string (KeyFileDesktop.KEY_COMMENT);
            comment_entry.text = comment;
        } catch (GLib.KeyFileError e) {
            warning (e.message);
        }
        comment_entry.notify["text"].connect (() => {
            keyFile.keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_COMMENT, comment_entry.text);
        });
        comment_view.append (comment_entry);
        mainBox.append (comment_view);

        // categories
        // todo: use He.Chip for categories
        var categories_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_start = 18,
            margin_end = 18
        };

        var categories_label = new Gtk.Label (_("Categories")) {
            xalign = 0
        };
        categories_label.add_css_class ("cb-title");
        categories_view.append (categories_label);

        var categories_entry = new Gtk.Entry ();
        categories_entry.hexpand = true;
        // connect to keyfile's categories
        try {
            var categories = keyFile.keyfile_get_string (KeyFileDesktop.KEY_CATEGORIES);
            categories_entry.text = categories;
        } catch (GLib.KeyFileError e) {
            warning (e.message);
        }
        categories_entry.notify["text"].connect (() => {
            keyFile.keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_CATEGORIES, categories_entry.text);
        });
        categories_view.append (categories_entry);
        mainBox.append (categories_view);

        var terminal_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_start = 18,
            margin_end = 18,
            margin_bottom = 12
        };

        // checkbox
        var terminal_check = new Gtk.CheckButton.with_label (_("Run in Terminal"));
        terminal_check.hexpand = true;
        // connect to keyfile's terminal
        try {
            var terminal = keyFile.keyfile_get_bool (KeyFileDesktop.KEY_TERMINAL);
            terminal_check.active = terminal;
        } catch (GLib.KeyFileError e) {
            warning (e.message);
        }

        terminal_check.notify["active"].connect (() => {
            keyFile.keyfile.set_boolean (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TERMINAL, terminal_check.active);
        });
        terminal_view.append (terminal_check);

        mainBox.append (terminal_view);

        // finish up
        var controls = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            hexpand = true,
            homogeneous = true,
            margin_start = 18,
            margin_end = 18,
            margin_bottom = 18
        };

        var cancel_btn = new He.TextButton (_("Cancel"));
        cancel_btn.clicked.connect (() => {
            this.destroy ();
        });
        controls.append (cancel_btn);
        var save_btn = new He.FillButton (_("Save"));
        save_btn.clicked.connect (() => {
            keyFile.write_to_file ();
            this.destroy ();
        });
        controls.append (save_btn);

        mainBox.append (controls);

        var winhandle = new Gtk.WindowHandle ();
        winhandle.set_child (mainBox);

        child = winhandle;
    }
}