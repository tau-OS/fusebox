[DBus (name = "org.freedesktop.locale1")]
public interface Locale1Proxy : GLib.Object {
    public abstract string[] locale { owned get; }

    public abstract void set_locale (string[] arg_0, bool arg_1) throws GLib.Error;
    public abstract void set_x11_keyboard (string arg_0,
        string arg_1,
        string arg_2,
        string arg_3,
        bool arg_4,
        bool arg_5) throws GLib.Error;
}

public class Locale.LocaleView : Gtk.Box {
    private Locale1Proxy locale1_proxy;
    private UserLocale current_user_locale;
    private signal void current_user_locale_updated ();

    construct {
        var user_manager = Act.UserManager.get_default ();
        var current_user = user_manager.get_user (Environment.get_user_name ());

        current_user.notify["is-loaded"].connect (() => {
            this.current_user_locale = get_user_locale (current_user);
            current_user_locale_updated ();
        });

        try {
            var connection = Bus.get_sync (BusType.SYSTEM);
            locale1_proxy = connection.get_proxy_sync<Locale1Proxy> (
                                                                     "org.freedesktop.locale1",
                                                                     "/org/freedesktop/locale1",
                                                                     DBusProxyFlags.NONE
            );
        } catch (IOError e) {
            critical (e.message);
        }

        var system_locale = get_system_locale (locale1_proxy);
        this.current_user_locale = get_user_locale (current_user);

        var mbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

        var language_button = new He.Button ("document-edit-symbolic", "") {
            is_disclosure = true
        };
        language_button.clicked.connect (() => {
            var dialog = new Locale.LanguagePicker (He.Misc.find_ancestor_of_type<He.ApplicationWindow> (mbox));
            dialog.show ();
            dialog.notify["selected-language"].connect ((lang) => {
                var language = dialog.selected_language;
                dialog.destroy ();
                try {
                    var new_user_locale = get_user_locale (current_user);
                    new_user_locale.language = language;
                    update_user_locale (current_user, new_user_locale);
                    this.current_user_locale = new_user_locale;
                    current_user_locale_updated ();
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        });

        var language_block = new He.MiniContentBlock.with_details (_("Language"), null, language_button) {
            hexpand = true,
        };
        print ("%s", this.current_user_locale.language ? .name ?? system_locale.language.name);
        language_block.subtitle = this.current_user_locale.language ? .name ?? system_locale.language.name;
        this.current_user_locale_updated.connect (() => {
            language_block.subtitle = this.current_user_locale.language ? .name ?? system_locale.language.name;
        });
        mbox.append (language_block);

        var format_button = new He.Button ("document-edit-symbolic", "") {
            is_disclosure = true
        };
        format_button.clicked.connect (() => {
            var dialog = new Locale.FormatPicker (He.Misc.find_ancestor_of_type<He.ApplicationWindow> (mbox));
            dialog.show ();
            dialog.notify["selected-format"].connect ((lang) => {
                var format = dialog.selected_format;
                dialog.destroy ();
                try {
                    var new_user_locale = get_user_locale (current_user);
                    new_user_locale.format = format;
                    update_user_locale (current_user, new_user_locale);
                    this.current_user_locale = new_user_locale;
                    current_user_locale_updated ();
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        });
        var format_block = new He.MiniContentBlock.with_details (_("Format"), null, format_button) {
            hexpand = true,
        };
        format_block.subtitle = this.current_user_locale.format ? .name ??
            this.current_user_locale.language ? .name ??
            system_locale.format ? .name ??
            system_locale.language.name;
        this.current_user_locale_updated.connect (() => {
            format_block.subtitle = this.current_user_locale.format ? .name ??
                this.current_user_locale.language ? .name ??
                system_locale.format ? .name ??
                system_locale.language.name;
        });
        mbox.append (format_block);

        var clamp = new Bis.Latch ();
        clamp.set_child (mbox);

        this.append (clamp);
        orientation = Gtk.Orientation.VERTICAL;
    }
}