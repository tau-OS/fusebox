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
        public Fusebox.Fuse.Category category { get; construct; }

        private Gtk.ListBox flowbox;

        public Category (Fusebox.Fuse.Category category) {
            Object (category: category);
        }

        construct {
            var category_label = new Gtk.Label (Fusebox.CategoryView.get_category_name (category));
            category_label.halign = Gtk.Align.START;
            category_label.add_css_class ("heading");

            flowbox = new Gtk.ListBox () {
                activate_on_single_click = true,
                selection_mode = Gtk.SelectionMode.NONE
            };
            flowbox.add_css_class ("content-list");

            valign = Gtk.Align.START;
            spacing = 6;
            orientation = Gtk.Orientation.VERTICAL;

            append (category_label);
            append (flowbox);

            flowbox.row_activated.connect ((child) => {
                ((FuseboxApp) GLib.Application.get_default ()).load_fuse (((CategoryIcon) child).fuse);
            });

            flowbox.set_sort_func (fuse_sort_func);
        }

        public GLib.List<Fuse?> get_fuses () {
            var fuses = new GLib.List<Fuse?> ();

            var child = flowbox.get_first_child ();
            while (child != null) {
                fuses.append (((CategoryIcon) child).fuse);
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

        private int fuse_sort_func (Gtk.ListBoxRow child_a, Gtk.ListBoxRow child_b) {
            var fuse_name_a = ((CategoryIcon) child_a).fuse.display_name;
            var fuse_name_b = ((CategoryIcon) child_b).fuse.display_name;

            return strcmp (fuse_name_a, fuse_name_b);
        }
    }
}
