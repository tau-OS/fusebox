[CCode (cheader_filename = "monetary.h", cname = "strfmon")]
extern ssize_t strfmon ([CCode (array_length = false)] uint8[] s, size_t max, string format, ...);

namespace Locale {
  private class LocaleModel {
    public string locale;
    public string name;
    public string native_name;
    public string language_code;

    public LocaleModel.from_locale (string locale) {
      string language_code;
      Gnome.Languages.parse_locale (locale, out language_code, null, null, null);
      this.locale = locale;
      this.name = Gnome.Languages.get_language_from_locale (locale, null);
      this.native_name = Gnome.Languages.get_language_from_locale (locale, locale);
      this.language_code = language_code;
    }
  }

  private GLib.List<LocaleModel?> get_all_locales () {
    var locales = Gnome.Languages.get_all_locales ();
    var languages = new GLib.List<LocaleModel> ();

    foreach (var locale in locales) {
      languages.append (new LocaleModel.from_locale (locale));
    }

    return languages;
  }

  private struct SystemLocale {
    public LocaleModel language;
    public LocaleModel? format;
  }

  private SystemLocale get_system_locale (Locale1Proxy proxy) {
    LocaleModel? language_locale = null;
    foreach (var l in proxy.locale) {
      if (l.has_prefix ("LANG=")) {
        language_locale = new LocaleModel.from_locale (l.split ("=")[1]);
        break;
      }
    }

    if (language_locale == null) {
      critical ("Could not get languagelocale from Locale1");
    }

    LocaleModel? format_locale = null;
    foreach (var l in proxy.locale) {
      if (l.has_prefix ("LC_MEASUREMENT=")) {
        format_locale = new LocaleModel.from_locale (l.split ("=")[1]);
        break;
      }
    }

    return SystemLocale () {
             language = language_locale,
             format = format_locale
    };
  }

  // private void update_system_locale(Locale1Proxy proxy, SystemLocale system_locale) {
  // var locales = new GLib.Array<string>();
  // locales.append_val("LANG=%s".printf(system_locale.language.locale));

  // var format = system_locale.format?.locale;
  // if (format != null) {
  // locales.append_val("LC_MEASUREMENT=%s".printf(format));
  // locales.append_val("LC_MONETARY=%s".printf(format));
  // locales.append_val("LC_NUMERIC=%s".printf(format));
  // locales.append_val("LC_PAPER=%s".printf(format));
  // locales.append_val("LC_TIME=%s".printf(format));
  // }

  // try {
  // proxy.set_locale(locales.data, true);
  // } catch (GLib.Error e) {
  // critical("Could not set system locale: %s", e.message);
  // }
  // }

  // ? Note that the system locale is the default when user language/format is not set
  private struct UserLocale {
    public LocaleModel? language;
    public LocaleModel? format;
  }

  private UserLocale get_user_locale (Act.User current_user) {
    var locale_settings = new GLib.Settings ("org.gnome.system.locale");

    var language_id = current_user.language;
    var format_id = locale_settings.get_string ("region");

    LocaleModel? language_locale = null;
    if (language_id != null && language_id != "") {
      language_locale = new LocaleModel.from_locale (language_id);
    }

    LocaleModel? format_locale = null;
    if (format_id != null && format_id != "") {
      format_locale = new LocaleModel.from_locale (format_id);
    }

    return UserLocale () {
             language = language_locale,
             format = format_locale
    };
  }

  private void update_user_locale (Act.User current_user, UserLocale user_locale) {
    var locale_settings = new GLib.Settings ("org.gnome.system.locale");

    var language_id = user_locale.language ? .locale;
    var format_id = user_locale.format ? .locale;

    if (language_id != null) {
      current_user.set_language (language_id);
    }

    if (format_id != null) {
      locale_settings.set_string ("region", format_id);
    }
  }

  private struct LocaleExample {
    public string date;
    public string time;
    public string currency;
    public string temperature;
  }

  private LocaleExample get_examples_for_locale (LocaleModel locale) {
    var current_locale = GLib.Intl.setlocale (GLib.LocaleCategory.ALL, null);
    if (current_locale == null) {
      critical ("Could not get current locale");
    }
    var example_locale = GLib.Intl.setlocale (GLib.LocaleCategory.ALL, locale.locale);
    if (example_locale == null) {
      critical ("Could not set locale to %s", locale.locale);
    }

    var date = new GLib.DateTime.now_local ().format ("%x");
    var time = new GLib.DateTime.now_local ().format ("%X");

    var realunit = GWeather.TemperatureUnit.DEFAULT.to_real ();
    var temperature = realunit == GWeather.TemperatureUnit.CENTIGRADE ? "20°C" : "68°F";

    var currency = new uint8[100];
    strfmon (currency, currency.length, "%n", 1234.56);

    if (GLib.Intl.setlocale (GLib.LocaleCategory.ALL, current_locale) == null) {
      critical ("Could not reset locale to %s", current_locale);
    }

    return LocaleExample () {
             date = date,
             time = time,
             currency = (string) currency,
             temperature = temperature
    };
  }
}