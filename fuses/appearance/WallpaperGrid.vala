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

 [DBus (name = "org.freedesktop.DisplayManager.AccountsService")]
 interface Appearance.AccountsServiceUser : Object {
     [DBus (name = "BackgroundFile")]
     public abstract string background_file { owned get; set; }
 }
 
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
     private AccountsServiceUser? accountsservice = null;
 
     private Gtk.ScrolledWindow wallpaper_scrolled_window;
     private Gtk.FlowBox wallpaper_view;
     private He.OverlayButton view_overlay;
 
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

         try {
             int uid = (int)Posix.getuid ();
             accountsservice = Bus.get_proxy_sync (BusType.SYSTEM,
                     "org.freedesktop.Accounts",
                     "/org/freedesktop/Accounts/User%i".printf (uid));
         } catch (Error e) {
             warning (e.message);
         }
 
         wallpaper_view = new Gtk.FlowBox ();
         wallpaper_view.activate_on_single_click = true;
         wallpaper_view.homogeneous = true;
         wallpaper_view.valign = Gtk.Align.START;
         wallpaper_view.selection_mode = Gtk.SelectionMode.SINGLE;
         wallpaper_view.child_activated.connect (update_checked_wallpaper);
         wallpaper_view.set_sort_func (wallpapers_sort_function);
 
         wallpaper_scrolled_window = new Gtk.ScrolledWindow ();
         wallpaper_scrolled_window.hexpand = true;
         wallpaper_scrolled_window.vexpand = true;
         wallpaper_scrolled_window.set_child (wallpaper_view);

         var wallpaper_label = new Gtk.Label (_("Wallpaper")) {
            halign = Gtk.Align.START
         };
         wallpaper_label.add_css_class ("cb-title");

         var wallpaper_main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            spacing = 12,
            hexpand = true
        };
        wallpaper_main_box.add_css_class ("mini-content-block");
        wallpaper_main_box.append (wallpaper_label);
        wallpaper_main_box.append (wallpaper_scrolled_window);
 
         view_overlay = new He.OverlayButton ("", null, null);
         view_overlay.icon = "list-add-symbolic";
         view_overlay.child = (wallpaper_main_box);
 
         load_settings ();
         attach (view_overlay, 0, 1);
 
         view_overlay.clicked.connect (show_wallpaper_chooser);

         update_wallpaper_folder ();
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
                add_wallpaper_from_file (uri);
                chooser.destroy ();
            }
         });
 
         chooser.show ();
     }
 
     private void load_settings () {
         prevent_update_mode = true;
         current_wallpaper_path = settings.get_string ("picture-uri");
     }
 
     private void update_checked_wallpaper (Gtk.FlowBox box, Gtk.FlowBoxChild child) {
         var children = (Appearance.WallpaperContainer) wallpaper_view.get_selected_children ().data;
 
         children.checked = true;
 
         if (active_wallpaper != null && active_wallpaper != children) {
             active_wallpaper.checked = false;
         }
 
         active_wallpaper = children;
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
                     // Spawn off another loader for the subdirectory
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
            wallpaper_view.get_first_child ().destroy ();
         }
     }
 
     private static string get_local_bg_directory () {
         return Path.build_filename (Environment.get_user_data_dir (), "backgrounds") + "/";
     }
 
     private static string[] get_system_bg_directories () {
         string[] directories = {};
         foreach (unowned string data_dir in Environment.get_system_data_dirs ()) {
             var system_background_dir = Path.build_filename (data_dir, "backgrounds") + "/";
             if (FileUtils.test (system_background_dir, FileTest.EXISTS)) {
                 debug ("Found system background directory: %s", system_background_dir);
                 directories += system_background_dir;
             }
         }
 
         return directories;
     }
 
     private string[] get_bg_directories () {
         string[] background_directories = {};
 
         // Add user background directory first
         background_directories += get_local_bg_directory ();
 
         foreach (var bg_dir in get_system_bg_directories ()) {
             background_directories += bg_dir;
         }
 
         if (background_directories.length == 0) {
             warning ("No background directories found");
         }
 
         return background_directories;
     }
 
     private void add_wallpaper_from_file (GLib.File file) {
         if (wallpaper_for_removal != null) {
             return;
         }
 
        var wallpaper = new Appearance.WallpaperContainer (file.get_uri ());
        wallpaper_view.append (wallpaper);

        wallpaper.trash.connect (() => {
            mark_for_removal (wallpaper);
        });

        if (current_wallpaper_path.has_suffix (file.get_uri ()) && settings.get_string ("picture-options") != "none") {
            this.wallpaper_view.select_child (wallpaper);
            wallpaper.checked = true;
            active_wallpaper = wallpaper;
        }
 
         wallpaper_view.invalidate_sort ();
     }
 
     public void cancel_thumbnail_generation () {
         if (last_cancellable != null) {
             last_cancellable.cancel ();
         }
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
         foreach (var bg_dir in get_system_bg_directories ()) {
             bg_dir = "file://" + bg_dir;
             uri1_is_system = uri1.has_prefix (bg_dir) || uri1_is_system;
             uri2_is_system = uri2.has_prefix (bg_dir) || uri2_is_system;
         }
 
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
 
     private void mark_for_removal (WallpaperContainer wallpaper) {
         wallpaper_view.remove (wallpaper);
         wallpaper_for_removal = wallpaper;
     }
 }

 public class Appearance.WallpaperContainer : Gtk.FlowBoxChild {
    public signal void trash ();

    private const int THUMB_WIDTH = 128;
    private const int THUMB_HEIGHT = 128;

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

    construct {
        height_request = THUMB_HEIGHT;
        width_request = THUMB_WIDTH;

        image = new Gtk.Image () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            pixel_size = THUMB_WIDTH
        };

        check = new Gtk.ToggleButton () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.START,
            can_focus = false,
            sensitive = false,
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