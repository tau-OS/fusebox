/*-
 * Copyright (c) 2022 Fyra Labs
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

public class Fusebox.SearchView : Gtk.Box {
    private Gtk.SearchEntry search_entry;
    private Gtk.ListBox listbox;

    construct {
        var alert_view = new He.EmptyPage () {
            description = _("Try changing search terms."),
            icon = "edit-find-symbolic"
        };
        alert_view.action_button.visible = false;

        unowned FuseboxApp app = (FuseboxApp) GLib.Application.get_default ();

        search_entry = app.search_box;

        listbox = new Gtk.ListBox () {
            margin_start = 18,
            margin_end = 18,
            margin_bottom = 18
        };
        listbox.add_css_class ("content-list");
        listbox.selection_mode = Gtk.SelectionMode.BROWSE;
        listbox.set_filter_func (filter_func);
        listbox.set_placeholder (alert_view);

        var clamp = new Bis.Latch () {
            child = listbox
        };

        var scrolled = new Gtk.ScrolledWindow () {
            child = clamp
        };

        append (scrolled);

        load_fuses.begin ();

        search_entry.search_changed.connect (() => {
            alert_view.title = _("No Results for “%s”").printf (search_entry.text);
            listbox.invalidate_filter ();
            listbox.select_row (null);
        });

        listbox.row_activated.connect ((row) => {
            app.load_setting_path (
                                   ((SearchRow) row).uri.replace ("settings://", ""),
                                   Fusebox.FusesManager.get_default ()
            );
            search_entry.text = "";
        });
    }

    public void activate_first_item () {
        listbox.get_row_at_y (0).activate ();
    }

    private bool filter_func (Gtk.ListBoxRow listbox_row) {
        var search_text = search_entry.text;
        if (search_text == "" || search_text == null) {
            return true;
        }

        return search_text.down () in ((SearchRow) listbox_row).description.down ();
    }

    private async void load_fuses () {
        var fuses_manager = Fusebox.FusesManager.get_default ();
        foreach (var fuse in fuses_manager.get_fuses ()) {
            var settings = fuse.supported_settings;
            if (settings == null || settings.size () <= 0) {
                continue;
            }

            string uri = settings.get_keys_as_array ()[0];

            var search_row = new SearchRow (
                                            fuse.icon,
                                            fuse.display_name,
                                            uri
            );
            listbox.append (search_row);

            // Using search to get sub settings
            var search_results = yield fuse.search ("");

            foreach (var key in search_results.get_keys_as_array ()) {
                unowned string title = key;
                var view = search_results.lookup (key);

                // get uri from fuse's supported_settings
                // Use main fuse uri as fallback
                string sub_uri = uri;
                if (view != "") {
                    foreach (var setting_key in settings.get_keys_as_array ()) {
                        if (settings.lookup (setting_key) == view) {
                            sub_uri = setting_key;
                            break;
                        }
                    }
                }

                search_row = new SearchRow (
                                            fuse.icon,
                                            title,
                                            (owned) sub_uri
                );
                listbox.append (search_row);
            }
        }
    }

    private class SearchRow : Gtk.ListBoxRow {
        public string icon_name { get; construct; }
        public string description { get; construct; }
        public string uri { get; construct; }

        public SearchRow (string icon_name, string description, string uri) {
            Object (
                    description: description,
                    icon_name: icon_name,
                    uri: uri
            );
        }

        construct {
            var image = new Gtk.Image.from_icon_name (icon_name) {
                pixel_size = 16
            };

            var label = new Gtk.Label (description) {
                ellipsize = Pango.EllipsizeMode.MIDDLE
            };

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            box.append (image);
            box.append (label);

            child = box;
            add_css_class ("fuse-block");
            margin_bottom = 6;
        }
    }
}