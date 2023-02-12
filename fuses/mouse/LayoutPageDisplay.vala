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

// widget to display/add/remove/move keyboard layouts
public class Mouse.LayoutPageDisplay : Gtk.Frame {
    private SourceSettings settings;
    private Gtk.TreeView tree;
    private He.IconicButton up_button;
    private He.IconicButton down_button;
    private He.IconicButton add_button;
    private He.IconicButton remove_button;

    /*
     * Set to true when the user has just clicked on the list to prevent
     * layouts.active_changed triggering update_cursor
     */
    private bool cursor_changing = false;

    construct {
        settings = SourceSettings.get_instance ();

        var cell = new Gtk.CellRendererText () {
            ellipsize_set = true,
            ellipsize = Pango.EllipsizeMode.END
        };

        tree = new Gtk.TreeView () {
            vexpand = true,
            tooltip_column = 0
        };
        tree.insert_column_with_attributes (-1, "Layouts", cell, "text", 0);

        var scroll = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true,
        };
        scroll.set_child (tree);

        add_button = new He.IconicButton ("list-add-symbolic") {
            tooltip_text = _("Add…")
        };

        remove_button = new He.IconicButton ("list-remove-symbolic") {
            sensitive = false,
            tooltip_text = _("Remove")
        };

        up_button = new He.IconicButton ("go-up-symbolic") {
            sensitive = false,
            tooltip_text = _("Move up")
        };

        down_button = new He.IconicButton ("go-down-symbolic") {
            sensitive = false,
            tooltip_text = _("Move down")
        };

        var bottom_bar = new He.BottomBar ();
        bottom_bar.append_button (add_button, He.BottomBar.Position.LEFT);
        bottom_bar.append_button (remove_button, He.BottomBar.Position.LEFT);
        bottom_bar.append_button (up_button, He.BottomBar.Position.RIGHT);
        bottom_bar.append_button (down_button, He.BottomBar.Position.RIGHT);

        var grid = new Gtk.Grid ();
        grid.attach (scroll, 0, 0);
        grid.attach (bottom_bar, 0, 1);

        set_child (grid);

        add_button.clicked.connect (() => {
            var dialog = new AddLayoutDialog (He.Misc.find_ancestor_of_type<He.ApplicationWindow> (this));
            dialog.present ();

            dialog.layout_added.connect ((layout, variant) => {
                settings.add_layout (InputSource.new_xkb (layout, variant));
                rebuild_list ();
            });
        });

        remove_button.clicked.connect (() => {
            settings.remove_active_layout ();
            rebuild_list ();
        });

        up_button.clicked.connect (() => {
            settings.move_active_layout_up ();
            rebuild_list ();
        });

        down_button.clicked.connect (() => {
            settings.move_active_layout_down ();
            rebuild_list ();
        });

        tree.cursor_changed.connect_after (() => {
            cursor_changing = true;

            int new_index = get_cursor_index ();
            if (new_index >= 0) {
                settings.active_index = new_index;
            }

            update_buttons ();

            cursor_changing = false;
        });

        settings.notify["active-index"].connect (() => {
            update_cursor ();
        });

        settings.external_layout_change.connect (rebuild_list);

