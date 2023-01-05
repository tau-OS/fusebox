/*-
* Copyright (c) 2022 Fyra Labs
* Copyright (c) 2015-2016 elementary LLC.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
*/
public class Appearance.WallpaperGrid : Gtk.Grid {
    public enum ColumnType {
        ICON,
        NAME
    }
    
    private const string [] REQUIRED_FILE_ATTRS = {
        FileAttribute.STANDARD_NAME,
        FileAttribute.STANDARD_TYPE,
        FileAttribute.STANDARD_CONTENT_TYPE,
        FileAttribute.STANDARD_IS_HIDDEN,
        FileAttribute.STANDARD_IS_BACKUP,
        FileAttribute.STANDARD_IS_SYMLINK,
        FileAttribute.THUMBNAIL_PATH,
        FileAttribute.THUMBNAIL_IS_VALID
    };
    
    public Fusebox.Fuse fuse { get; construct set; }
    private GLib.Settings settings;
    
    private Gtk.ScrolledWindow wallpaper_scrolled_window;
    private Gtk.FlowBox wallpaper_view;
    private He.OverlayButton view_overlay;
    private He.DisclosureButton wallpaper_removal_button;
    
    private Appearance.WallpaperContainer active_wallpaper = null;
    private Appearance.WallpaperContainer wallpaper_for_removal = null;
    
    private Cancellable last_cancellable;
    
    private string current_wallpaper_path;
    private bool prevent_update_mode = false; // When restoring the combo state, don't trigger the update.
    private bool finished; // Shows that we got or wallpapers together
    
    public WallpaperGrid (Fusebox.Fuse _fuse) {
        Object (fuse: _fuse);
    }
    
    construct {
            settings = new GLib.Settings ("org.gnome.desktop.background");
            
            wallpaper_view = new Gtk.FlowBox () {
                activate_on_single_click = true,
                row_spacing = 12,
                column_spacing = 12,
                valign = Gtk.Align.START,
                selection_mode = Gtk.SelectionMode.SINGLE,
                max_children_per_line = 4
            };
            wallpaper_view.child_activated.connect (update_checked_wallpaper);
            wallpaper_view.set_sort_func (wallpapers_sort_function);
            
            wallpaper_scrolled_window = new Gtk.ScrolledWindow () {
                hexpand = true,
                vexpand = true,
                hscrollbar_policy = Gtk.PolicyType.NEVER
            };
            wallpaper_scrolled_window.set_child (wallpaper_view);
            
            var wallpaper_label = new Gtk.Label (_("Wallpaper")) {
                halign = Gtk.Align.START
            };
            wallpaper_label.add_css_class ("cb-title");

            wallpaper_removal_button = new He.DisclosureButton ("") {
                hexpand = true,
                halign = Gtk.Align.START,
                icon = "user-trash-symbolic",
                visible = false
            };
            wallpaper_removal_button.clicked.connect (() => {
                var wallpaper = (Appearance.WallpaperContainer) wallpaper_view.get_selected_children ().data;
                if (wallpaper != null)
                    wallpaper_for_removal = wallpaper;
                    wallpaper_view.remove (wallpaper_for_removal);
                    var wallpaper_file = File.new_for_uri (wallpaper_for_removal.uri);
                    wallpaper_file.trash_async.begin ();
                    wallpaper_for_removal = null;
                    wallpaper_removal_button.visible = false;
            });

            var wallpaper_title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
                spacing = 12,
                hexpand = true
            };
            wallpaper_title_box.append (wallpaper_label);
            wallpaper_title_box.append (wallpaper_removal_button);
            
