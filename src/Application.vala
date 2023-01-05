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
    public class FuseboxApp : He.Application {
        public Gtk.SearchEntry search_box { get; private set; }

        private GLib.HashTable <Gtk.Widget, Fusebox.Fuse> fuse_widgets;
        private Bis.Album album;
        private Bis.Album halbum;
        private He.AppBar headerbar;
        private He.ApplicationWindow main_window;
        private Fusebox.CategoryView category_view;

        private static bool opened_directly = false;
        private static string? link = null;
        private static string? open_window = null;
        private static string? fuse_to_open = null;

        public const string ACTION_PREFIX = "win.";
        public const string ACTION_ABOUT = "about";
        public SimpleActionGroup actions;
        private const GLib.ActionEntry[] ACTION_ENTRIES = {
            {ACTION_ABOUT, action_about },
        };

        public FuseboxApp () {
            Object (application_id: "co.tauos.Fusebox");
        }

        construct {
            if (GLib.AppInfo.get_default_for_uri_scheme ("settings") == null) {
                var appinfo = new GLib.DesktopAppInfo (application_id + ".desktop");
                try {
                    appinfo.set_as_default_for_type ("x-scheme-handler/settings");
                } catch (Error e) {
                    critical ("Unable to set default for the settings scheme: %s", e.message);
                }
            }
        }

        public override void open (File[] files, string hint) {
            var file = files[0];
            if (file == null) {
                return;
            }

            if (file.get_uri_scheme () == "settings") {
                link = file.get_uri ().replace ("settings://", "");
                if (link.has_suffix ("/")) {
                    link = link.substring (0, link.last_index_of_char ('/'));
                }
            } else {
                critical ("Calling Fusebox directly is unsupported, please use the settings:// scheme instead");
            }

            activate ();
        }

        protected override void startup () {
            Gdk.RGBA accent_color = { 0 };
            accent_color.parse("#828292");
            default_accent_color = He.Color.from_gdk_rgba(accent_color);

            resource_base_path = "/co/tauos/Fusebox";

            base.startup ();

            Bis.init ();
        }

        public override void activate () {
            var fusesmanager = Fusebox.FusesManager.get_default ();
            if (link != null) {
                bool fuse_found = load_setting_path (link, fusesmanager);

                if (fuse_found) {
                    link = null;

                    // If fuse_to_open was set from the command line
                    opened_directly = true;
                } else {
                    warning (_("Specified link '%s' does not exist, going back to the main panel").printf (link));
                }
            } else if (fuse_to_open != null) {
                foreach (var fuse in fusesmanager.get_fuses ()) {
                    if (fuse_to_open.has_suffix (fuse.code_name)) {
                        load_fuse (fuse);
                        fuse_to_open = null;

                        // If fuse_to_open was set from the command line
                        opened_directly = true;
                        break;
                    }
                }
            }

            // If app is already running, present the current window.
            if (get_windows ().length () > 0) {
                get_windows ().data.present ();
                return;
            }

            fuse_widgets = new GLib.HashTable <Gtk.Widget, Fusebox.Fuse> (null, null);

            var quit_action = new SimpleAction ("quit", null);
            add_action (quit_action);
            set_accels_for_action ("app.quit", {"<Control>q"});

            var search_box_eventcontrollerkey = new Gtk.EventControllerKey ();

            search_box = new Gtk.SearchEntry () {
                placeholder_text = _("Search Settings"),
                visible = false,
                halign = Gtk.Align.START
            };
            search_box.add_controller (search_box_eventcontrollerkey);
            search_box.add_css_class ("search");

            headerbar = new He.AppBar () {
                show_buttons = false,
                show_back = false,
                flat = true,
                width_request = 250
            };

            var search_button = new Gtk.ToggleButton ();
            search_button.icon_name = "system-search-symbolic";

            var menu_popover = new Gtk.Popover () {
                autohide = true
            };
            var about_menu_item = create_button_menu_item (
                                                           _("About Fusebox…"),
                                                           "win.about"
                                                          );
            about_menu_item.clicked.connect (() => {
                menu_popover.popdown ();
            });
            var menu_popover_grid = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL
            };
            menu_popover_grid.attach (about_menu_item, 0, 0, 1, 1);
            menu_popover.child = menu_popover_grid;

            var menu_button = new Gtk.MenuButton () {
                popover = menu_popover,
                icon_name = "open-menu-symbolic"
            };

            headerbar.append (menu_button);
            headerbar.append (search_button);

            search_button.toggled.connect (() => {
                search_box.visible = search_button.active;
            });

            category_view = new Fusebox.CategoryView (fuse_to_open);
            category_view.load_default_fuses.begin ();

            album = new Bis.Album () {
                can_navigate_back = true,
                can_navigate_forward = true,
                can_unfold = false
            };
            album.append (category_view);

            var empty_page = new He.EmptyPage () {
                margin_start = 18,
                margin_end = 18,
                title = "Select A Preference",
                description = "Start by selecting a preference from the sidebar",
                icon = "applications-system-symbolic"
            };
            empty_page.action_button.visible = false;

            halbum = new Bis.Album () {
                can_navigate_back = true,
                can_navigate_forward = true,
                can_unfold = false
            };
            halbum.append (empty_page);

            var searchview = new SearchView ();

            var search_stack = new Gtk.Stack () {
                transition_type = Gtk.StackTransitionType.OVER_DOWN_UP
            };
            search_stack.add_child (album);
            search_stack.add_child (searchview);

            var window_eventcontrollerkey = new Gtk.EventControllerKey ();

            var label = new Gtk.Label ("Settings") {
                halign = Gtk.Align.START
            };
            label.add_css_class ("view-title");

            var ssbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
                hexpand = false,
                margin_start = 18,
                margin_end = 18
            };
            ssbox.append (label);
            ssbox.append (search_box);
            ssbox.append (search_stack);

            var sbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
                hexpand = false
            };
            sbox.append (headerbar);
            sbox.append (ssbox);

            var sheaderbar = new He.AppBar () {
                show_buttons = true,
                show_back = false,
                flat = true,
            };

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
            box.append (sheaderbar);
            box.append (halbum);

            var sep = new Gtk.Separator (Gtk.Orientation.VERTICAL);

            var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            main_box.append (sbox);
            main_box.append (sep);
            main_box.append (box);

            var window_handle = new Gtk.WindowHandle () {
                child = main_box
            };

            main_window = new He.ApplicationWindow (this) {
                application = this,
                child = window_handle,
                icon_name = application_id,
                title = _("Fusebox")
            };
            add_window (main_window);
            main_window.present ();
            main_window.set_size_request (360, 360);
            main_window.default_height = 800;
            main_window.default_width = 830;
            // Actions
            actions = new SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            main_window.insert_action_group ("win", actions);

            search_box.search_changed.connect (() => {
                if (search_box.text.length > 0) {
                    search_stack.visible_child = searchview;
                } else {
                    search_stack.visible_child = album;
                }
            });

            search_box.activate.connect (() => {
                searchview.activate_first_item ();
            });

            search_box_eventcontrollerkey.key_released.connect ((keyval, keycode, state) => {
                switch (keyval) {
                    case Gdk.Key.Down:
                        search_box.move_focus (Gtk.DirectionType.TAB_FORWARD);
                        break;
                    case Gdk.Key.Escape:
                        search_box.text = "";
                        break;
                    default:
                        break;
                }
            });

            quit_action.activate.connect (() => {
                quit ();
            });

            shutdown.connect (() => {
                if (fuse_widgets[album.visible_child] != null && fuse_widgets[album.visible_child] is Fusebox.Fuse) {
                    fuse_widgets[album.visible_child].hidden ();
                }
            });

            ((Gtk.Widget) main_window).add_controller (window_eventcontrollerkey);
            window_eventcontrollerkey.key_pressed.connect ((keyval, keycode, modifiers) => {
                window_eventcontrollerkey.forward (search_box.get_delegate ());
                return Gdk.EVENT_PROPAGATE;
            });

            halbum.notify["visible-child"].connect (() => {
                update_navigation ();
            });

            halbum.notify["child-transition-running"].connect (() => {
                update_navigation ();
            });

            if (Fusebox.FusesManager.get_default ().has_fuses () == false) {
                category_view.show_alert (_("No Settings Found"), _("Install some and re-launch Fusebox."), "dialog-warning");
            }
        }

        public void action_about () {
            // TRANSLATORS: 'Name <email@domain.com>' or 'Name https://website.example'
            string translators = (_(""));

            var about = new He.AboutWindow (
                this.get_active_window (),
                "Fusebox",
                "co.tauos.Fusebox",
                "0.1.0",
                "co.tauos.Fusebox",
                "https://github.com/tau-os/fusebox/tree/main/po",
                "https://github.com/tau-os/fusebox/issues/new",
                "https://github.com/tau-os/fusebox",
                {translators},
                {"The tauOS team"},
                2023, // Year of first publication.
                He.AboutWindow.Licenses.GPLv3,
                He.Colors.DARK
            );
            about.present ();
        }

        private Gtk.Button create_button_menu_item (string label, string? action_name) {
            var labelb = new Gtk.Label (label) {
                xalign = 0
            };
            var button = new Gtk.Button () {
                child = labelb,
                hexpand = true
            };
            button.set_action_name (action_name);
            button.add_css_class ("flat");
            return button;
        }

        private void update_navigation () {
            if (!halbum.child_transition_running) {
                if (fuse_widgets[album.get_adjacent_child (Bis.NavigationDirection.FORWARD)] != null) {
                    fuse_widgets[album.get_adjacent_child (Bis.NavigationDirection.FORWARD)].hidden ();
                }

                var previous_child = fuse_widgets[halbum.get_adjacent_child (Bis.NavigationDirection.BACK)];
                if (previous_child != null && previous_child is Fusebox.Fuse) {
                    previous_child.hidden ();
                }

                fuse_widgets[halbum.visible_child].shown ();
                search_box.text = "";
            }
        }

        public void load_fuse (Fusebox.Fuse fuse) {
            if (album.child_transition_running) {
                return;
            }

            Idle.add (() => {
                while (halbum.get_adjacent_child (Bis.NavigationDirection.FORWARD) != null) {
                    halbum.remove (halbum.get_adjacent_child (Bis.NavigationDirection.FORWARD));
                }

                var fuse_widget = fuse.get_widget ();
                if (fuse_widget.parent == null) {
                    halbum.append (fuse_widget);
                }

                if (fuse_widgets[fuse_widget] == null) {
                    fuse_widgets[fuse_widget] = fuse;
                }

                foreach (var entry in category_view.fuse_search_result) {
                    if (fuse.display_name == entry.fuse_name) {
                        if (entry.open_window == null) {
                            fuse.search_callback (""); // open default in the switch
                        } else {
                            fuse.search_callback (entry.open_window);
                        }
                        debug ("open section:%s of fuse: %s", entry.open_window, fuse.display_name);
                        continue;
                    }

                    break;
                }

                // open window was set by command line argument
                if (open_window != null) {
                    fuse.search_callback (open_window);
                    open_window = null;
                }

                if (opened_directly) {
                    halbum.mode_transition_duration = 0;
                    opened_directly = false;
                } else if (album.mode_transition_duration == 0) {
                    halbum.mode_transition_duration = 200;
                }

                halbum.visible_child = fuse.get_widget ();

                return false;
            }, GLib.Priority.DEFAULT_IDLE);
        }

        // Try to find a supported fuse, fallback paths like "foo/bar" to "foo"
        public bool load_setting_path (string setting_path, Fusebox.FusesManager fusesmanager) {
            foreach (var fuse in fusesmanager.get_fuses ()) {
                var supported_settings = fuse.supported_settings;
                if (supported_settings == null) {
                    continue;
                }

                if (supported_settings.contains (setting_path)) {
                    load_fuse (fuse);
                    open_window = supported_settings.get (setting_path);
                    return true;
                }
            }

            // Fallback to subpath
            if ("/" in setting_path) {
                int last_index = setting_path.last_index_of_char ('/');
                return load_setting_path (setting_path.substring (0, last_index), fusesmanager);
            }

            return false;
        }

        public static int main (string[] args) {
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
            Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
            Intl.textdomain (GETTEXT_PACKAGE);

            var app = new FuseboxApp ();
            return app.run (args);
        }
    }
}
