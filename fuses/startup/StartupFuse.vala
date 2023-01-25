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
 * //////////////////////////////////////////////////////////////////////////
 *
 * Fusebox startup applications fuse (plugin)
 *
 * Author: Pornpipat "Cappy" Popum <cappy@cappuchino.xyz>
 * This file is part of Fusebox.
 *
 * This Fusebox fuse manages startup applications.
 * These startup applications are in XDG autostart format. See
 * https://specifications.freedesktop.org/autostart-spec/autostart-spec-latest.html
 * for more information.
 * This fuse allows users to add, remove and edit startup applications.
 * It also allows the ablity to create a custom startup shortcut with custom commands and arguments.
 *
 * The XDG autostart parser is based on code from elementary OS's Startup Applications plug.
 */

public class Startup.Fuse : Fusebox.Fuse {
    private const string STARTUP = "startup";
    private Gtk.Grid main_grid;
    public Fuse () {
        var settings = new GLib.HashTable<string, string?> (null, null);
        settings.set ("startup", STARTUP);
        Object (
            category: Category.SYSTEM,
            code_name: "co.tauos.Fusebox.Startup",
            display_name: _("App Autostart"),
            description: _("Manage applications that start automatically"),
            icon: "settings-applications-symbolic",
            supported_settings: settings,
            index: 6
        );
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            var startup_view = new StartupView(this);
            main_grid = new Gtk.Grid () {
                row_spacing = 12
            };

            var view_label = new Gtk.Label ("App Autostart") {
                halign = Gtk.Align.START
            };
            view_label.add_css_class ("view-title");

            var appbar = new He.AppBar () {
                viewtitle_widget = view_label,
                show_back = false
            };

            main_grid.attach (appbar, 0, 0);
            main_grid.attach (startup_view, 0, 1);


        }

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

    public override async GLib.HashTable<string, string> search (string search) {
        var search_results = new GLib.HashTable<string, string> (
            null, null
        );

        search_results.set ("%s → %s".printf (display_name, _("Startup")), STARTUP);

        return search_results;
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating Startup Fuse");
    var fuse = new Startup.Fuse ();
    return fuse;
}