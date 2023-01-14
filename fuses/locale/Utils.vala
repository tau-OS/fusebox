namespace Locale {
  private class LanguageLocale {
    public string locale;
    public string name;
    public string native_name;
    public string language_code;

    public LanguageLocale.from_locale(string locale) {
      string language_code;
      Gnome.Languages.parse_locale(locale, out language_code, null, null, null);
      this.locale = locale;
      this.name = Gnome.Languages.get_language_from_locale(locale, null);
      this.native_name = Gnome.Languages.get_language_from_locale(locale, locale);
      this.language_code = language_code;
    }
  }

  private GLib.List<LanguageLocale?> get_all_languages() {
    var locales = Gnome.Languages.get_all_locales();
    var languages = new GLib.List<LanguageLocale>();

    foreach (var locale in locales) {
      languages.append(new LanguageLocale.from_locale(locale));
    }

    return languages;
  }

  private LanguageLocale get_current_language(Locale1Proxy proxy) {
    string? locale = null;
    foreach (var l in proxy.locale) {
      if (l.has_prefix("LANG=")) {
        locale = l.split("=")[1];
        break;
      }
    }

    if (locale == null) {
      critical("Could not get locale from Locale1");
    }

    return new LanguageLocale.from_locale(locale);
  }
}
