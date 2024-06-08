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
            pixel_size = 24,
        };

        var fuse_name = new Gtk.Label (fuse.display_name) {
            hexpand = true,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD_CHAR,
            xalign = 0
        };
        fuse_name.add_css_class ("cb-title");

        var fuse_description = new Gtk.Label (fuse.description) {
            hexpand = true,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD_CHAR,
            xalign = 0
        };
        fuse_name.add_css_class ("cb-subtitle");

        var text_layout = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            valign = Gtk.Align.CENTER,
            margin_top = 6,
            margin_bottom = 6
        };
        text_layout.append (fuse_name);
        text_layout.append (fuse_description);

        var layout = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 16);
        layout.append (icon);
        layout.append (text_layout);
        layout.add_css_class ("mini-content-block");

        child = layout;

        fuse.notify["can-show"].connect (() => {
            changed ();
        });
    }
}
