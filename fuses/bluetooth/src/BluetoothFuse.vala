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
    private He.SwitchBar status_switch;
    private He.AppBar appbar;
    private Services.ObjectManager manager;

    public Fuse () {
        var settings = new GLib.HashTable<string, string?> (null, null);
        settings.set ("bluetooth", null);

        Object (
                category: Category.NETWORK,
                code_name: "com.fyralabs.Fusebox.Bluetooth",
                display_name: _("Bluetooth"),
                description: _("Connections, transfer, sharing"),
                icon: "settings-bluetooth-symbolic",
                supported_settings: settings,
                index: 0
        );

        manager = new Bluetooth.Services.ObjectManager ();
    }

    private void connect_manager () {
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

            status_switch = new He.SwitchBar () {
                hexpand = true,
                title = (_("Bluetooth"))
            };
            status_switch.main_switch.iswitch.active = manager.is_powered;
            status_switch.main_switch.iswitch.notify["active"].connect (() => {
                manager.set_global_state.begin (status_switch.main_switch.iswitch.active);
            });

            appbar = new He.AppBar () {
                viewtitle_widget = status_switch,
                show_back = false,
                show_left_title_buttons = false,
                show_right_title_buttons = true
            };

            main_grid = new Gtk.Grid () {
                row_spacing = 12,
            };
            main_grid.attach (appbar, 0, 0);
            main_grid.attach (main_view, 0, 1);
        }

        connect_manager ();

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
            // TRANSLATORS: \"%s\" represents the name of the adapter
            status_switch.subtitle = _("Now discoverable as \"%s\".").printf (name ?? _("Unknown"));
        } else if (!powered) {
            status_switch.subtitle = _("Not discoverable while Bluetooth is powered off.");
        } else {
            status_switch.subtitle = _("Not discoverable.");
        }
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating Bluetooth fuse");
    var fuse = new Bluetooth.Fuse ();
    return fuse;
}
