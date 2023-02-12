/*
* Copyright (c) 2023 Fyra Labs
* Copyright (c) 2017-2020 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

namespace Mouse {
    public class LayoutPage : Gtk.Grid {
        private He.TextField entry_test;
        private SourceSettings settings;
        private Gtk.SizeGroup [] size_group;

        construct {
            settings = SourceSettings.get_instance ();

            size_group = {
                new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL),
                new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL)
            };
            // tree view to display the current layouts
            var display = new LayoutPageDisplay ();

            var switch_layout_label = new He.SettingsRow () {
                title = (_("Switch Layout"))
            };

            // Layout switching keybinding
            var modifier = new XkbModifier ("switch-layout");
            modifier.append_xkb_option ("", _("Disabled"));
            modifier.append_xkb_option ("grp:alt_caps_toggle", _("Alt + Caps Lock"));
            modifier.append_xkb_option ("grp:alt_shift_toggle", _("Alt + Shift"));
            modifier.append_xkb_option ("grp:alt_space_toggle", _("Alt + Space"));
            modifier.append_xkb_option ("grp:shifts_toggle", _("Both Shift keys together"));
            modifier.append_xkb_option ("grp:caps_toggle", _("Caps Lock"));
            modifier.append_xkb_option ("grp:ctrl_alt_toggle", _("Ctrl + Alt"));
            modifier.append_xkb_option ("grp:ctrl_shift_toggle", _("Ctrl + Shift"));
            modifier.append_xkb_option ("grp:shift_caps_toggle", _("Shift + Caps Lock"));
            modifier.set_default_command ("");
            settings.add_xkb_modifier (modifier);

            var switch_layout_combo = new XkbComboBox (modifier, size_group[1]);
            switch_layout_label.primary_button = (He.Button) switch_layout_combo;

            var compose_key_label = new He.SettingsRow () {
                title = (_("Compose Key"))
            };

            // Compose key position menu
            modifier = new XkbModifier ();
            modifier.append_xkb_option ("", _("Disabled"));
            modifier.append_xkb_option ("compose:caps", _("Caps Lock"));
            modifier.append_xkb_option ("compose:menu", _("Menu"));
            modifier.append_xkb_option ("compose:ralt", _("Right Alt"));
            modifier.append_xkb_option ("compose:rctrl", _("Right Ctrl"));
            modifier.append_xkb_option ("compose:rwin", _("Right Super"));
            modifier.set_default_command ("");
            settings.add_xkb_modifier (modifier);

            var compose_key_combo = new XkbComboBox (modifier, size_group[1]);
            compose_key_label.primary_button = (He.Button) compose_key_combo;

            var caps_lock_label = new He.SettingsRow () {
                title = (_("Caps Lock"))
            };

            // Caps Lock key functionality
            modifier = new XkbModifier ();
            modifier.append_xkb_option ("", _("Default"));
            modifier.append_xkb_option ("caps:none", _("Disabled"));
            modifier.append_xkb_option ("caps:backspace", _("as Backspace"));
            modifier.append_xkb_option ("ctrl:nocaps", _("as Ctrl"));
            modifier.append_xkb_option ("caps:escape", _("as Escape"));
            modifier.append_xkb_option ("caps:numlock", _("as Num Lock"));
            modifier.append_xkb_option ("caps:super", _("as Super"));
            modifier.append_xkb_option ("ctrl:swapcaps", _("Swap with Ctrl"));
            modifier.append_xkb_option ("caps:swapescape", _("Swap with Escape"));

            modifier.set_default_command ("");

            settings.add_xkb_modifier (modifier);

            var caps_lock_combo = new XkbComboBox (modifier, size_group[1]);

            caps_lock_label.primary_button = (He.Button) caps_lock_combo;

            entry_test = new He.TextField () {
                vexpand = true,
                valign = Gtk.Align.END
            };

            update_entry_test_usable ();

            var sep = new Gtk.Separator (Gtk.Orientation.VERTICAL);

            column_spacing = 12;
            row_spacing = 12;
            attach (display, 0, 0, 1, 4);
            attach (sep, 1, 0, 1, 4);
            attach (switch_layout_label, 2, 0, 1, 1);
            attach (compose_key_label, 2, 1, 1, 1);
            attach (caps_lock_label, 2, 2, 1, 1);
            attach (entry_test, 2, 3, 1, 1);

            settings.notify["active-index"].connect (() => {
                update_entry_test_usable ();
            });
        }

        private class XkbComboBox : Gtk.Box {
            public XkbComboBox (XkbModifier modifier, Gtk.SizeGroup size_group) {
                var cb = new Gtk.ComboBoxText ();

                cb.halign = Gtk.Align.START;
                cb.valign = Gtk.Align.CENTER;
                size_group.add_widget (cb);

                for (int i = 0; i < modifier.xkb_option_commands.length; i++) {
                    cb.append (modifier.xkb_option_commands[i], modifier.option_descriptions[i]);
                }

                cb.set_active_id (modifier.get_active_command ());

                cb.changed.connect (() => {
                    modifier.update_active_command (cb.active_id);
                });

                modifier.active_command_updated.connect (() => {
                    cb.set_active_id (modifier.get_active_command ());
                });

                append (cb);
            }
        }

        private class XkbOptionSwitch : Gtk.Box {
            public XkbOptionSwitch (SourceSettings settings, string xkb_command) {
                var sw = new Gtk.Switch ();
                sw.halign = Gtk.Align.START;
                sw.valign = Gtk.Align.CENTER;

                var modifier = new XkbModifier ("" + xkb_command);
                modifier.append_xkb_option ("", "option off");
                modifier.append_xkb_option (xkb_command, "option on");

                settings.add_xkb_modifier (modifier);

                if (modifier.get_active_command () == "") {
                    sw.active = false;
                } else {
                    sw.active = true;
                }

                sw.notify["active"].connect (() => {
                    if (sw.active) {
                        modifier.update_active_command (xkb_command);
                    } else {
                        modifier.update_active_command ("");
                    }
                });

                append (sw);
            }
        }

        private void update_entry_test_usable () {
            if (settings.active_input_source != null &&
                settings.active_input_source.layout_type == LayoutType.XKB) {

                entry_test.placeholder_text = _("Type to test your layout");
                entry_test.sensitive = true;
            } else {
                entry_test.placeholder_text = _("Input Method is active");
                entry_test.sensitive = false;
            }
        }
    }
}

class Mouse.XkbModifier : Object {
    public signal void active_command_updated ();

    public string gsettings_key { get; construct; }
    public string gsettings_schema { get; construct; }
    public string name { get; construct; }

    public string [] option_descriptions;
    public string [] xkb_option_commands;

    private GLib.Settings settings;
    private string active_command;
    private string default_command = "";

    public XkbModifier (string name = "",
                        string schem = "org.gnome.desktop.input-sources",
                        string key = "xkb-options") {
        Object (
            name: name,
            gsettings_schema: schem,
            gsettings_key: key
        );
    }

    construct {
        settings = new GLib.Settings (gsettings_schema);
        settings.changed[gsettings_key].connect (update_from_gsettings);
    }

    public string get_active_command () {
        if ( active_command == null ) {
            return default_command;
        } else {
            return active_command;
        }
    }

    public void update_from_gsettings () {
        string [] xkb_options = settings.get_strv (this.gsettings_key);
        bool found = false;
        foreach (string xkb_command in this.xkb_option_commands) {
            bool command_is_valid = true;
            if (xkb_command != "") {
                var com_arr = xkb_command.split (",", 4);
                foreach (string opt in com_arr) {
                    if (!(opt in xkb_options)) {
                        command_is_valid = false;
                    }
                }
                if (command_is_valid) {
                    update_active_command (xkb_command);
                    found = true;
                    break;
                }
            }
        }
        if (!found) {
            update_active_command (default_command);
        }
    }

    public void update_active_command ( string val ) {
        if (!(val in xkb_option_commands) || val == active_command) {
            return;
        }

        string old_opt = get_active_command ();
        if (val != active_command && val in xkb_option_commands) {
            active_command = val;
        }

        string [] new_xkb_options = {};
        string [] old_xkb_options = settings.get_strv (gsettings_key);
        var old_arr = old_opt.split (",", 4);
        var new_arr = val.split (",", 4);

        foreach (string xkb_command in old_xkb_options) {
            if (!(xkb_command in old_arr) || (xkb_command in new_arr)) {
                new_xkb_options += xkb_command;
            }
        }

        foreach (string xkb_command in new_arr) {
            if (!(xkb_command in new_xkb_options)) {
                new_xkb_options += xkb_command;
            }
        }

        settings.changed[gsettings_key].disconnect (update_from_gsettings);
        settings.set_strv (gsettings_key, new_xkb_options);
        settings.changed[gsettings_key].connect (update_from_gsettings);

        active_command_updated ();
    }

    public void set_default_command ( string val ) {
        if ( val in xkb_option_commands ) {
            default_command = val;
        } else {
            return;
        }
    }

    public void append_xkb_option (string xkb_command, string description) {
        xkb_option_commands += xkb_command;
        option_descriptions += description;
    }
}

class Mouse.SourceSettings : Object {
    public signal void external_layout_change ();

    public uint active_index { get; set; }

    public InputSource? active_input_source {
        get {
            if (active_index >= input_sources.length ()) {
                active_index = 0;
            }

            return input_sources.nth_data (active_index); //May be null if input source list empty
        }
    }

    // The ibus settings take precedence over the input-sources settings. On opening the plug, the input-sources are
    // synchronized with the ibus settings (which may have been changed by e.g. the IBus preferences app).
    private string[] _active_engines;
    public string[] active_engines {
        get {
            _active_engines = Mouse.Fuse.ibus_general_settings.get_strv ("preload-engines");
            return _active_engines;
        }

        set {
            Mouse.Fuse.ibus_general_settings.set_strv ("preload-engines", value);
            Mouse.Fuse.ibus_general_settings.set_strv ("engines-order", value);
            update_input_sources_ibus ();
        }
    }

    private GLib.List<InputSource> input_sources;

    private XkbModifier [] xkb_options_modifiers;
    private GLib.Settings settings;

    /**
     * True if and only if we are currently writing to gsettings
     * by ourselves.
     */
    private bool currently_writing;

    private static SourceSettings? instance;
    public static SourceSettings get_instance () {
        if (instance == null) {
            instance = new SourceSettings ();
        }
        return instance;
    }

    construct {
        input_sources = new GLib.List<InputSource> ();
    }

    private SourceSettings () {
        settings = new GLib.Settings ("org.gnome.desktop.input-sources");

        settings.changed["sources"].connect (() => {
            update_list_from_gsettings ();
            external_layout_change ();
        });

        settings.bind ("current", this, "active-index", SettingsBindFlags.DEFAULT);

        update_list_from_gsettings ();
    }

    private void update_list_from_gsettings () {
        // If we are currentlyly writing to gsettings, we don't need to read the list again from dconf
        if (currently_writing) {
            return;
        }

        reset (null);

        GLib.Variant sources = settings.get_value ("sources");
        if (sources.get_type ().dup_string () == "a(ss)") {
            for (size_t i = 0; i < sources.n_children (); i++) {
                GLib.Variant child = sources.get_child_value (i);
                add_layout_internal (InputSource.new_from_variant (child));
            }

            external_layout_change ();
        } else {
            warning ("GSettings sources of unexpected type");
        }

        add_default_keyboard_if_required ();
    }

    public void add_xkb_modifier (XkbModifier modifier) {
        //We assume by this point the modifier has all the options in it.
        modifier.update_from_gsettings ();
        xkb_options_modifiers += modifier;
    }

    private void switch_items (uint pos1, bool move_up) {
        var pos2 = move_up ? pos1 - 1 : pos1 + 1;
        unowned List<InputSource> container1 = input_sources.nth (pos1);
        unowned List<InputSource> container2 = input_sources.nth (pos2);
        /* We want to move the source relative to its own kind */
        var max_pos = input_sources.length () - 1;
        while (container1.data.layout_type != container2.data.layout_type) {
            pos2 = move_up ? pos2 - 1 : pos2 + 1;
            if (pos2 < 0 || pos2 > max_pos) {
                return;
            }

            container2 = input_sources.nth (pos2);
        }

        InputSource tmp = container1.data;
        container1.data = container2.data;
        container2.data = tmp;

        if (active_index == pos1) {
            active_index = pos2;
        } else if (active_index == pos2) {
            active_index = pos1;
        }

        write_to_gsettings ();
    }

    public void move_active_layout_up () {
        if (input_sources.length () == 0) {
            return;
        }

        // check that the active item is not the first one
        if (active_index > 0) {
            switch_items (active_index, true);
        }
    }

    public void move_active_layout_down () {
        if (input_sources.length () == 0)
            return;

        // check that the active item is not the last one
        if (active_index < input_sources.length () - 1) {
            switch_items (active_index, false);
        }
    }

    public void foreach_layout (GLib.Func<InputSource> func) {
        input_sources.foreach (func);
    }

    private void add_default_keyboard_if_required () {
        bool have_xkb = false;
        input_sources.@foreach ((source) => {
            if (source.layout_type == LayoutType.XKB) {
                have_xkb = true;
            }
        });

        if (!have_xkb) {
            var file = File.new_for_path ("/etc/default/keyboard");

            if (!file.query_exists ()) {
                warning ("File '%s' doesn't exist.\n", file.get_path ());
                return;
            }

            string xkb_layout = "";
            string xkb_variant = "";

            try {
                var dis = new DataInputStream (file.read ());

                string line;

                while ((line = dis.read_line (null)) != null) {
                    if (line.contains ("XKBLAYOUT=")) {
                        xkb_layout = line.replace ("XKBLAYOUT=", "").replace ("\"", "");

                        while ((line = dis.read_line (null)) != null) {
                            if (line.contains ("XKBVARIANT=")) {
                                xkb_variant = line.replace ("XKBVARIANT=", "").replace ("\"", "");
                            }
                        }

                        break;
                    }
                }
            }
            catch (Error e) {
                warning ("%s", e.message);
                return;
            }

            var variants = xkb_variant.split (",");
            var xkb_layouts = xkb_layout.split (",");

            for (int i = 0; i < xkb_layouts.length; i++) {
                if (variants[i] != null && variants[i] != "") {
                    add_layout_internal (InputSource.new_xkb (xkb_layouts[i], variants[i]));
                } else {
                    add_layout_internal (InputSource.new_xkb (xkb_layouts[i], null));
                }
            }

            write_to_gsettings ();
        }
    }

    public bool add_layout (InputSource? new_layout) {
        if (add_layout_internal (new_layout)) {
            write_to_gsettings ();
            return true;
        }

        return false;
    }

    public bool add_layout_internal (InputSource? new_layout) {
        if (new_layout == null) {
            return false;
        }

        int i = 0;
        foreach (InputSource l in input_sources) {
            if (l.equal (new_layout)) {
                return false;
            }

            i++;
        }

        input_sources.append (new_layout);
        return true;
    }

    public void remove_active_layout () {
        input_sources.remove (active_input_source);

        if (active_index >= 1) {
            active_index = input_sources.length () - 1;
        }

        add_default_keyboard_if_required ();

        write_to_gsettings ();
    }

    public void reset (LayoutType? layout_type, bool signal_changed = true) {
        var remove_layouts = new GLib.List<InputSource> ();
        input_sources.@foreach ((source) => {
            if (layout_type == null || layout_type == source.layout_type) {
                remove_layouts.append (source);
            }
        });

        remove_layouts.@foreach ((layout) => {
            input_sources.remove (layout);
        });
    }

    private void update_input_sources_ibus () {
        reset (LayoutType.IBUS, false);
        foreach (string engine_name in active_engines) {
            add_layout (InputSource.new_ibus (engine_name));
        }

        write_to_gsettings ();
    }

    private void write_to_gsettings () {
        currently_writing = true;
        try {
            Variant[] elements = {};
            List<InputSource> xkb_sources = null;
            List<InputSource> ibus_sources = null;
            input_sources.foreach ((input_source) => {
                if (input_source.layout_type == LayoutType.XKB) {
                    xkb_sources.append (input_source);
                } else {
                    ibus_sources.append (input_source);
                }
            });

            /* We want xkb sorted before ibus so as to match the layout of the wingpanel indicator and so <Alt><Shift>
             * cycles in the expected order. */

            xkb_sources.foreach ((input_source) => {elements += input_source.to_variant ();});
            ibus_sources.foreach ((input_source) => {elements += input_source.to_variant ();});

            GLib.Variant list = new GLib.Variant.array (new VariantType ("(ss)"), elements);
            settings.set_value ("sources", list);
        } finally {
            currently_writing = false;
        }
    }
}

