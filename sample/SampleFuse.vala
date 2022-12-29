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

public class Sample.Fuse : Fusebox.Fuse {
    private Gtk.Grid main_grid;
    private Gtk.Label hello_label;
    private Gtk.Label view_label;

    public Fuse () {
        Object (category: Category.SYSTEM,
                code_name: "sample-fuse",
                display_name: _("Sample Fuse"),
                description:_("Does nothing, nya!"),
                icon: "system-run",
                supported_settings: new Gee.TreeMap<string, string?> (null, null));
        supported_settings.set ("wallpaper", null);
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            main_grid = new Gtk.Grid ();
            main_grid.margin_start = 18;
            main_grid.margin_end = 18;
            main_grid.row_spacing = 12;
            view_label = new Gtk.Label ("Sample Fuse");
            view_label.add_css_class ("view-title");
            hello_label = new Gtk.Label ("Hello World!");
            hello_label.halign = Gtk.Align.START;
            main_grid.attach (view_label, 0, 0, 1, 1);
            main_grid.attach (hello_label, 0, 1, 1, 1);
        }

        return main_grid;
    }

    public override void shown () {

    }

    public override void hidden () {

    }

    public override void search_callback (string location) {
    }

    // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
    public override async Gee.TreeMap<string, string> search (string search) {
        return new Gee.TreeMap<string, string> (null, null);
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating Sample fuse");
    var fuse = new Sample.Fuse ();
    return fuse;
}
