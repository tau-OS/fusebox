/*-
 * Copyright (c) 2023 Fyra Labs
 * Copyright (c) 2015-2016 elementary LLC.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

// XDG Autostart manager

public class Startup.Fuse : Fusebox.Fuse {
    private const string STARTUP = "startup";
    private Gtk.Grid main_grid;
    public Fuse () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("startup", STARTUP);
        Object (
            category: Category.SYSTEM,
            code_name: "co.tauos.Fusebox.Startup",
            display_name: _("Startup Applications"),
            description: _("Manage applications that start automatically"),
            icon: "system-run-symbolic",
            supported_settings: settings
        );
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            main_grid = new Gtk.Grid ();
        }

        // add some text
        var label = new Gtk.Label (_("Manage applications that start automatically"));
        label.get_style_context ().add_class ("h2");
        label.set_halign (Gtk.Align.START);
        label.set_margin_top (12);
        label.set_margin_bottom (12);
        label.set_margin_start (12);
        label.set_margin_end (12);
        main_grid.attach (label, 0, 0, 1, 1);

        return main_grid;
    }

    public override void shown() {
    }

    public override void hidden() {
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

        //  search_results.set ("%s → %s".printf (display_name, _("About")), OS);
        //  search_results.set ("%s → %s".printf (display_name, _("Report A Problem")), OS);

        return search_results;
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating Startup Fuse");
    var fuse = new Startup.Fuse ();
    return fuse;
}