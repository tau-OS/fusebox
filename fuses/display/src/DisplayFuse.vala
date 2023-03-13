/*-
 * Copyright (c) 2023 Fyra Labs
 * Copyright (c) 2014-2018 elementary LLC.
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this software; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

public class Display.Fuse : Fusebox.Fuse {
    public static Fuse fuse;
    private Gtk.Grid main_grid;

    public Fuse () {
        var settings = new GLib.HashTable<string, string?> (null, null);
        settings.set ("display", null);
        settings.set ("display/night-light", "night-light");

        Object (
            category: Category.SYSTEM,
            code_name: "com.fyralabs.Fusebox.display",
            display_name: _("Displays"),
            description: _("Configure resolution and position of monitors and projectors"),
            icon: "settings-display-symbolic",
            supported_settings: settings,
            index: 2
        );
        fuse = this;
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            main_grid = new Gtk.Grid () {
                row_spacing = 12,
                column_homogeneous = true
            };
            var displays_view = new DisplaysView ();

            var nightlight_view = new NightLightView ();

            var latch2 = new Bis.Latch ();
            latch2.set_child (nightlight_view);

            var stack = new Gtk.Stack ();
            var stack_switcher = new He.ViewSwitcher ();
            stack_switcher.stack = stack;

            stack.add_titled (displays_view, "displays", _("Displays"));
            stack.add_titled (latch2, "night-light", _("Night Light"));

            var appbar = new He.AppBar () {
                viewtitle_widget = stack_switcher,
                show_back = false,
                hexpand = true,
            };
            main_grid.attach (appbar, 0, 0);
            main_grid.attach (stack, 0, 1);
        }

        return main_grid;
    }

    public override void shown () {
    }

    public override void hidden () {
    }

    public override void search_callback (string location) {
    }

    // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
    public override async GLib.HashTable<string, string> search (string search) {
        var search_results = new GLib.HashTable<string, string> (null, null);
        search_results.set ("%s → %s".printf (display_name, _("Screen Resolution")), "");
        search_results.set ("%s → %s".printf (display_name, _("Screen Rotation")), "");
        search_results.set ("%s → %s".printf (display_name, _("Primary display")), "");
        search_results.set ("%s → %s".printf (display_name, _("Screen mirroring")), "");
        search_results.set ("%s → %s".printf (display_name, _("Scaling factor")), "");
        search_results.set ("%s → %s".printf (display_name, _("Rotation lock")), "");
        search_results.set ("%s → %s".printf (display_name, _("Night Light")), "night-light");
        search_results.set ("%s → %s → %s".printf (display_name, _("Night Light"), _("Schedule")), "night-light");
        search_results.set ("%s → %s → %s".printf (display_name, _("Night Light"), _("Color temperature")), "night-light");
        return search_results;
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating Display fuse");
    var fuse = new Display.Fuse ();
    return fuse;
}
