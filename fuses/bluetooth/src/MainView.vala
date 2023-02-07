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
public class Bluetooth.MainView : He.Bin {
    private Gtk.ListBox list_box;
    public Services.ObjectManager manager { get; construct set; }
    public signal void quit_fuse ();

    public MainView (Services.ObjectManager manager) {
        Object (
                manager: manager
        );
    }

    construct {
        var empty_alert = new He.EmptyPage () {
            icon = "eye-not-looking-symbolic",
            title = _("No Devices Found"),
            description = _("Please ensure that your devices are visible and ready for pairing.")
        };
        empty_alert.action_button.visible = false;

        list_box = new Gtk.ListBox ();
        list_box.add_css_class ("content-list");
        list_box.set_sort_func ((Gtk.ListBoxSortFunc) compare_rows);
        list_box.set_header_func ((Gtk.ListBoxUpdateHeaderFunc) title_rows);
        list_box.set_placeholder (empty_alert);
        list_box.selection_mode = Gtk.SelectionMode.NONE;
        list_box.margin_start = 18;
        list_box.margin_end = 18;

        var scrolled = new Gtk.ScrolledWindow () {
            child = list_box,
            hexpand = true,
            vexpand = true
        };

        var clamp = new Bis.Latch () {
            hexpand = true
        };
        clamp.set_child (scrolled);

        clamp.set_parent (this);

        this.vexpand = true;

        if (manager.retrieve_finished) {
            complete_setup ();
        } else {
            manager.notify["retrieve-finished"].connect (complete_setup);
        }
    }

    private void complete_setup () {
        foreach (var device in manager.get_devices ()) {
            var adapter = manager.get_adapter_from_path (device.adapter);
            var row = new DeviceRow (device, adapter);
            list_box.append (row);
        }

        var first_row = list_box.get_row_at_index (0);
        if (first_row != null) {
            list_box.select_row (first_row);
            list_box.row_activated (first_row);
        }

        /* Now retrieve finished, we can connect manager signals */
        manager.device_added.connect ((device) => {
            var adapter = manager.get_adapter_from_path (device.adapter);
            var row = new DeviceRow (device, adapter);
            list_box.append (row);
            if (list_box.get_selected_row () == null) {
                list_box.select_row (row);
                list_box.row_activated (row);
            }
        });

        manager.device_removed.connect_after ((device) => {
            var child = list_box.get_first_child ();
            while (child != null) {
                if (((DeviceRow) child).device == device) {
                    list_box.remove (child);
                    break;
                }

                child = child.get_next_sibling ();
            }
        });

        manager.adapter_removed.connect ((adapter) => {
            if (!manager.has_object) {
                quit_fuse ();
            }
        });
    }

    [CCode (instance_pos = -1)]
    private int compare_rows (DeviceRow row1, DeviceRow row2) {
        unowned Services.Device device1 = row1.device;
        unowned Services.Device device2 = row2.device;
        if (device1.paired && !device2.paired) {
            return -1;
        }

        if (!device1.paired && device2.paired) {
            return 1;
        }

        if (device1.connected && !device2.connected) {
            return -1;
        }

        if (!device1.connected && device2.connected) {
            return 1;
        }

        if (device1.name != null && device2.name == null) {
            return -1;
        }

        if (device1.name == null && device2.name != null) {
            return 1;
        }

        var name1 = device1.name ?? device1.address;
        var name2 = device2.name ?? device2.address;
        return name1.collate (name2);
    }

    [CCode (instance_pos = -1)]
    private void title_rows (DeviceRow row1, DeviceRow? row2) {
        if (row2 == null && row1.device.paired) {
            var label = new Gtk.Label (_("My Devices"));
            label.halign = Gtk.Align.START;
            label.margin_top = 12;
            label.add_css_class ("heading");
            label.add_css_class ("dim-label");
            row1.set_header (label);
        } else if (row2 == null || row1.device.paired != row2.device.paired) {
            var label = new Gtk.Label (_("Nearby Devices"));
            label.halign = Gtk.Align.START;
            label.margin_top = 12;
            label.add_css_class ("heading");
            label.add_css_class ("dim-label");
            row1.set_header (label);
        } else {
            row1.set_header (null);
        }
    }
}