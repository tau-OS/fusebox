class Locale.LanguageRow : Gtk.ListBoxRow {
  public LanguageLocale language_locale { get; construct; }

  public LanguageRow (LanguageLocale language_locale) {
    Object (language_locale: language_locale);
  }

  construct {
    var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    box.add_css_class ("mini-content-block");
    set_child (box);

    var name = new Gtk.Label (language_locale.name) {
      xalign = 0
    };
    name.add_css_class ("cb-title");
    box.append (name);

    var native_name = new Gtk.Label (language_locale.native_name) {
      xalign = 0
    };
    native_name.add_css_class ("cb-subtitle");
    box.append (native_name);
  }
}
