[DBus (name = "org.freedesktop.locale1")]
public interface Locale1Proxy : GLib.Object {
    public abstract string[] locale { owned get; }

    public abstract void set_locale (string[] arg_0, bool arg_1) throws GLib.Error;
    public abstract void set_x11_keyboard (
        string arg_0,
        string arg_1,
        string arg_2,
        string arg_3,
        bool arg_4,
        bool arg_5
    ) throws GLib.Error;
}

public class Locale.LocaleView : Gtk.Box {
    private Locale1Proxy locale1_proxy;
    private SystemLocale current_system_locale;
    private signal void current_system_locale_updated ();
    construct {
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

        this.current_system_locale = get_system_locale (locale1_proxy);

        var mbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

        var language_button = new He.DisclosureButton ("document-edit-symbolic");
        language_button.clicked.connect (() => {
            var dialog = new Locale.LanguagePicker (He.Misc.find_ancestor_of_type<He.ApplicationWindow>(mbox));
            dialog.show ();
            dialog.notify["selected-language"].connect ((lang) => {
                var language = dialog.selected_language;
                dialog.destroy ();
                try {
                    var new_system_locale = get_system_locale (locale1_proxy);
                    new_system_locale.language = language;
                    update_system_locale (locale1_proxy, new_system_locale);
                    this.current_system_locale = new_system_locale;
                    current_system_locale_updated ();
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        });

        var language_block = new He.MiniContentBlock.with_details(_("Language"), null, language_button) {
            hexpand = true,
        };
        language_block.subtitle = this.current_system_locale.language.name;
        this.current_system_locale_updated.connect (() => {
            language_block.subtitle = this.current_system_locale.language.name;
        });
        mbox.append(language_block);

        var format_button = new He.DisclosureButton ("document-edit-symbolic");
        format_button.clicked.connect (() => {
            var dialog = new Locale.FormatPicker (He.Misc.find_ancestor_of_type<He.ApplicationWindow>(mbox));
            dialog.show ();
            dialog.notify["selected-format"].connect ((lang) => {
                var format = dialog.selected_format;
                dialog.destroy ();
                try {
                    var new_system_locale = get_system_locale (locale1_proxy);
                    new_system_locale.format = format;
                    update_system_locale (locale1_proxy, new_system_locale);
                    this.current_system_locale = new_system_locale;
                    current_system_locale_updated ();
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        });
        var format_block = new He.MiniContentBlock.with_details(_("Format"), null, format_button) {
            hexpand = true,
        };
        format_block.subtitle = this.current_system_locale.format?.name ?? this.current_system_locale.language.name;
        this.current_system_locale_updated.connect (() => {
            format_block.subtitle = this.current_system_locale.format?.name ?? this.current_system_locale.language.name;
        });
        mbox.append(format_block);

        var clamp = new Bis.Latch ();
        clamp.set_child (mbox);
        this.append (clamp);
    }
}
