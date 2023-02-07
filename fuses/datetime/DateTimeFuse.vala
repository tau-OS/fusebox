public class DateTime.Fuse : Fusebox.Fuse {
    private Gtk.Grid main_grid;

    public Fuse () {
        var settings = new GLib.HashTable<string, string?> (null, null);
        settings.set ("DateTime", null);

        Object (
                category: Category.SYSTEM,
                code_name: "co.tauos.Fusebox.DateTime",
                display_name: _("Date & Time"),
                description: _("Setup time and date"),
                icon: "settings-time-symbolic",
                supported_settings: settings,
                index: 1
        );

        Bis.init ();
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            var datetime_view = new DateTimeView ();

            var view_label = new Gtk.Label (_("Date & Time")) {
                halign = Gtk.Align.START
            };
            view_label.add_css_class ("view-title");

            var appbar = new He.AppBar () {
                viewtitle_widget = view_label,
                show_back = false,
                flat = true
            };

            main_grid = new Gtk.Grid () {
                row_spacing = 12
            };
            main_grid.attach (appbar, 0, 0);
            main_grid.attach (datetime_view, 0, 1);
        }

        return main_grid;
    }

    public override void shown () {
    }

    public override void hidden () {
    }

    public override void search_callback (string location) {
        switch (location) {
        //
        }
    }

    public override async GLib.HashTable<string, string> search (string search) {
        var search_results = new GLib.HashTable<string, string> (
                                                                 null, null
        );

        search_results.set ("%s → %s".printf (display_name, _("Date")), "date");
        search_results.set ("%s → %s".printf (display_name, _("Time")), "time");

        return search_results;
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating DateTime Fuse");
    var fuse = new DateTime.Fuse ();
    return fuse;
}