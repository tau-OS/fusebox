class Locale.LanguagePicker : He.Window {
  static GLib.List<Locale.LanguageLocale> language_list;
  static construct {
    language_list = get_all_languages ();
  }

  public Locale.LanguageLocale? selected_language { get; private set; }

  public LanguagePicker (He.ApplicationWindow parent) {
    this.parent = parent;
    this.transient_for = parent;
  }

  construct {
    this.modal = true;
    this.resizable = false;
    this.set_size_request (440, 550);

    var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);

    var title = new Gtk.Label (_("Language")) {
      margin_top = 34,
      margin_start = 18,
      halign = Gtk.Align.START,
    };
    title.add_css_class ("view-title");
    content.append(title);

    var search_entry = new Gtk.SearchEntry() {
      placeholder_text = "Search languages…",
      margin_start = 18,
      halign = Gtk.Align.START
    };
    content.append (search_entry);

    var scrolled = new Gtk.ScrolledWindow() {
      vexpand = true,
      hscrollbar_policy = Gtk.PolicyType.NEVER,
    };
    content.append (scrolled);

    var listbox = new Gtk.ListBox() {
      margin_start = 18,
      margin_end = 18,

    };
    listbox.add_css_class ("content-list");
    foreach (var language in language_list) {
      listbox.append (new Locale.LanguageRow (language));
    }
    listbox.set_filter_func((row) => {
      return (row as Locale.LanguageRow).language_locale.name.down ().contains (search_entry.text.down ());
    });
    listbox.set_sort_func((row1, row2) => {
      return (row1 as Locale.LanguageRow).language_locale.name.collate ((row2 as Locale.LanguageRow).language_locale.name);
    });
    search_entry.changed.connect (() => {
      listbox.invalidate_filter ();
    });
    scrolled.set_child (listbox);

    var button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12) {
      homogeneous = true,
      margin_start = 18,
      margin_end = 18,
      margin_bottom = 18,
    };
    content.append (button_box);

    var cancel_button = new He.TextButton (_("Cancel"));
    cancel_button.clicked.connect (() => {
      this.destroy ();
    });
    button_box.append (cancel_button);

    var apply_button = new He.FillButton (_("Set Language"));
    apply_button.clicked.connect (() => {
      var selected = listbox.get_selected_row () as Locale.LanguageRow;
      if (selected != null) {
        selected_language = selected.language_locale;
      }
    });
    button_box.append (apply_button);

    this.set_child (content);
  }
}
