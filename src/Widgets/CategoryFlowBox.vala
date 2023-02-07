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
    public class Category : Gtk.Box {
        private Gtk.ListBox flowbox;

        construct {
            flowbox = new Gtk.ListBox () {
                activate_on_single_click = true,
                selection_mode = Gtk.SelectionMode.BROWSE
            };
            flowbox.add_css_class ("content-list");
            flowbox.set_sort_func (sort_function);
            flowbox.set_header_func (header_function);

            valign = Gtk.Align.START;
            spacing = 6;
            orientation = Gtk.Orientation.VERTICAL;

            append (flowbox);

            flowbox.row_activated.connect ((child) => {
                ((FuseboxApp) GLib.Application.get_default ()).load_fuse (((CategoryIcon) child).fuse);
            });
        }

        private void header_function (Gtk.ListBoxRow row1, Gtk.ListBoxRow? row2) {
            // Type-check Rows
            if (row1 is CategoryIcon && (row2 == null || row2 is CategoryIcon)) {
                var name1 = ((CategoryIcon) row1).fuse.category.to_string ().replace ("FUSEBOX_FUSE_CATEGORY_", "");
                var name2 = row2 != null ? (
                    (CategoryIcon) row2).fuse.category.to_string ().replace ("FUSEBOX_FUSE_CATEGORY_", "") : null;
                string header_string = null;

                if (name1 != "") {
                    header_string = name1;
                } else {
                    header_string = "";
                }

                if (name2 != null) {
                    if (name2 == header_string) {
                        return;
                    }
                }

                if (header_string == null) {
                    return;
                } else {
                    var header_label = new Gtk.Label (header_string) {
                        halign = Gtk.Align.START,
                        margin_bottom = 6,
                        margin_top = 6
                    };
                    header_label.add_css_class ("heading");
                    header_label.add_css_class ("dim-label");
                    row1.set_header (header_label);
                }
            }
        }

        [CCode (instance_pos = -1)]
        private int sort_function (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
            var name1 = ((CategoryIcon) row1).fuse.category.to_string ().replace ("FUSEBOX_FUSE_CATEGORY_", "");
            var name2 = ((CategoryIcon) row2).fuse.category.to_string ().replace ("FUSEBOX_FUSE_CATEGORY_", "");

            if (name1 != null) {
                if (name2 == null) {
                    return -1;
                }
            } else if (name2 != null) {
                return 1;
            }

            return name1.collate (name2);
        }

        public GLib.List<Fuse?> get_fuses () {
            var fuses = new GLib.List<Fuse?> ();

            var child = flowbox.get_first_child ();
            while (child != null) {
                fuses.insert (((CategoryIcon) child).fuse, ((CategoryIcon) child).fuse.index);
                child = child.get_next_sibling ();
            }

            return fuses;
        }

        public new void add (Gtk.Widget widget) {
            flowbox.append (widget);
        }

        public bool has_child () {
            var child = flowbox.get_first_child ();
            while (child != null) {
                if (child.get_child_visible ()) {
                    show ();
                    return true;
                }

                child = child.get_next_sibling ();
            }

            hide ();
            return false;
        }
    }
}
