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
public class Fusebox.CategoryIcon : Gtk.ListBoxRow {
    public unowned Fusebox.Fuse fuse { get; construct; }

    public CategoryIcon (Fusebox.Fuse fuse) {
        Object (fuse: fuse);
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (fuse.icon) {
            pixel_size = 16,
            tooltip_text = fuse.description
        };

        var fuse_name = new Gtk.Label (fuse.display_name) {
            hexpand = true,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD_CHAR,
            xalign = 0
        };

        var layout = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 16);
        layout.append (icon);
        layout.append (fuse_name);
        layout.add_css_class ("mini-content-block");

        child = layout;

        fuse.notify["can-show"].connect (() => {
            changed ();
        });
    }
}