        rebuild_list ();
    }

    private void update_buttons () {
        int rows = tree.model.iter_n_children (null);
        int index = get_cursor_index ();


        up_button.sensitive = (rows > 1 && index != 0);
        down_button.sensitive = (rows > 1 && index < rows - 1);
        remove_button.sensitive = (rows > 0);
    }

    private int get_cursor_index () {
        Gtk.TreePath path;

        tree.get_cursor (out path, null);

        if (path == null) {
            return -1;
        }

        Gtk.TreeIter iter;
        tree.model.get_iter (out iter, path);
        uint index;
        tree.model.get (iter, 2, out index, -1);
        return (int)index;
    }

    private void update_cursor () {
        if (cursor_changing || settings.active_input_source == null) {
            return;
        }

        tree.set_cursor (new Gtk.TreePath (), null, false);
        if (settings.active_input_source.layout_type == LayoutType.XKB) {
            uint index = 0;
            tree.model.foreach ((model, path, iter) => {
                tree.model.get (iter, 2, out index);
                if (index == settings.active_index) {
                    tree.set_cursor (path, null, false);
                    return true;
                }

                return false;
            });
        }
    }

    private void rebuild_list () {
        var list_store = new Gtk.ListStore (3, typeof (string), typeof (string), typeof (uint));
        Gtk.TreeIter? iter = null;
        uint index = 0;
        settings.foreach_layout ((input_source) => {
            if (input_source.layout_type == LayoutType.XKB) {
                list_store.append (out iter);
                list_store.set (iter, 0, XkbLayoutHandler.get_instance ().get_display_name (input_source.name));
                list_store.set (iter, 1, input_source.name);
                list_store.set (iter, 2, index);
            }

            index++;
        });

        tree.model = list_store;
        update_cursor ();
        update_buttons ();
    }
}

public class Mouse.XkbLayoutHandler : GLib.Object {
    private const string XKB_RULES_FILE = "evdev.xml";

    private static XkbLayoutHandler? instance = null;

    public static XkbLayoutHandler get_instance () {
        if (instance == null) {
            instance = new XkbLayoutHandler ();
        }

        return instance;
    }

    public HashTable<string, string> languages { get; private set; }

    private XkbLayoutHandler () {}

    construct {
        languages = new HashTable<string, string> (str_hash, str_equal);

        Xml.Doc* doc = Xml.Parser.parse_file (get_xml_rules_file_path ());
        if (doc == null) {
            critical ("'%s' not found or permissions missing\n", XKB_RULES_FILE);
            return;
        }

        Xml.XPath.Context cntx = new Xml.XPath.Context (doc);
        Xml.XPath.Object* res = cntx.eval_expression ("/xkbConfigRegistry/layoutList/layout/configItem");

        if (res == null) {
            delete doc;
            critical ("Unable to parse '%s'", XKB_RULES_FILE);
            return;
        }

        if (res->type != Xml.XPath.ObjectType.NODESET || res->nodesetval == null) {
            delete res;
            delete doc;
            critical ("No layouts found in '%s'", XKB_RULES_FILE);
            return;
        }

        for (int i = 0; i < res->nodesetval->length (); i++) {
            Xml.Node* node = res->nodesetval->item (i);
            string? name = null;
            string? description = null;
            for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
                if (iter->type == Xml.ElementType.ELEMENT_NODE) {
                    if (iter->name == "name") {
                        name = iter->get_content ();
                    } else if (iter->name == "description") {
                        description = dgettext ("xkeyboard-config", iter->get_content ());
                    }
                }
            }
            if (name != null && description != null) {
                languages.set (name, description);
            }
        }

        delete res;
        delete doc;
    }

    private string get_xml_rules_file_path () {
        unowned string? base_path = GLib.Environment.get_variable ("XKB_CONFIG_ROOT");
        if (base_path == null) {
            base_path = "/usr/share/X11/xkb";
        }

        return Path.build_filename (base_path, "rules", XKB_RULES_FILE);
    }

    public HashTable<string, string> get_variants_for_language (string language) {
        var returned_table = new HashTable<string, string> (str_hash, str_equal);
        returned_table.set ("", _("Default"));

        string file_path = get_xml_rules_file_path ();
        Xml.Doc* doc = Xml.Parser.parse_file (file_path);
        if (doc == null) {
            critical ("'%s' not found or permissions incorrect\n", XKB_RULES_FILE);
            return returned_table;
        }

        Xml.XPath.Context cntx = new Xml.XPath.Context (doc);
        var xpath = @"/xkbConfigRegistry/layoutList/layout/configItem/name[text()='$language']/../../variantList/variant/configItem";//vala-lint=line-leng //vala-lint=line-length
        Xml.XPath.Object* res = cntx.eval_expression (xpath);

        if (res == null) {
            delete doc;
            critical ("Unable to parse '%s'", XKB_RULES_FILE);
            return returned_table;
        }

        if (res->type != Xml.XPath.ObjectType.NODESET || res->nodesetval == null) {
            delete res;
            delete doc;
            warning (@"No variants for $language found in '%s'", XKB_RULES_FILE);
            return returned_table;
        }

        for (int i = 0; i < res->nodesetval->length (); i++) {
            Xml.Node* node = res->nodesetval->item (i);

            string? name = null;
            string? description = null;
            for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
                if (iter->type == Xml.ElementType.ELEMENT_NODE) {
                    if (iter->name == "name") {
                        name = iter->get_content ();
                    } else if (iter->name == "description") {
                        description = dgettext ("xkeyboard-config", iter->get_content ());
                    }
                }
            }
            if (name != null && description != null) {
                returned_table.set (name, description);
            }
        }

        delete res;
        delete doc;

        return returned_table;
    }

    public string get_display_name (string variant) {
        if ("+" in variant) {
            var parts = variant.split ("+", 2);
            return get_variants_for_language (parts[0]).get (parts[1]);
        } else {
            return languages.get (variant);
        }
    }
}

