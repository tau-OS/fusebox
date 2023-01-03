public class About.Fuse : Fusebox.Fuse {
    private const string OS = "operating-system";
    private Gtk.Grid main_grid;

    public Fuse () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("about", null);
        settings.set ("about/os", OS);

        Object (
            category: Category.SYSTEM,
            code_name: "co.tauos.Fusebox.About",
            display_name: _("About"),
            description: _("View OS information"),
            icon: "dialog-information-symbolic",
            supported_settings: settings
        );
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            var os_view = new OSView ();

            var view_label = new Gtk.Label ("About") {
                halign = Gtk.Align.START,
                margin_start = 18
            };
            view_label.add_css_class ("view-title");

            main_grid = new Gtk.Grid () {
                row_spacing = 12
            };
            main_grid.attach (view_label, 0, 0);
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

    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> (
            (GLib.CompareDataFunc<string>)strcmp,
            (Gee.EqualDataFunc<string>)str_equal
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
