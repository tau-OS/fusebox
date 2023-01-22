/*
 * Copyright (c) 2023 Fyra Labs
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
public class Bluetooth.Fuse : Fusebox.Fuse {
    private Gtk.Grid main_grid;
    private Gtk.Switch status_switch;
    private He.AppBar appbar;
    private Services.ObjectManager manager;

    public Fuse () {
        var settings = new GLib.HashTable<string, string?> (null, null);
        settings.set ("bluetooth", null);

        Object (
            category: Category.NETWORK,
            code_name: "co.tauos.Fusebox.Bluetooth",
            display_name: _("Bluetooth"),
            description: _("Configure Bluetooth Settings"),
            icon: "settings-bluetooth-symbolic",
            supported_settings: settings,
            index: 0
        );

        manager = new Bluetooth.Services.ObjectManager ();
        manager.bind_property ("is-powered", status_switch, "active", GLib.BindingFlags.DEFAULT);

        manager.adapter_added.connect ((adapter) => {
            update_description ();
        });

        manager.adapter_removed.connect ((adapter) => {
            if (manager.has_object) {
                update_description ();
            }
        });

        manager.notify["discoverable"].connect (() => {
            update_description ();
        });

        manager.notify["is-powered"].connect (() => {
            update_description ();
        });
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            var main_view = new MainView (manager);
            main_view.quit_fuse.connect (() => hidden ());

            status_switch = new Gtk.Switch () {
                hexpand = true,
                halign= Gtk.Align.END
            };
            status_switch.active = manager.is_powered;
            status_switch.notify["active"].connect (() => {
                manager.set_global_state.begin (status_switch.active);
            });

            var view_label = new Gtk.Label ("Bluetooth") {
                halign = Gtk.Align.START
            };
            view_label.add_css_class ("view-title");

            var view_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            view_box.append (view_label);
            view_box.append (status_switch);

            appbar = new He.AppBar () {
                viewtitle_widget = view_box,
                show_back = false,
                hexpand = true,
            };

            main_grid = new Gtk.Grid () {
                row_spacing = 12,
            };
            main_grid.attach (appbar, 0, 0);
            main_grid.attach (main_view, 0, 1);
        }

        return main_grid;
    }

    public override void shown () {
        manager.register_agent.begin (main_grid.get_root () as Gtk.Window);
        manager.set_global_state.begin (true);
    }

    public override void hidden () {
        Application.get_default ().hold ();
        manager.unregister_agent.begin ();
        manager.discoverable = false;
        manager.stop_discovery.begin (() => {
            Application.get_default ().release ();
        });
    }

    public override void search_callback (string location) {

    }

    public override async GLib.HashTable<string, string> search (string search) {
        var search_results = new GLib.HashTable<string, string> (
            null, null
        );

        return search_results;
    }

    // extra
    private void update_description () {
        string? name = manager.get_name ();
        var powered = manager.is_powered;
        if (powered && manager.discoverable) {
            //TRANSLATORS: \"%s\" represents the name of the adapter
            appbar.viewsubtitle_label = _("Now discoverable as \"%s\".").printf (name ?? _("Unknown"));
        } else if (!powered) {
            appbar.viewsubtitle_label = _("Not discoverable while Bluetooth is powered off.");
        } else {
            appbar.viewsubtitle_label = _("Not discoverable.");
        }
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating Bluetooth fuse");
    var fuse = new Bluetooth.Fuse ();
    return fuse;
}