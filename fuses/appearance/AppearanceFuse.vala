public class Appearance.Fuse : Fusebox.Fuse {
    private const string ACCENTS = "accents";
    private const string WALLPAPER = "wallpaper";
    private Gtk.Grid main_grid;

    public Fuse () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("appearance", null);
        settings.set ("appearance/accents", ACCENTS);
        settings.set ("appearance/wallpaper", WALLPAPER);

        Object (
            category: Category.PERSONAL,
            code_name: "co.tauos.Fusebox.Appearance",
            display_name: _("Appearance"),
            description: _("Choose an accent color and change wallpaper"),
            icon: "applications-graphics-symbolic",
            supported_settings: settings
        );

        Bis.init ();
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            var appearance_view = new AppearanceView ();

            main_grid = new Gtk.Grid () {
                row_spacing = 12
            };
            main_grid.attach (appearance_view, 0, 0);
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

        search_results.set ("%s → %s".printf (display_name, _("Accent Color")), ACCENTS);
        search_results.set ("%s → %s".printf (display_name, _("Wallpaper")), WALLPAPER);

        return search_results;
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating Appearance Fuse");
    var fuse = new Appearance.Fuse ();
    return fuse;
}