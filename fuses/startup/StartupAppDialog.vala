public class StartupAppDialog : He.Window {
    public Startup.Backend.KeyFile keyFile { get; set construct; }
    private Startup.Backend.KeyFile kf { get; set; }

    private Gtk.Box mainBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);

    construct {
        // we dupe the keyfile so we do not actually segfault
        //  kf = keyFile.get_instance ();


        this.modal = true;
        var title = new Gtk.Label (_("Edit Startup Entry"));
        title.add_css_class ("view-title");
        mainBox.append (title);

        var icon_btn = new Gtk.Button ();
        // TODO: lains: do icon sizing
        var btn_content = new He.ButtonContent ();
        // var icon = new Gtk.Image ();
        icon_btn.set_child (btn_content);

        mainBox.append (icon_btn);


        // settings content
        var name_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

        var name_label = new Gtk.Label (_("Name"));
        name_label.add_css_class ("cb-title");
        name_view.append (name_label);

        var name_entry = new Gtk.Entry ();
        name_entry.hexpand = true;
        name_view.append (name_entry);

        // connect to keyfile's name

        // keyfile desktop entry object group of keyfile
        // var kf = keyFile.keyfile.get_keys (KeyFileDesktop.GROUP);
        //  name_entry.bind_property ("text", keyFile, "name", GLib.BindingFlags.BIDIRECTIONAL);

        // get text
        // !? segfault????
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
        var command_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

        var command_label = new Gtk.Label (_("Execute"));
        command_label.add_css_class ("cb-title");
        command_view.append (command_label);

        var command_entry = new Gtk.Entry ();
        command_entry.hexpand = true;
        command_entry.bind_property ("text", keyFile, "Exec", GLib.BindingFlags.BIDIRECTIONAL);
        command_view.append (command_entry);

        mainBox.append (command_view);


        // finish up
        var controls = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        controls.hexpand = true;
        controls.halign = Gtk.Align.CENTER;

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

        child = mainBox;
    }
}