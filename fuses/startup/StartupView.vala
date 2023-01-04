public class StartupView : Gtk.Box {

    public Fusebox.Fuse fuse { get; construct; }

    public StartupView (Fusebox.Fuse _fuse) {
        Object (fuse: _fuse);
    }


    construct {

        // container for everything
        var mbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        mbox.margin_start = 24;


        // the actual list to contain the startup apps
        var list = new Gtk.ListBox ();
        list.set_show_separators (true);
        list.selection_mode = Gtk.SelectionMode.SINGLE;
        // example app
        var app_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        app_box.selection_mode = Gtk.SelectionMode.SINGLE;
        var app_icon = new Gtk.Image () {
            icon_name = "org.gnome.Nautilus",
            pixel_size = 48
        };
        app_box.append (app_icon);

        var label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        label_box.halign = Gtk.Align.START;
        var app_name = new Gtk.Label ("Nautilus");
        app_name.add_css_class ("cb-title");
        app_name.halign = Gtk.Align.START;
        label_box.append (app_name);
        var app_desc = new Gtk.Label ("File Manager");
        app_desc.add_css_class ("cb-subtitle");
        app_desc.halign = Gtk.Align.START;
        label_box.append (app_desc);

        app_box.append (label_box);

        // toggle switch at the end of the box
        var app_switch = new Gtk.Switch ();
        app_switch.halign = Gtk.Align.END;
        app_switch.hexpand = true;

        app_switch.valign = Gtk.Align.CENTER;
        app_box.append (app_switch);


        var app_row = new Gtk.ListBoxRow ();
        app_row.set_child (app_box);

        list.append (app_row);




        mbox.append (list);

        mbox.add_css_class ("mini-content-block");

        var clamp = new Bis.Latch ();
        clamp.set_child (mbox);

        // return the thing
        append (clamp);
        //

    }
}