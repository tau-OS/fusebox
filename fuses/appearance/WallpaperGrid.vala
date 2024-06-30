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

    private const string[] REQUIRED_FILE_ATTRS = {
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
    public AppearanceView appearance_view { get; construct set; }

    private Gtk.ScrolledWindow wallpaper_scrolled_window;
    private Gtk.FlowBox wallpaper_view;
    private He.TextButton wallpaper_add_button;
    private He.TextButton wallpaper_removal_button;

    public Appearance.WallpaperContainer active_wallpaper = null;
    private Appearance.WallpaperContainer wallpaper_for_removal = null;

    private static GLib.Settings tau_appearance_settings;
    private static GLib.Settings settings;

    private Cancellable last_cancellable;

    public string current_wallpaper_path;
    private bool prevent_update_mode = false; // When restoring the combo state, don't trigger the update.
    private bool finished; // Shows that we got or wallpapers together

    public string wallpaper_title;
    public string wallpaper_subtitle;

    public WallpaperGrid (Fusebox.Fuse _fuse, AppearanceView _appearance_view) {
        Object (fuse: _fuse, appearance_view: _appearance_view);
    }

    static construct {
        tau_appearance_settings = new GLib.Settings ("com.fyralabs.desktop.appearance");
        settings = new GLib.Settings ("org.gnome.desktop.background");
    }

    construct {
        wallpaper_view = new Gtk.FlowBox () {
            activate_on_single_click = true,
            column_spacing = 12,
            valign = Gtk.Align.START,
            selection_mode = Gtk.SelectionMode.SINGLE,
            max_children_per_line = 4,
            min_children_per_line = 4
        };
        wallpaper_view.child_activated.connect (update_checked_wallpaper);
        wallpaper_view.set_sort_func (wallpapers_sort_function);
        wallpaper_view.add_css_class ("wallpaper-grid");

        var wallpaper_label = new Gtk.Label (_("Wallpaper")) {
            halign = Gtk.Align.START
        };
        wallpaper_label.add_css_class ("cb-title");

        var wallpaper_title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            spacing = 12,
            hexpand = true,
            halign = Gtk.Align.START
        };

        wallpaper_add_button = new He.TextButton ("") {
            child = new He.ButtonContent () {
                label = "Add Wallpaper…",
                icon = "list-add-symbolic"
            }
        };
        wallpaper_add_button.clicked.connect (show_wallpaper_chooser);

        wallpaper_removal_button = new He.TextButton ("") {
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

        wallpaper_title_box.prepend (wallpaper_add_button);
        wallpaper_title_box.append (wallpaper_removal_button);

        var wallpaper_main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            spacing = 12,
            hexpand = true
        };
        wallpaper_main_box.add_css_class ("mini-content-block");
        wallpaper_main_box.append (wallpaper_title_box);
        wallpaper_main_box.append (wallpaper_view);

        load_settings ();
        attach (wallpaper_main_box, 0, 1);
    }

    public const string FILE_ATTRIBUTES = "standard::*,time::*,id::file,id::filesystem,etag::value";
    private async void update_wallpaper (string uri) {
        var file = File.new_for_uri (uri);
        string furi = file.get_uri ();

        settings.set_string ("picture-uri", furi);
        settings.set_string ("picture-uri-dark", furi);
        if (appearance_view.wp_switch.iswitch.active)
            appearance_view.accent_set.begin ();
        
        appearance_view.wallpaper_preview.file = furi;

        try {
            FileInfo info = file.query_info (FILE_ATTRIBUTES, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
            var pixbuf = new Gdk.Pixbuf.from_file (file.get_path ());
            var width = pixbuf.get_width ();
            var height = pixbuf.get_height ();

            wallpaper_title = "";
            wallpaper_title = load_artist_name ();
            wallpaper_subtitle = "";
            wallpaper_subtitle = width.to_string () + "×" + height.to_string () + ", " + info.get_content_type ().to_string ().replace ("image/", "").up ();

            appearance_view.wallpaper_details_label.label = wallpaper_title;
            appearance_view.wallpaper_details_sublabel.label = wallpaper_subtitle;
        } catch (Error e) {
            warning (e.message);
        }
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
                    add_wallpaper_from_file.begin (local_uri);
                }
                chooser.destroy ();
            }
        });

        chooser.show ();
    }

    private void load_settings () {
        prevent_update_mode = true;
        current_wallpaper_path = settings.get_string ("picture-uri");

        try {
            var file = File.new_for_uri (current_wallpaper_path);
            FileInfo info = file.query_info (FILE_ATTRIBUTES, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);

            var pixbuf = new Gdk.Pixbuf.from_file (file.get_path ());
            var width = pixbuf.get_width ();
            var height = pixbuf.get_height ();

            wallpaper_title = "";
            wallpaper_title = load_artist_name ();
            wallpaper_subtitle = "";
            wallpaper_subtitle = width.to_string () + "×" + height.to_string () + ", " + info.get_content_type ().to_string ().replace ("image/", "").up ();

            appearance_view.wallpaper_details_label.label = wallpaper_title;
            appearance_view.wallpaper_details_sublabel.label = wallpaper_subtitle;
        } catch (Error e) {
            warning (e.message);
        }
    }

    private string load_artist_name () {
        if (current_wallpaper_path != null) {
            string path = "";
            GExiv2.Metadata metadata;
            try {
                path = Filename.from_uri (current_wallpaper_path);
                metadata = new GExiv2.Metadata ();
                metadata.open_path (path);
            } catch (Error e) {
                warning ("Error parsing exif metadata of \"%s\": %s", path, e.message);
                return "Current Wallpaper";
            }

            if (metadata.has_exif ()) {
                var artist_name = metadata.get_tag_string ("Exif.Image.Artist");
                if (artist_name != null) {
                    return (_("%s").printf (artist_name));
                } else {
                    return "Current Wallpaper";
                }
            }
        } else {
            return "Current Wallpaper";
        }
        return "Current Wallpaper";
    }

    private static File ? copy_for_library (File source) {
        File? dest = null;

        string local_bg_directory = Path.build_filename (Environment.get_user_data_dir (), "backgrounds") + "/";
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
        var system_bg = Path.build_filename ("/usr/share/backgrounds") + "/";
        if (children.uri.contains (system_bg)) {
            wallpaper_removal_button.visible = false;
        } else {
            wallpaper_removal_button.visible = true;
        }
        current_wallpaper_path = children.uri;
        update_wallpaper.begin (current_wallpaper_path);
    }

    public async void update_wallpaper_folder () {
        if (last_cancellable != null) {
            last_cancellable.cancel ();
            return;
        }

        var cancellable = new Cancellable ();
        last_cancellable = cancellable;

        while (wallpaper_view.get_first_child () != null) {
            wallpaper_view.remove (wallpaper_view.get_first_child ());
        }

        foreach (unowned string directory in get_bg_directories ()) {
            load_wallpapers.begin (directory, cancellable);
        }
    }

    public async void cancel_thumbnail_generation () {
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
                add_wallpaper_from_file.begin (file);
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

    private string[] get_bg_directories () {
        string[] background_directories = {};

        // Add user background directory first
        background_directories += Path.build_filename (Environment.get_user_data_dir (), "backgrounds") + "/";
        background_directories += Path.build_filename ("/usr/share/backgrounds") + "/";

        if (background_directories.length == 0) {
            warning ("No background directories found");
        }

        return background_directories;
    }

    private async void add_wallpaper_from_file (GLib.File file) {
        try {
            var info = file.query_info (string.joinv (",", REQUIRED_FILE_ATTRS), 0);
            var thumb_path = info.get_attribute_as_string (FileAttribute.THUMBNAIL_PATH);
            var thumb_valid = info.get_attribute_boolean (FileAttribute.THUMBNAIL_IS_VALID);
            var wallpaper = new WallpaperContainer (file.get_uri (), thumb_path, thumb_valid);
            wallpaper_view.append (wallpaper);

            if (current_wallpaper_path.has_suffix (file.get_uri ()) &&
                settings.get_string ("picture-options") != "none") {
                this.wallpaper_view.select_child (wallpaper);
                wallpaper.checked = true;
                active_wallpaper = wallpaper;
            }

            wallpaper_view.invalidate_sort ();
        } catch (Error e) {
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
        var bg_dir = Path.build_filename ("/usr/share/backgrounds") + "/";
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
    private const int THUMB_WIDTH = 128;
    private const int THUMB_HEIGHT = 128;

    private Gtk.Revealer check_revealer;
    private Gtk.ToggleButton check;
    private He.ContentBlockImage image;

    public string? thumb_path { get; construct set; }
    public bool thumb_valid { get; construct; }
    public string uri { get; construct; }
    public Gdk.Pixbuf thumb { get; set; }
    public uint64 creation_date = 0;

    public bool checked {
        get {
            return Gtk.StateFlags.CHECKED in get_state_flags ();
        } set {
            if (value) {
                check.set_active (true);
                check_revealer.reveal_child = true;
                image.remove_css_class ("large-radius");
                image.add_css_class ("x-large-radius");
            } else {
                check.set_active (false);
                check_revealer.reveal_child = false;
                image.remove_css_class ("x-large-radius");
                image.add_css_class ("large-radius");
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

    public WallpaperContainer (string uri, string? thumb_path, bool thumb_valid) {
        Object (uri: uri, thumb_path: thumb_path, thumb_valid: thumb_valid);
    }

    ~WallpaperContainer () {
        if (this != null)
            this.unparent ();
    }

    construct {
        image = new He.ContentBlockImage ("") {
            requested_width = 135,
            requested_height = 135
        };
        image.add_css_class ("large-radius");
        image.tooltip_text = (thumb_path);

        check = new Gtk.ToggleButton () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.START,
            can_focus = false,
            icon_name = "emblem-ok-symbolic"
        };
        check.add_css_class ("circle-radius");
        check.add_css_class ("checked-up");

        check_revealer = new Gtk.Revealer () {
            height_request = THUMB_HEIGHT
        };
        check_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        check_revealer.child = (check);

        var overlay = new Gtk.Overlay ();
        overlay.set_child (image);
        overlay.add_overlay (check_revealer);
        set_child (overlay);

        if (uri != null) {
            var file = File.new_for_uri (uri);
            try {
                var info = file.query_info ("*", FileQueryInfoFlags.NONE);
                creation_date = info.get_attribute_uint64 (GLib.FileAttribute.TIME_CREATED);
            } catch (Error e) {
                critical (e.message);
            }
        }

        activate.connect (() => {
            checked = true;
        });

        try {
            generate_and_load_thumb ();
        } catch (Error e) {
            critical ("Failed to load wallpaper thumbnail: %s", e.message);
            return;
        }
    }

    private void generate_and_load_thumb () {
        var scale = 1;
        ThumbnailGenerator.get_default ().get_thumbnail (uri, THUMB_WIDTH * scale, () => {
            update_thumb.begin ();
        });
    }

    private async void update_thumb () {
        image.file = "file://"+thumb_path;
    }
}

[DBus (name = "org.freedesktop.thumbnails.Thumbnailer1")]
interface Appearance.Thumbnailer : Object {
    public signal void ready (uint32 handle, string[] uris);
    public signal void finished (uint32 handle);
    public abstract uint32 queue (string[] uris,
        string[] mime_types,
        string flavor,
        string scheduler,
        uint32 dequeue) throws GLib.Error;
    public abstract void dequeue (uint32 handle) throws GLib.Error;
}

public class Appearance.ThumbnailGenerator {
    private const string THUMBNAILER_DBUS_ID = "org.freedesktop.thumbnails.Thumbnailer1";
    private const string THUMBNAILER_DBUS_PATH = "/org/freedesktop/thumbnails/Thumbnailer1";

    public delegate void ThumbnailReady ();

    public class ThumbnailReadyWrapper {
        public unowned ThumbnailReady cb { get; set; }
    }

    private static ThumbnailGenerator? instance = null;
    private Thumbnailer? thumbnailer = null;
    private Gee.HashMap<uint32, ThumbnailReadyWrapper> queued_delegates
        = new Gee.HashMap<uint32, ThumbnailReadyWrapper> ();
    private Gee.ArrayList<uint32> handles = new Gee.ArrayList<uint32> ();

    public static ThumbnailGenerator get_default () {
        if (instance == null) {
            instance = new ThumbnailGenerator ();
        }

        return instance;
    }

    public ThumbnailGenerator () {
        try {
            thumbnailer = Bus.get_proxy_sync (BusType.SESSION, THUMBNAILER_DBUS_ID, THUMBNAILER_DBUS_PATH);
            thumbnailer.ready.connect ((handle, uris) => {
                if (queued_delegates.has_key (handle)) {
                    queued_delegates[handle].cb ();
                }
            });

            thumbnailer.finished.connect ((handle) => {
                queued_delegates.unset (handle);
                handles.remove (handle);
            });
        } catch (Error e) {
            warning ("Unable to connect to system thumbnailer: %s", e.message);
        }
    }

    public void dequeue_all () {
        foreach (var handle in handles) {
            try {
                thumbnailer.dequeue (handle);
            } catch (GLib.Error e) {
                warning ("Unable to tell thumbnailer to stop creating thumbnails: %s", e.message);
            }
        }
    }

    public void get_thumbnail (string uri, uint size, ThumbnailReady callback) {
        string thumb_size = "normal";

        if (size > 128) {
            thumb_size = "large";
        }

        if (thumbnailer != null) {
            var wrapper = new ThumbnailReadyWrapper ();
            wrapper.cb = callback;

            try {
                var handle = thumbnailer.queue ({ uri }, { get_mime_type (uri) }, thumb_size, "default", 0);
                handles.add (handle);
                queued_delegates.@set (handle, wrapper);
            } catch (GLib.Error e) {
                warning ("Unable to queue thumbnail generation for '%s': %s", uri, e.message);
            }
        }
    }

    private string get_mime_type (string uri) {
        try {
            return ContentType.guess (Filename.from_uri (uri), null, null);
        } catch (ConvertError e) {
            warning ("Error converting filename '%s' while guessing mime type: %s", uri, e.message);
            return "";
        }
    }
}