            var wallpaper_main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
                spacing = 12,
                hexpand = true
            };
            wallpaper_main_box.add_css_class ("mini-content-block");
            wallpaper_main_box.append (wallpaper_title_box);
            wallpaper_main_box.append (wallpaper_scrolled_window);
            
            view_overlay = new He.OverlayButton ("", null, null);
            view_overlay.icon = "list-add-symbolic";
            view_overlay.child = (wallpaper_main_box);
            
            load_settings ();
            attach (view_overlay, 0, 1);
            
            view_overlay.clicked.connect (show_wallpaper_chooser);
        }

        private async void update_wallpaper (string uri) {
            var file = File.new_for_uri (uri);
            string furi = file.get_uri ();
            settings.set_string ("picture-uri", furi);
        }
        
        private void show_wallpaper_chooser () {
            var filter = new Gtk.FileFilter ();
            filter.add_mime_type ("image/*");
            
            var chooser = new Gtk.FileChooserNative (
                _("Add Wallpaper"), 
                null, 
                Gtk.FileChooserAction.OPEN,
                _("Add"),
                _("Cancel")
            );
            chooser.filter = filter;
            chooser.select_multiple = true;
            
            chooser.response.connect (r => {
                var response = (Gtk.ResponseType) r;
                
                if (response == Gtk.ResponseType.ACCEPT) {
                    File uri = chooser.get_file ();
                    var dest = copy_for_library (uri);
                    if (dest != null) {
                        var local_uri = dest;
                        add_wallpaper_from_file (local_uri);
                    }
                    chooser.destroy ();
                }
            });
            
            chooser.show ();
        }
        
        private void load_settings () {
            prevent_update_mode = true;
            current_wallpaper_path = settings.get_string ("picture-uri");
        }

        private static File? copy_for_library (File source) {
            File? dest = null;
    
            string local_bg_directory = get_local_bg_directory ();
            try {
                File folder = File.new_for_path (local_bg_directory);
                folder.make_directory_with_parents ();
            } catch (Error e) {
                if (e is GLib.IOError.EXISTS) {
                    debug ("Local background directory already exists");
                } else {
                    warning (e.message);
                }
            }
    
            try {
                var timestamp = new DateTime.now_local ().format ("%Y-%m-%d-%H-%M-%S");
                var filename = "%s-%s".printf (timestamp, source.get_basename ());
                string path = Path.build_filename (local_bg_directory, filename);
                dest = File.new_for_path (path);
                source.copy (dest, FileCopyFlags.OVERWRITE | FileCopyFlags.ALL_METADATA);
            } catch (Error e) {
                warning (e.message);
            }
    
            return dest;
        }
        
        private async void update_checked_wallpaper (Gtk.FlowBox box, Gtk.FlowBoxChild child) {
            var children = (Appearance.WallpaperContainer) wallpaper_view.get_selected_children ().data;
            
            if (active_wallpaper != null && active_wallpaper != children) {
                active_wallpaper.checked = false;
            }
            
            active_wallpaper = children;
            children.checked = true;
            var system_bg = get_system_bg_directories ();
            if (children.uri.contains (system_bg)) {
                wallpaper_removal_button.visible = false;
            } else {
                wallpaper_removal_button.visible = true;
            }
            current_wallpaper_path = children.uri;
            update_wallpaper.begin (current_wallpaper_path);
        }
        
        public void update_wallpaper_folder () {
            if (last_cancellable != null) {
                last_cancellable.cancel ();
            }

            var cancellable = new Cancellable ();
            last_cancellable = cancellable;

            clean_wallpapers ();

            foreach (unowned string directory in get_bg_directories ()) {
                load_wallpapers.begin (directory, cancellable);
            }
        }
        
        public void cancel_thumbnail_generation () {
            if (last_cancellable != null) {
                last_cancellable.cancel ();
            }
        }

        private async void load_wallpapers (string basefolder, Cancellable cancellable, bool toplevel_folder = true) {
            if (cancellable.is_cancelled ()) {
                return;
            }
            
            var directory = File.new_for_path (basefolder);
            
            try {
                var attrs = string.joinv (",", REQUIRED_FILE_ATTRS);
                var e = yield directory.enumerate_children_async (attrs, 0, Priority.DEFAULT);
                FileInfo file_info;
                
                while ((file_info = e.next_file ()) != null) {
                    if (cancellable.is_cancelled ()) {
                        return;
                    }
                    
                    if (file_info.get_is_hidden () || file_info.get_is_backup () || file_info.get_is_symlink ()) {
                        continue;
                    }
                    
                    if (file_info.get_file_type () == FileType.DIRECTORY) {
                        var subdir = directory.resolve_relative_path (file_info.get_name ());
                        yield load_wallpapers (subdir.get_path (), cancellable, false);
                        continue;
                    }
                    
                    var file = directory.resolve_relative_path (file_info.get_name ());
                    add_wallpaper_from_file (file);
                }
                
                if (toplevel_folder) {
                    finished = true;
                    
                    if (active_wallpaper != null) {
                        Gtk.Allocation alloc;
                        active_wallpaper.get_allocation (out alloc);
                        wallpaper_scrolled_window.get_vadjustment ().value = alloc.y;
                    }
                }
            } catch (Error err) {
                if (!(err is IOError.NOT_FOUND)) {
                    warning (err.message);
                }
            }
        }
        
        private void clean_wallpapers () {
            while (wallpaper_view.get_first_child () != null) {
                wallpaper_view.remove (wallpaper_view.get_first_child ());
            }
        }
        
        private static string get_local_bg_directory () {
            return Path.build_filename (Environment.get_user_data_dir (), "backgrounds") + "/";
        }
        
        private static string get_system_bg_directories () {
            var system_background_dir = Path.build_filename ("/usr/share/backgrounds") + "/";
            if (FileUtils.test (system_background_dir, FileTest.EXISTS)) {
                debug ("Found system background directory: %s", system_background_dir);
                return system_background_dir;
            } else {
                return "";
            }
        }
        
        private string[] get_bg_directories () {
            string[] background_directories = {};
            
            // Add user background directory first
            background_directories += get_local_bg_directory ();
            background_directories += get_system_bg_directories ();
            
            if (background_directories.length == 0) {
                warning ("No background directories found");
            }
            
            return background_directories;
        }
        
        private void add_wallpaper_from_file (GLib.File file) {
            var wallpaper = new Appearance.WallpaperContainer (file.get_uri ());
            wallpaper_view.append (wallpaper);
            
            if (current_wallpaper_path.has_suffix (file.get_uri ()) && settings.get_string ("picture-options") != "none") {
                this.wallpaper_view.select_child (wallpaper);
                wallpaper.checked = true;
                active_wallpaper = wallpaper;
            }
            
            wallpaper_view.invalidate_sort ();
        }
        
        private int wallpapers_sort_function (Gtk.FlowBoxChild _child1, Gtk.FlowBoxChild _child2) {
            var child1 = (WallpaperContainer) _child1;
            var child2 = (WallpaperContainer) _child2;
            var uri1 = child1.uri;
            var uri2 = child2.uri;
            
            if (uri1 == null || uri2 == null) {
                return 0;
            }
            
            var uri1_is_system = false;
            var uri2_is_system = false;
            var bg_dir = get_system_bg_directories ();
            bg_dir = "file://" + bg_dir;
            uri1_is_system = uri1.has_prefix (bg_dir) || uri1_is_system;
            uri2_is_system = uri2.has_prefix (bg_dir) || uri2_is_system;
            
            // Sort system wallpapers last
            if (uri1_is_system && !uri2_is_system) {
                return 1;
            } else if (!uri1_is_system && uri2_is_system) {
                return -1;
            }
            
            var child1_date = child1.creation_date;
            var child2_date = child2.creation_date;
            
            // sort by filename if creation dates are equal
            if (child1_date == child2_date) {
                return uri1.collate (uri2);
            }
            
            // sort recently added first
            if (child1_date >= child2_date) {
                return -1;
            } else {
                return 1;
            }
        }
    }
    
    public class Appearance.WallpaperContainer : Gtk.FlowBoxChild {
        private const int THUMB_WIDTH = 100;
        private const int THUMB_HEIGHT = 100;
        
        private Gtk.Revealer check_revealer;
        private Gtk.ToggleButton check;
        private Gtk.Image image;
        
        public string uri { get; construct; }
        public uint64 creation_date = 0;
        
        public bool checked {
            get {
                return Gtk.StateFlags.CHECKED in get_state_flags ();
            } set {
                if (value) {
                    check.set_active (true);
                    check_revealer.reveal_child = true;
                } else {
                    check.set_active (false);
                    check_revealer.reveal_child = false;
                }
                
                queue_draw ();
            }
        }
        
        public bool selected {
            get {
                return Gtk.StateFlags.SELECTED in get_state_flags ();
            } set {
                if (value) {
                    set_state_flags (Gtk.StateFlags.SELECTED, false);
                } else {
                    unset_state_flags (Gtk.StateFlags.SELECTED);
                }
                
                queue_draw ();
            }
        }
        
        public WallpaperContainer (string uri) {
            Object (uri: uri);
        }
        
        ~WallpaperContainer () {
            if (this != null)
                this.unparent ();
        }

        construct {
            height_request = THUMB_HEIGHT + 6;
            width_request = THUMB_WIDTH + 6;
            
            image = new Gtk.Image () {
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER,
                pixel_size = THUMB_WIDTH
            };
            
            check = new Gtk.ToggleButton () {
                halign = Gtk.Align.START,
                valign = Gtk.Align.START,
                can_focus = false,
                icon_name = "emblem-ok-symbolic"
            };
            check.add_css_class ("circular");
            check.add_css_class ("checked-up");
            
            check_revealer = new Gtk.Revealer ();
            check_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
            check_revealer.child = (check);
            
            var overlay = new Gtk.Overlay ();
            overlay.set_child (image);
            overlay.add_overlay (check_revealer);
            
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.CENTER;
            set_child (overlay);
            
            activate.connect (() => {
                checked = true;
            });
            
            make_thumb.begin ();
        }

        public async void make_thumb () {
            try {
                var file = File.new_for_uri (uri);
                var pixbuf = new Gdk.Pixbuf.from_file (file.get_path ());
                pixbuf = pixbuf.scale_simple (THUMB_WIDTH, THUMB_HEIGHT, Gdk.InterpType.BILINEAR);
                image.set_from_pixbuf (pixbuf);
            } catch (Error e) {
                //
            }
        }
    }
