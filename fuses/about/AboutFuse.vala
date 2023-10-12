public class About.Fuse : Fusebox.Fuse {
    private const string OS = "operating-system";
    private Gtk.Grid main_grid;

    public Fuse () {
        var settings = new GLib.HashTable<string, string?> (null, null);
        settings.set ("about", null);
        settings.set ("about/os", OS);

        Object (
                category: Category.SYSTEM,
                code_name: "com.fyralabs.Fusebox.About",
                display_name: _("About"),
                description: _("View OS information"),
                icon: "settings-about-symbolic",
                supported_settings: settings,
                index: 5
        );
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            var os_view = new OSView ();

            var view_label = new Gtk.Label ("About") {
                halign = Gtk.Align.START
            };
            view_label.add_css_class ("view-title");

            var appbar = new He.AppBar () {
                viewtitle_widget = view_label,
                show_back = false,
                show_left_title_buttons = false,
                show_right_title_buttons = true
            };

            main_grid = new Gtk.Grid () {
                row_spacing = 12
            };
            main_grid.attach (appbar, 0, 0);
            main_grid.attach (os_view, 0, 1);
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

        search_results.set ("%s → %s".printf (display_name, _("About")), OS);
        search_results.set ("%s → %s".printf (display_name, _("Report A Problem")), OS);

        return search_results;
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating About Fuse");
    var fuse = new About.Fuse ();
    return fuse;
}
