/*
 * Copyright (c) 2022 Fyra Labs
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 */

public class DateTime.WeatherLocation : Object {
    public GWeather.Location loc { get; construct set; }
    public bool selected { get; set; }

    public WeatherLocation (GWeather.Location loc, bool selected) {
        Object (loc: loc, selected: selected);
    }
}

public class DateTime.LocationRow : Gtk.ListBoxRow {
    public DateTime.WeatherLocation data { get; construct set; }

    public string? lname { get; set; default = null; }
    public string? location { get; set; default = null; }
    public bool loc_selected { get; set; default = false; }

    public Gtk.Box main_box;

    public LocationRow (DateTime.WeatherLocation data) {
        Object (data: data);

        lname = data.loc.get_name ();
        location = "(" + data.loc.get_timezone_str ().replace ("_", " ") + ")";
        data.bind_property ("selected", this, "loc-selected", SYNC_CREATE);

        var loc_label = new Gtk.Label (lname);
        loc_label.halign = Gtk.Align.START;
        loc_label.add_css_class ("cb-title");
        var loc_ct_label = new Gtk.Label (location);
        loc_ct_label.halign = Gtk.Align.START;
        loc_ct_label.add_css_class ("cb-subtitle");

        var loc_icon = new Gtk.Image.from_icon_name ("list-add-symbolic");
        loc_icon.halign = Gtk.Align.END;
        loc_icon.visible = data.selected ? true : false;

        var loc_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        loc_box.append (loc_label);
        loc_box.append (loc_ct_label);
        loc_box.append (loc_icon);

        main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        main_box.add_css_class ("mini-content-block");
        main_box.append (loc_box);

        this.set_child (main_box);

        data.bind_property ("selected", this, "loc-selected", SYNC_CREATE);
    }
}

public class DateTime.WorldLocationFinder : Gtk.Box {
    private ListStore locations;
    private const int RESULT_COUNT_LIMIT = 6;

    private DateTime.LocationRow? _selected_row = null;
    public DateTime.LocationRow? selected_row {
        get {
            return _selected_row;
        } set {
            _selected_row = value;
        }
    }

    private He.EmptyPage search_label;
    private Gtk.Stack search_stack;
    private Gtk.ListBox listbox;
    private Gtk.SearchEntry search_entry;
    private He.Button add_button;

    construct {
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);

        search_entry = new Gtk.SearchEntry () {
            halign = Gtk.Align.START
        };

        search_stack = new Gtk.Stack () {
            margin_top = 12,
            margin_bottom = 12,
            vhomogeneous = true,
            vexpand = true,
            transition_type = Gtk.StackTransitionType.CROSSFADE
        };

        search_label = new He.EmptyPage () {
            title = _("No Location Searched"),
            description = _("Search for a location."),
            icon = "location-services-disabled-symbolic",
            margin_top = 18,
            margin_bottom = 18
        };

        listbox = new Gtk.ListBox () {
            valign = Gtk.Align.START,
            selection_mode = Gtk.SelectionMode.NONE
        };
        listbox.add_css_class ("content-list");

        search_stack.add_named (search_label, "empty");
        search_stack.add_named (listbox, "results");

        add_button = new He.Button ("", "") {
            margin_bottom = 18,
            is_pill = true,
            label = _("Add Location")
        };

        var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        content_box.append (search_entry);
        content_box.append (search_stack);

        main_box.append (content_box);

        append (main_box);
        search_entry.set_key_capture_widget (this);
        add_button.sensitive = false;
        locations = new ListStore (typeof (DateTime.WeatherLocation));
        listbox.bind_model (locations, (data) => {
            return new DateTime.LocationRow ((DateTime.WeatherLocation) data);
        });
        listbox.row_activated.connect (item_activated);
        add_button.clicked.connect (add_button_clicked);

        search_entry.search_changed.connect (() => {
            selected_row = null;

            // Remove old results
            locations.remove_all ();

            if (search_entry.text == "") {
                return;
            }

            string search = search_entry.text.normalize ().casefold ();
            var world = GWeather.Location.get_world ();
            if (world == null) {
                return;
            }

            query_locations ((GWeather.Location) world, search);

            if (locations.get_n_items () == 0) {
                return;
            }
            locations.sort ((a, b) => {
                var name_a = ((DateTime.WeatherLocation) a).loc.get_sort_name ();
                var name_b = ((DateTime.WeatherLocation) b).loc.get_sort_name ();
                return strcmp (name_a, name_b);
            });
            search_stack.visible_child_name = "results";
        });
        search_entry.notify["text"].connect (() => {
            if (search_entry.text == "")
                search_stack.visible_child_name = "empty";
        });
        search_label.action_button.visible = false;
    }

    public signal void location_added ();

    private void add_button_clicked () {
        location_added ();
    }

    private void query_locations (GWeather.Location lc, string search) {
        if (locations.get_n_items () >= RESULT_COUNT_LIMIT) return;

        switch (lc.get_level ()) {
        case CITY:
            var contains_name = lc.get_sort_name ().contains (search);

            var country_name = lc.get_country_name ();
            if (country_name != null) {
                country_name = ((string) country_name).normalize ().casefold ();
            }
            var contains_country_name = country_name != null && ((string) country_name).contains (search);

            if (contains_name || contains_country_name) {
                bool selected = location_exists (lc);
                locations.append (new DateTime.WeatherLocation (lc, selected));
            }
            return;
        default:
            break;
        }

        var l = lc.next_child (null);
        while (l != null) {
            query_locations (l, search);
            if (locations.get_n_items () >= RESULT_COUNT_LIMIT) {
                return;
            }
            l = lc.next_child (l);
        }
    }

    public bool location_exists (GWeather.Location loc) {
        var exists = false;
        var n = locations.get_n_items ();
        for (int i = 0; i < n; i++) {
            var l = locations.get_object (i);
            if (l == loc) {
                exists = true;
                break;
            }
        }

        return exists;
    }

    public GWeather.Location? get_selected_location () {
        if (selected_row == null)
            return null;
        return ((DateTime.LocationRow) selected_row).data.loc;
    }

    private void item_activated (Gtk.ListBoxRow listbox_row) {
        var row = (DateTime.LocationRow) listbox_row;

        if (selected_row != null && selected_row != row) {
            ((DateTime.LocationRow) selected_row).data.selected = false;
        }

        row.data.selected = !row.data.selected;
        if (row.data.selected) {
            selected_row = row;
        } else {
            selected_row = null;
        }

        add_button.sensitive = true;
    }
}