public class Mouse.AddLayoutDialog : He.Window {
    private const string INPUT_LANGUAGE = N_("Input Language");
    private const string LAYOUT_LIST = N_("Layout List");

    public signal void layout_added (string language, string layout);
    private Gtk.ListBox input_language_list_box;
    private Gtk.ListBox layout_list_box;
    private GLib.ListStore language_list;
    private GLib.ListStore layout_list;
    private XkbLayoutHandler handler;

    private string layout_id;

    public AddLayoutDialog (He.ApplicationWindow parent) {
        this.parent = parent;
    }

    construct {
        default_height = 440;

        var search_entry = new Gtk.SearchEntry () {
            margin_bottom = 6,
            placeholder_text = _("Search input language")
        };

        handler = XkbLayoutHandler.get_instance ();

        language_list = new GLib.ListStore (typeof (ListStoreItem));
        layout_list = new GLib.ListStore (typeof (ListStoreItem));

        update_list_store (language_list, handler.languages);
        var first_lang = language_list.get_item (0) as ListStoreItem;
        update_list_store (layout_list, handler.get_variants_for_language (first_lang.id));

        input_language_list_box = new Gtk.ListBox ();
        for (int i = 0; i < language_list.get_n_items (); i++) {
            var item = language_list.get_item (i) as ListStoreItem;
            var row = new LayoutRow (item.name);

            input_language_list_box.append (row);
        }

        var input_language_scrolled = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true
        };
        input_language_scrolled.set_child (input_language_list_box);

        var input_language_grid = new Gtk.Grid ();
        input_language_grid.attach (search_entry, 0, 0);
        input_language_grid.attach (input_language_scrolled, 0, 1);

        var back_button = new He.DisclosureButton ("") {
            halign = Gtk.Align.START,
            hexpand = true,
            icon = "go-previous-symbolic"
        };

        layout_list_box = new Gtk.ListBox () {
            margin_top = 12
        };

        layout_list_box.bind_model (layout_list, (item) => {
            return new LayoutRow (((ListStoreItem)item).name);
        });

