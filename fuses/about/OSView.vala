public class About.OSView : Gtk.Box {
    construct {
        var pretty_name = "%s".printf (
            Environment.get_os_info (GLib.OsInfoKey.NAME)
        );
        var sub_name = "<b>%s</b>".printf (
            Environment.get_os_info (GLib.OsInfoKey.VERSION) ?? ""
        );
        var title = new Gtk.Label (pretty_name) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            xalign = 0
        };
        title.get_style_context ().add_class ("view-title");
        var subtitle = new Gtk.Label (sub_name) {
            ellipsize = Pango.EllipsizeMode.END,
            selectable = true,
            use_markup = true,
            xalign = 0
        };
        subtitle.get_style_context ().add_class ("view-subtitle");

        var os_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        os_box.append (title);
        os_box.append (subtitle);
        os_box.add_css_class ("main-content-block");

        var bug_button = new He.PillButton (_("Report A Problem…")) {
            hexpand = true,
            halign = Gtk.Align.CENTER
        };

        var view_label = new Gtk.Label ("About") {
            halign = Gtk.Align.START
        };
        view_label.add_css_class ("view-title");

        orientation = Gtk.Orientation.VERTICAL;
        spacing = 12;
        append (view_label);
        append (os_box);
        append (bug_button);

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
}