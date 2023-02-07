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

namespace Fusebox {
    public struct SearchEntry {
        string fuse_name;
        string ui_elements;
        string open_window;
    }

    public class FusesSearch {
        public GLib.List<SearchEntry?> search_entries;
        public bool ready {get; private set;}

        public FusesSearch () {
            ready = false;
            search_entries = new GLib.List<SearchEntry?> ();
            cache_search_entries.begin ((obj, res) => {
                cache_search_entries.end (res);
                ready = true;
            });
        }

        // key ("%s → %s".printf (display_name, _("Network Time")))
        public async void cache_search_entries () {
            var fusesmanager = Fusebox.FusesManager.get_default ();

            foreach (var fuse in fusesmanager.get_fuses ()) {
                var tmp_entries = yield fuse.search ("");

                foreach (var key in tmp_entries.get_keys_as_array ()) {
                    string [] tmp = key.split (" → ");
                    SearchEntry tmp_entry = SearchEntry ();
                    tmp_entry.fuse_name = tmp[0];
                    string ui_elements_name = key;
                    tmp_entry.ui_elements = ui_elements_name;
                    tmp_entry.open_window = tmp_entries.lookup(key);
                    search_entries.append (tmp_entry);
                    debug ("FusesSearch: add open window: %s ", tmp_entry.open_window);
                    debug ("FusesSearch: add ui elements: %s ", tmp_entry.ui_elements);
                    debug ("FusesSearch: add fuse name: %s ", tmp_entry.fuse_name);
                }
            }
        }
    }
}