        var layout_scrolled = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true
        };
        layout_scrolled.set_child (layout_list_box);

        var keyboard_map_button = new He.TintButton (_("Preview Layout")) {
            halign = Gtk.Align.END
        };

        var keyboard_map_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE
        };
        keyboard_map_revealer.set_child (keyboard_map_button);

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            hexpand = true
        };
        header_box.prepend (back_button);
        header_box.append (keyboard_map_revealer);

        var header_grid = new Gtk.Grid ();
        header_grid.attach (header_box, 0, 0);
        header_grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL) { margin_top = 3, margin_bottom = 3}, 0, 1);

        var header_revealer = new Gtk.Revealer ();
        header_revealer.set_child (header_grid);

        var deck = new Gtk.Stack ();
        deck.add_named (input_language_grid, "main");
        deck.add_named (layout_scrolled, "");

        var frame_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };

        frame_grid.attach (header_revealer, 0, 0);
        frame_grid.attach (deck, 0, 1);

        var button_add = new He.PillButton (_("Add Layout"));
        button_add.sensitive = false;

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            margin_start = 24,
            margin_end = 24,
            margin_bottom = 24
        };
        box.append (frame_grid);
        box.append (button_add);

        var window_handle = new Gtk.WindowHandle ();
        window_handle.set_child (box);

        modal = true;
        has_title = true;
        resizable = false;
        set_child (window_handle);

        search_entry.grab_focus ();

        deck.notify["visible-child"].connect (() => {
            if (deck.visible_child == input_language_grid) {
                header_revealer.reveal_child = false;
                layout_list_box.unselect_all ();
            } else if (deck.visible_child == layout_scrolled) {
                header_revealer.reveal_child = true;
                keyboard_map_revealer.reveal_child = true;
            }
        });

        input_language_list_box.set_filter_func ((list_box_row) => {
            var item = language_list.get_item (list_box_row.get_index ()) as ListStoreItem;
            return search_entry.text.down () in item.name.down ();
        });

        search_entry.search_changed.connect (() => {
            input_language_list_box.invalidate_filter ();
        });

        back_button.clicked.connect (() => {
            deck.set_visible_child_name ("main");
        });

        button_add.clicked.connect (() => {
            layout_added (get_selected_lang ().id, get_selected_layout ().id);
            close ();
        });

        input_language_list_box.row_activated.connect (() => {
            var selected_lang = get_selected_lang ();
            update_list_store (layout_list, handler.get_variants_for_language (selected_lang.id));
            layout_list_box.select_row (layout_list_box.get_row_at_index (0));
            if (layout_list_box.get_row_at_index (0) != null) {
                layout_list_box.get_row_at_index (0).grab_focus ();
            }

            deck.visible_child = layout_scrolled;
        });

        keyboard_map_button.clicked.connect (() => {
            string command = "gkbd-keyboard-display \"--layout=" + layout_id + "\"";
            try {
                AppInfo.create_from_commandline (command, null, AppInfoCreateFlags.NONE).launch (null, null);
            } catch (Error e) {
                warning ("Error launching keyboard layout display: %s", e.message);
            }
        });

        layout_list_box.row_selected.connect ((row) => {
            keyboard_map_button.sensitive = row != null;

            if (row != null) {
                layout_id = "%s\t%s".printf (get_selected_lang ().id, get_selected_layout ().id);
            }
        });
    }

    private ListStoreItem get_selected_lang () {
        var selected_lang_row = input_language_list_box.get_selected_row ();
        return language_list.get_item (selected_lang_row.get_index ()) as ListStoreItem;
    }

    private ListStoreItem get_selected_layout () {
        var selected_layout_row = layout_list_box.get_selected_row ();
        return layout_list.get_item (selected_layout_row.get_index ()) as ListStoreItem;
    }

    private void update_list_store (GLib.ListStore store, HashTable<string, string> values) {
        store.remove_all ();

        values.foreach ((key, val) => {
            store.append (new ListStoreItem (key, val));
        });

        store.sort ((a, b) => {
            if (((ListStoreItem)a).name == _("Default")) {
                return -1;
            }

            if (((ListStoreItem)b).name == _("Default")) {
                return 1;
            }

            return ((ListStoreItem)a).name.collate (((ListStoreItem)b).name);
        });
    }

    private class ListStoreItem : Object {
        public string id { get; construct; }
        public string name { get; construct; }

        public ListStoreItem (string id, string name) {
            Object (
                id: id,
                name: name
            );
        }
    }

    private class LayoutRow : Gtk.ListBoxRow {
        public string rname { get; construct; }
        public LayoutRow (string name) {
            Object (rname: name);
        }

        construct {
            var label = new Gtk.Label (rname);
            label.xalign = 0;
            set_child (label);
            add_css_class ("mini-content-block");
        }
    }
}