namespace Locale {
  private class LocaleModel {
    public string locale;
    public string name;
    public string native_name;
    public string language_code;

    public LocaleModel.from_locale(string locale) {
      string language_code;
      Gnome.Languages.parse_locale(locale, out language_code, null, null, null);
      this.locale = locale;
      this.name = Gnome.Languages.get_language_from_locale(locale, null);
      this.native_name = Gnome.Languages.get_language_from_locale(locale, locale);
      this.language_code = language_code;
    }
  }

  private GLib.List<LocaleModel?> get_all_locales() {
    var locales = Gnome.Languages.get_all_locales();
    var languages = new GLib.List<LocaleModel>();

    foreach (var locale in locales) {
      languages.append(new LocaleModel.from_locale(locale));
    }

    return languages;
  }

  private struct SystemLocale {
    public LocaleModel language;
    public LocaleModel? region;
  }

  private SystemLocale get_system_locale(Locale1Proxy proxy) {
    LocaleModel? language_locale = null;
    foreach (var l in proxy.locale) {
      if (l.has_prefix("LANG=")) {
        language_locale = new LocaleModel.from_locale(l.split("=")[1]);
        break;
      }
    }

    if (language_locale == null) {
      critical("Could not get languagelocale from Locale1");
    }

    LocaleModel? region_locale = null;
    foreach (var l in proxy.locale) {
      if (l.has_prefix("LC_MEASUREMENT=")) {
        region_locale = new LocaleModel.from_locale(l.split("=")[1]);
        break;
      }
    }

    return SystemLocale() {
      language = language_locale,
      region = region_locale
    };
  }

  // ? Region is also a locale, although for fomatting of dates, times, currency, etc.
  private void update_system_locale(Locale1Proxy proxy, SystemLocale system_locale) {
    var locales = new GLib.Array<string>();
    locales.append_val("LANG=%s".printf(system_locale.language.locale));

    var region = system_locale.region?.locale;
    if (region != null) {
      locales.append_val("LC_MEASUREMENT=%s".printf(region));
      locales.append_val("LC_MONETARY=%s".printf(region));
      locales.append_val("LC_NUMERIC=%s".printf(region));
      locales.append_val("LC_PAPER=%s".printf(region));
      locales.append_val("LC_TIME=%s".printf(region));
    }

    try {
      proxy.set_locale(locales.data, true);
    } catch (GLib.Error e) {
      critical("Could not set region locale: %s", e.message);
    }
  }
}
