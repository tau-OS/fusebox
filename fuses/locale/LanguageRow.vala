class Locale.LocaleRow : Gtk.ListBoxRow {
  public LocaleModel locale { get; construct; }

  public LocaleRow (LocaleModel locale) {
    Object (locale: locale);
  }

  construct {
    var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    box.add_css_class ("mini-content-block");
    set_child (box);

    var name = new Gtk.Label (locale.name) {
      xalign = 0
    };
    name.add_css_class ("cb-title");
    box.append (name);

    var native_name = new Gtk.Label (locale.native_name) {
      xalign = 0
    };
    native_name.add_css_class ("cb-subtitle");
    box.append (native_name);
  }
}