public class Locale.Fuse : Fusebox.Fuse {
    private const string LOCALE = "locale";
    private Gtk.Grid main_grid;

    public Fuse () {
        var settings = new GLib.HashTable<string, string?> (null, null);
        settings.set ("locale", null);

        Object (
            category: Category.PERSONAL,
            code_name: "co.tauos.Fusebox.Locale",
            display_name: _("Locale"),
            description: _("Change system locale"),
            icon: "settings-locale",
            supported_settings: settings,
            index: 2
        );
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            var locale_view = new LocaleView ();

            var view_label = new Gtk.Label ("Locale") {
                halign = Gtk.Align.START,
                margin_start = 18
            };
            view_label.add_css_class ("view-title");

            main_grid = new Gtk.Grid () {
                row_spacing = 12
            };
            main_grid.attach (view_label, 0, 0);
            main_grid.attach (locale_view, 0, 1);
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

        search_results.set ("%s → %s".printf (display_name, _("Locale")), LOCALE);

        return search_results;
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating Locale Fuse");
    var fuse = new Locale.Fuse ();
    return fuse;
}