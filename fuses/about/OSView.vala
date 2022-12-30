[DBus (name = "org.freedesktop.hostname1")]
public interface SystemInterface : Object {
    [DBus (name = "IconName")]
    public abstract string icon_name { owned get; }

    public abstract string pretty_hostname { owned get; set; }
    public abstract string static_hostname { owned get; set; }
}

public class About.OSView : Gtk.Box {
    private SystemInterface system_interface;
    private Gtk.Label hostname_subtitle;

    construct {
        var os_pretty_name = "%s".printf (
            Environment.get_os_info (GLib.OsInfoKey.NAME)
        );
        var os_sub_name = "<b>%s %s</b>".printf (
            Environment.get_os_info (GLib.OsInfoKey.VERSION_ID) ?? "",
            Environment.get_os_info (GLib.OsInfoKey.VERSION_CODENAME) ?? "(Guadalajara)" // Remember to change this with every new GNOME release until we do a new DE
        );
        var os_title = new Gtk.Label (os_pretty_name) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            xalign = 0
        };
        os_title.get_style_context ().add_class ("view-title");
        var os_subtitle = new Gtk.Label (os_sub_name.replace ("(","“").replace(")","”")) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        os_subtitle.get_style_context ().add_class ("view-subtitle");
        var os_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        os_box.append (os_title);
        os_box.append (os_subtitle);
        os_box.add_css_class ("main-content-block");

        var hostname_title = new Gtk.Label (_("Device Name")) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            xalign = 0
        };
        hostname_title.get_style_context ().add_class ("cb-title");
        hostname_subtitle = new Gtk.Label (get_host_name ()) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        hostname_subtitle.get_style_context ().add_class ("cb-subtitle");
        var hostname_image = new Gtk.Image () {
            halign = Gtk.Align.START,
            icon_name = system_interface.icon_name + "-symbolic"
        };
        hostname_image.add_css_class ("rounded-icon");
        var hostname_button = new Gtk.Button () {
            icon_name = "pan-end-symbolic",
            hexpand = true,
            halign = Gtk.Align.END
        };
        hostname_button.add_css_class ("flat");
        hostname_button.add_css_class ("circular");
        var hostname_action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        hostname_action_box.append (hostname_title);
        hostname_action_box.append (hostname_button);
        var hostname_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        hostname_box.append (hostname_image);
        hostname_box.append (hostname_action_box);
        hostname_box.append (hostname_subtitle);
        hostname_box.add_css_class ("content-block");

        var bug_button = new He.PillButton (_("Report A Problem…")) {
            hexpand = true,
            halign = Gtk.Align.CENTER
        };

        var view_label = new Gtk.Label ("About") {
            halign = Gtk.Align.START
        };
        view_label.add_css_class ("view-title");

        orientation = Gtk.Orientation.VERTICAL;
        spacing = 6;
        append (view_label);
        append (os_box);
        append (hostname_box);
        append (bug_button);

        hostname_button.clicked.connect (() => {
            var rename_button = new He.FillButton (_("Rename")) {
                sensitive = false
            };
            var title_label = new Gtk.Label ("Rename Your Computer") {
                halign = Gtk.Align.START
            };
            title_label.add_css_class ("view-title");
            var subtitle_label = new Gtk.Label ("The computer's identity") {
                halign = Gtk.Align.START
            };
            subtitle_label.add_css_class ("view-subtitle");
            var text_label = new Gtk.Label ("When you rename your computer, it'll reflect on how it is seen by other devices. For example, via bluetooth and secure shells.") {
                halign = Gtk.Align.START,
                wrap = true,
                wrap_mode = Pango.WrapMode.WORD
            };
            var image = new Gtk.Image () {
                pixel_size = 128,
                icon_name = "dialog-information-symbolic"
            };

            var rename_entry = new Gtk.Entry () {
                text = hostname_subtitle.label
            };

            rename_entry.buffer.inserted_text.connect (() => {
                rename_button.sensitive = true;
            });

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24) {
                margin_top = 24,
                margin_bottom = 24,
                margin_start = 24,
                margin_end = 24
            };
            main_box.append (image);
            main_box.append (title_label);
            main_box.append (subtitle_label);
            main_box.append (text_label);
            main_box.append (rename_entry);

            var cancel_button = new He.TextButton ("Cancel");

            var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
                homogeneous = true
            };
            action_box.append (cancel_button);
            action_box.append (rename_button);

            main_box.append (action_box);

            var rename_dialog = new He.Window () {
                resizable = false,
                has_title = false
            };
            rename_dialog.set_size_request (360, 400);
            rename_dialog.set_default_size (360, 400);
            rename_dialog.set_child (main_box);
            rename_dialog.show ();

            rename_button.clicked.connect (() => {
                set_host_name (rename_entry.buffer.get_text ());
                rename_dialog.close ();
            });

            cancel_button.clicked.connect (() => {
                rename_dialog.close ();
            });
        });

        bug_button.clicked.connect (() => {
            var appinfo = new GLib.DesktopAppInfo ("co.tauos.Mondai");
            if (appinfo != null) {
                try {
                    appinfo.launch (null, null);
                } catch (Error e) {
                    critical (e.message);
                }
            }
        });
    }

    private void get_system_interface_instance () {
        if (system_interface == null) {
            try {
                system_interface = Bus.get_proxy_sync (
                    BusType.SYSTEM,
                    "org.freedesktop.hostname1",
                    "/org/freedesktop/hostname1"
                );
            } catch (GLib.Error e) {
                warning ("%s", e.message);
            }
        }
    }

    private string get_host_name () {
        get_system_interface_instance ();

        if (system_interface == null) {
            return GLib.Environment.get_host_name ();
        }

        string hostname = system_interface.pretty_hostname;

        if (hostname.length == 0) {
            hostname = system_interface.static_hostname;
        }

        return hostname;
    }

    private void set_host_name (string sname) {
        get_system_interface_instance ();
        hostname_subtitle.label = sname;

        if (system_interface.pretty_hostname != null) {
            try {
                var dbsi = new DBusProxy.for_bus_sync (
                                                        BusType.SYSTEM,
                                                        DBusProxyFlags.NONE,
                                                        null,
                                                        "org.freedesktop.hostname1",
                                                        "/org/freedesktop/hostname1",
                                                        "org.freedesktop.hostname1",
                                                        null
                                                      );
                dbsi.call_sync (            
                                "SetPrettyHostname",
                                new Variant ("(sb)", sname, false),
                                DBusCallFlags.NONE,
                                -1,
                                null
                               );
            } catch (GLib.Error e) {
                warning ("%s", e.message);
            }
        }
        if (system_interface.static_hostname != null) {
            try {
                sname.canon ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", ' ');
                var dbsi = new DBusProxy.for_bus_sync (
                                                        BusType.SYSTEM,
                                                        DBusProxyFlags.NONE,
                                                        null,
                                                        "org.freedesktop.hostname1",
                                                        "/org/freedesktop/hostname1",
                                                        "org.freedesktop.hostname1",
                                                        null
                                                      );
                dbsi.call_sync (            
                                "SetStaticHostname",
                                new Variant ("(sb)", sname.replace (" ","-").ascii_down (), false),
                                DBusCallFlags.NONE,
                                -1,
                                null
                               );
            } catch (GLib.Error e) {
                warning ("%s", e.message);
            }
        }
    }
}