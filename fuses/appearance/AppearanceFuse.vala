public class Appearance.Fuse : Fusebox.Fuse {
    private const string ACCENTS = "accents";
    private const string WALLPAPER = "wallpaper";
    private const string DOCK = "dock";
    private Gtk.Grid main_grid;
    private Gtk.Stack main_stack;

    private AppearanceView appearance_view;

    public Fuse () {
        var settings = new GLib.HashTable<string, string?> (null, null);
        settings.set ("appearance", null);
        settings.set ("appearance/accents", ACCENTS);
        settings.set ("appearance/wallpaper", WALLPAPER);
        settings.set ("appearance/dock", DOCK);

        Object (
                category: Category.PERSONAL,
                code_name: "com.fyralabs.Fusebox.Appearance",
                display_name: _("Appearance"),
                description: _("Theme, accent color, background"),
                icon: "settings-appearance-symbolic",
                supported_settings: settings,
                index: 0
        );

        Bis.init ();
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            appearance_view = new AppearanceView (this);

            main_grid = new Gtk.Grid ();
            main_grid.attach (appearance_view, 0, 1);
        }

        return main_grid;
    }

    public override void shown () {
        appearance_view.wallpaper_view.update_wallpaper_folder.begin ();
    }

    public override void hidden () {
        appearance_view.wallpaper_view.cancel_thumbnail_generation.begin ();
    }

    public override void search_callback (string location) {
        switch (location) {
        case ACCENTS:
            main_stack.set_visible_child_name ("desktop");
            break;
        case WALLPAPER:
            appearance_view.wallpaper_stack.set_visible_child_name ("wallpaper");
            break;
        case DOCK:
            // TODO: Implement dock view when ready
            break;
        default:
            main_stack.set_visible_child_name ("desktop");
            break;
        }
    }

    public override async GLib.HashTable<string, string> search (string search) {
        var search_results = new GLib.HashTable<string, string> (
                                                                 null, null
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
