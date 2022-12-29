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

public abstract class Fusebox.Fuse : GLib.Object {
    public enum Category {
        NETWORK = 0,
        PERSONAL = 1,
        SYSTEM = 2
    }

    /**
     * The common used separator.
     */
    public const string SEP = "<sep>";

    /**
     * The category under which the Fuse will be stored.
     * 
     * Possible {@link Category} values are PERSONAL, HARDWARE, NETWORK or SYSTEM.
     */
    public Category category { get; construct; }

    /**
     * The unique name representing the Fuse.
     * 
     * It is also used to recognise it with the open-fuse command.
     */
    public string code_name { get; construct; }

    /**
     * The localised name of the Fuse.
     */
    public string display_name { get; construct; }

    /**
     * A short description of the Fuse.
     */
    public string description { get; construct; }

    /**
     * The icon representing the Fuse.
     */
    public string icon { get; construct; }

    /**
     * A map of settings:// endpoints and location to pass to the
     * {@link search_callback} method if the value is not %NULL.
     * For example {"input/keyboard", "keyboard"}.
     */
    public Gee.TreeMap<string, string?> supported_settings { get; construct; default = new Gee.TreeMap<string, string?> (null, null); }

    /**
     * Inform if the Fuse should be shown or not
     */
    public bool can_show { get; set; default=true; }

    /**
     * Inform the application that the Fuse can now be listed in the available Fuses.
     * The application will also listen to the notify::can-show signal.
     *
     * @deprecated: The changing {@link can_show} activate the notify::can-show signal.
     */
    public signal void visibility_changed ();

    /**
     * Returns the widget that contain the whole interface.
     *
     * @return a {@link Gtk.Widget} containing the interface.
     */
    public abstract Gtk.Widget get_widget ();

    /**
     * Called when the Fuse appears to the user.
     */
    public abstract void shown ();

    /**
     * Called when the Fuse disappear to the user.
     * 
     * This is not called when the Fuse got destroyed or the window is closed, use ~Fuse () instead.
     */
    public abstract void hidden ();

    /**
     * This function should return the widget that contain the whole interface.
     * 
     * When the user click on an action, the second parameter is send to the {@link search_callback} method
     * 
     * @param search a {@link string} that represent the search.
     * @return a {@link Gee.TreeMap} containing two strings like {"Keyboard → Behavior → Duration", "keyboard<sep>behavior"}.
     */
    public abstract async Gee.TreeMap<string, string> search (string search);

    /**
     * This function is used when the user click on a search result, it should show the selected setting (right tab…).
     * 
     * @param location a {@link string} that represents the setting to show.
     */
    public abstract void search_callback (string location);
}