namespace Mouse {

    /**
     * Type of a keyboard-InputSource as described in the description of
     * "org.gnome.desktop.input-sources sources".
     */
    public enum LayoutType { IBUS, XKB }

    /**
     * Immutable class that respresents a keyboard-InputSource according to
     * "org.gnome.desktop.input-sources sources".
     * This means that the enum parameter @layout_type equals the first string in the
     * tupel of strings, and the @name parameter equals the second string.
     */
    public class InputSource : Object {
        public static InputSource? new_xkb (string name, string? xkb_variant) {
            if (name == "") {
                critical ("Ignoring attempt to create invalid Xkb InputSource name %s", name);
                return null;
            }

            string full_name = name;
            if (xkb_variant != null && xkb_variant != "") {
                full_name += "+" + xkb_variant;
            }

            return new InputSource (LayoutType.XKB, full_name);
        }

        public static InputSource? new_ibus (string engine_name) {
            if (engine_name == "") {
                critical ("Ignoring attempt to create invalid IBus InputSource name %s", engine_name);
                return null;
            }

            return new InputSource (LayoutType.IBUS, engine_name);
        }

        public static InputSource? new_from_variant (Variant? variant) {
            if (variant.is_of_type (new VariantType ("(ss)"))) {
                unowned string type;
                unowned string name;

                variant.get ("(&s&s)", out type, out name);

                if (name != "") {
                    if (type == "xkb") {
                        return new InputSource (LayoutType.XKB, name);
                    } else if (type == "ibus") {
                        return new InputSource (LayoutType.IBUS, name);
                    }
                } else {
                    critical ("Attempt to create invalid InputSource name %s", name);
                }

            } else {
                critical ("Ignoring attempt to create InputSource from invalid VariantType");
            }

            return null;
        }

        public LayoutType layout_type { get; construct; }
        // Name of input source as stored in settings e.g. "gb" (xkb) or "xkb:gb:extd:eng" (ibus) or "mozc-jp" (ibus)
        // These names are used both in org/gnome/desktop/input-sources and desktop/ibus/general/preload-engines
        public string name { get; construct; }

        private InputSource (LayoutType layout_type, string name) {
            Object (
                layout_type: layout_type,
                name: name
            );
        }

        public bool equal (InputSource other) {
            return this.layout_type == other.layout_type && this.name == other.name;
        }

        /**
         * GSettings saves values in the form of GLib.Variant and this
         * function creates a Variant representing this object.
         */
        public GLib.Variant to_variant () requires (name != "") {
            string type_name = "";
            switch (layout_type) {
                case LayoutType.IBUS:
                    type_name = "ibus";
                    break;
                case LayoutType.XKB:
                    type_name = "xkb";
                    break;
                default:
                    assert_not_reached ();
            }
            GLib.Variant first = new GLib.Variant.string (type_name);
            GLib.Variant second = new GLib.Variant.string (name);
            GLib.Variant result = new GLib.Variant.tuple ({first, second});

            return result;
        }
    }
}