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

public class Mouse.Fuse : Fusebox.Fuse {
    private Gtk.Grid main_grid;
    private Gtk.Stack stack;

    public static GLib.Settings ibus_general_settings;
    static construct {
        ibus_general_settings = new GLib.Settings ("org.freedesktop.ibus.general");
    }

    public Fuse () {
        Object (
            category: Category.SYSTEM,
            code_name: "mouse-fuse",
            display_name: _("Mouse & Keyboard"),
            description:_("Settings for mice, keyboards and touchpads."),
            icon: "settings-mouse-symbolic",
            supported_settings: new GLib.HashTable<string, string?> (null, null),
            index: 5
        );
        supported_settings.set ("input/pointer", "clicking");
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            var mouse_view = new MouseView ();
            var touchpad_view = new TouchpadView ();
            var keyboard_view = new KeyboardView ();

            stack = new Gtk.Stack () {
                margin_bottom = 24,
                margin_start = 24,
                margin_end = 24,
                vhomogeneous = false,
                transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
                transition_duration = 400
            };
            var stack_switcher = new He.ViewSwitcher () {
                stack = stack
            };
            stack.add_titled (mouse_view, "mouse", _("Mouse"));
            stack.add_titled (touchpad_view, "touchpad", _("Touchpad"));
            stack.add_titled (keyboard_view, "keyboard", _("Keyboard"));

            var appbar = new He.AppBar () {
                viewtitle_widget = stack_switcher,
                show_back = false,
                show_left_title_buttons = false,
                show_right_title_buttons = true
            };

            main_grid = new Gtk.Grid () {
                row_spacing = 12
            };
            main_grid.attach (appbar, 0, 0);
            main_grid.attach (stack, 0, 1);
        }

        return main_grid;
    }

    public override void shown () {

    }

    public override void hidden () {

    }

    public override void search_callback (string location) {
        switch (location) {
            case "touchpad":
                stack.set_visible_child_name ("touchpad");
                break;
            case "mouse":
            default:
                stack.set_visible_child_name ("mouse");
                break;
        }
    }

    // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
    public override async GLib.HashTable<string, string> search (string search) {
        var search_results = new GLib.HashTable<string, string> (null, null);

        search_results.set ("%s → %s".printf (display_name, _("Primary button")), "clicking");
        search_results.set ("%s → %s".printf (display_name, _("Mouse")), "mouse");
        search_results.set ("%s → %s → %s".printf (display_name, _("Mouse"), _("Pointer speed")), "mouse");
        search_results.set ("%s → %s → %s".printf (display_name, _("Mouse"), _("Pointer acceleration")), "mouse");
        search_results.set ("%s → %s → %s".printf (display_name, _("Mouse"), _("Natural scrolling")), "mouse");

        return search_results;
    }
}

public Fusebox.Fuse get_fuse (Module module) {
    debug ("Activating Mouse fuse");
    var fuse = new Mouse.Fuse ();
    return fuse;
}
