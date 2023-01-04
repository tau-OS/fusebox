public class StartupView : Gtk.Box {

    public Fusebox.Fuse fuse { get; construct; }

    public StartupView (Fusebox.Fuse _fuse) {
        Object (fuse: _fuse);
    }

    // TODO: load gsettings to show system apps
    public bool show_system_apps { get; set construct; }


    construct {

        // container for everything
        var mbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        mbox.margin_start = 24;


        // the actual list to contain the startup apps
        var list = new Gtk.ListBox ();
        list.set_show_separators (true);

        // set spacing between rows
        // gtk4
        list.set_header_func ((row, before) => {
            if (before != null) {
                row.set_margin_top (6);
            } else {
                row.set_margin_bottom (6);
            }
        });

        list.set_selection_mode(Gtk.SelectionMode.SINGLE);


        //  // example apps
        //  var app1 = new AppEntry () {
        //      app_name = "Nautilus",
        //      app_desc = "File Manager",
        //      app_icon = "org.gnome.Nautilus",
        //      app_enabled = true
        //  };
        //  var app_row = app1.into_row ();

        //  list.append (app_row);

        //  var app2 = new AppEntry () {
        //      app_name = "Terminal",
        //      app_desc = "Terminal Emulator",
        //      app_icon = "org.gnome.Terminal",
        //      app_enabled = false
        //  };
        //  var app_row2 = app2.into_row ();
        
        //  list.append (app_row2);
        var approw = get_startup_apps ();

        foreach (var row in approw) {
            list.append (row);
        }


        var lbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        lbox.add_css_class ("mini-content-block");
        lbox.append (list);

        var clamp = new Bis.Latch ();

        var overlay = new He.OverlayButton ("", null, null);
        overlay.icon = "list-add-symbolic";
        overlay.child = (lbox);

        clamp.child = (overlay);

        mbox.append (clamp);

        // return the thing

        append (mbox);
        //

    }
}


private class AppEntry : Gtk.Box {
    public string app_name { get; set construct;}
    public string app_desc { get; set construct;}
    public string app_icon { get; set construct;}
    public bool app_enabled { get; set construct;}

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;
        spacing = 6;

        var icon = new Gtk.Image () {
            icon_name = app_icon,
            pixel_size = 48
        };
        append (icon);

        notify["app-icon"].connect (() => {
            icon.icon_name = create_icon (app_icon);
        });

        var label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        label_box.halign = Gtk.Align.START;
        var name = new Gtk.Label (app_name);
        name.add_css_class ("cb-title");
        name.halign = Gtk.Align.START;
        label_box.append (name);

        notify["app-name"].connect (() => {
            name.label = app_name;
        });

        var desc = new Gtk.Label (app_desc);
        desc.add_css_class ("cb-subtitle");
        desc.halign = Gtk.Align.START;
        label_box.append (desc);

        notify["app-desc"].connect (() => {
            desc.label = app_desc;
        });

        append (label_box);

        // toggle switch at the end of the box
        var app_switch = new Gtk.Switch ();
        app_switch.halign = Gtk.Align.END;
        app_switch.hexpand = true;
        app_switch.valign = Gtk.Align.CENTER;
        app_switch.active = app_enabled;
        append (app_switch);


        // delete button

        var delete_button = new Gtk.Button ();
        delete_button.add_css_class ("flat");
        delete_button.add_css_class ("destructive-action");

        var delete_icon = new Gtk.Image () {
            icon_name = "list-remove-symbolic",
            pixel_size = 16
        };
        delete_button.set_child (delete_icon);
        append (delete_button);


        notify["app-enabled"].connect (() => {
            app_switch.active = app_enabled;
        });

    }

    // function to wrap in a row
    public Gtk.ListBoxRow into_row () {
        var row = new Gtk.ListBoxRow ();
        row.set_child (this);
        return row;
    }
}

public string create_icon (string iconname) {


    var icon_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
    if (icon_theme.has_icon (iconname)) {
        return iconname;
    } else {
        return "application-default-icon";
    }
}

private Gtk.ListBoxRow[] get_startup_apps () {
    var rows = new Gtk.ListBoxRow[0];

    // get the app list
    foreach (unowned string path in Startup.Utils.get_autostart_files ()) {
        print ("path: %s\n", path);

        // load keyfile from path

        var keyfile = new Startup.Backend.KeyFile (path);

        var appinfo = keyfile.create_app_info ();

        print ("name: %s\n", appinfo.name);

        var app = new AppEntry () {
            app_name = appinfo.name,
            app_desc = appinfo.comment,
            app_icon = appinfo.icon,
            app_enabled = appinfo.active,
        };
        var row = app.into_row ();
        rows += row;
    }
    return rows;
}