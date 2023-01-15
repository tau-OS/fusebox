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

    public class CategoryView : Gtk.Box {
        public FusesSearch fuse_search { get; construct; }
        public unowned GLib.List<SearchEntry?> fuse_search_result { get; construct; }
        public Fusebox.Category category { get; construct; }

        public string? fuse_to_open { get; construct set; default = null; }

        private Gtk.Stack stack;
        private He.EmptyPage alert_view;

        construct {
            alert_view = new He.EmptyPage ();

            category = new Fusebox.Category ();

            fuse_search = new FusesSearch ();
            fuse_search_result = new GLib.List<SearchEntry?> ();

            var category_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
                margin_start = 18,
                margin_end = 18,
                margin_bottom = 18
            };
            category_box.append (category);

            var category_scrolled = new Gtk.ScrolledWindow () {
                child = category_box,
                hscrollbar_policy = Gtk.PolicyType.NEVER
            };

            stack = new Gtk.Stack ();
            stack.add_child (alert_view);
            stack.add_named (category_scrolled, "category-grid");

            append (stack);
        }

        public CategoryView (string? fuse = null) {
            Object (fuse_to_open: fuse);
        }

        public void show_alert (string primary_text, string secondary_text, string icon_name) {
            alert_view.title = primary_text;
            alert_view.description = secondary_text;
            alert_view.icon = icon_name;

            stack.visible_child = alert_view;
        }

        public async void load_default_fuses () {
            var fusesmanager = Fusebox.FusesManager.get_default ();
            fusesmanager.fuse_added.connect ((fuse) => {
                add_fuse (fuse);
            });

            Idle.add (() => {
                foreach (var fuse in fusesmanager.get_fuses ()) {
                    add_fuse (fuse);
                }

                return false;
            });
        }

        public void add_fuse (Fusebox.Fuse fuse) {
            var icon = new Fusebox.CategoryIcon (fuse);

            category.add (icon);

            var any_found = false;

            if (category.has_child ()) {
                any_found = true;
            }

            if (any_found) {
                stack.visible_child_name = "category-grid";
            }

            if (fuse_to_open != null && fuse_to_open.has_suffix (fuse.code_name)) {
                unowned var app = (FuseboxApp) GLib.Application.get_default ();
                app.load_fuse (fuse);
                fuse_to_open = null;
            }
        }

        public static string? get_category_name (Fusebox.Fuse.Category category) {
            switch (category) {
                case Fuse.Category.PERSONAL:
                    return _("Personal");
                case Fuse.Category.NETWORK:
                    return _("Connections");
                case Fuse.Category.SYSTEM:
                    return _("System");
                case Fuse.Category.CUSTOM:
                    return _("Miscellaneous");
            }

            return null;
        }
    }
}
