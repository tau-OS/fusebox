public class Accounts.Fuse : Fusebox.Fuse {
    private const string ACCOUNTS = "accounts";
    private Gtk.Grid main_grid;

    public Fuse () {
        var settings = new GLib.HashTable<string, string?> (null, null);
        settings.set ("accounts", null);

        Object (
                category: Category.PERSONAL,
                code_name: "co.tauos.Fusebox.Accounts",
                display_name: _("Accounts"),
                description: _("Manage user accounts"),
                icon: "settings-users-symbolic",
                supported_settings: settings,
                index: 2
        );
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            var accounts_view = new AccountsView ();

            var view_label = new Gtk.Label ("Accounts") {
                halign = Gtk.Align.START
            };
            view_label.add_css_class ("view-title");

            var appbar = new He.AppBar () {
                viewtitle_widget = view_label,
                show_back = false,
                hexpand = true,
            };

            main_grid = new Gtk.Grid () {
                row_spacing = 12,
            };
            main_grid.attach (appbar, 0, 0);
            main_grid.attach (accounts_view, 0, 1);
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

        search_results.set ("%s → %s".printf (display_name, _("Locale")), ACCOUNTS);

        return search_results;
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating Locale Fuse");
    var fuse = new Accounts.Fuse ();
    return fuse;
}