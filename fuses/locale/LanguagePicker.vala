class Locale.LanguagePicker : He.Window {
  static GLib.List<Locale.LocaleModel> language_list;
  static construct {
    language_list = get_all_locales ();
  }

  public Locale.LocaleModel? selected_language { get; private set; }

  public LanguagePicker (He.ApplicationWindow parent) {
    this.parent = parent;
  }

  construct {
    this.resizable = false;
    this.set_size_request (440, 550);
    this.add_css_class ("dialog-content");

    var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
    content.add_css_class ("dialog-content");

    var title = new Gtk.Label (_("Language")) {
      halign = Gtk.Align.START,
    };
    title.add_css_class ("view-title");
    content.append (title);

    var search_entry = new Gtk.SearchEntry () {
      placeholder_text = "Search languages…",
      halign = Gtk.Align.START
    };
    content.append (search_entry);

    var scrolled = new Gtk.ScrolledWindow () {
      vexpand = true,
      hscrollbar_policy = Gtk.PolicyType.NEVER,
    };
    content.append (scrolled);

    var listbox = new Gtk.ListBox () {
    };
    listbox.add_css_class ("content-list");
    foreach (var language in language_list) {
      listbox.append (new Locale.LocaleRow (language));
    }
    listbox.set_filter_func ((row) => {
      return ((Locale.LocaleRow) row).locale.name.down ().contains (search_entry.text.down ());
    });
    listbox.set_sort_func ((row1, row2) => {
      return ((Locale.LocaleRow) row1).locale.name.collate (((Locale.LocaleRow) row2).locale.name);
    });
    search_entry.changed.connect (() => {
      listbox.invalidate_filter ();
    });
    scrolled.set_child (listbox);

    var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
      homogeneous = true,
    };
    content.append (button_box);

    var cancel_button = new He.TextButton (_("Cancel"));
    cancel_button.clicked.connect (() => {
      this.destroy ();
    });
    button_box.append (cancel_button);

    var apply_button = new He.FillButton (_("Set Language")) {
      sensitive = false,
    };
    apply_button.clicked.connect (() => {
      var selected = listbox.get_selected_row () as Locale.LocaleRow;
      if (selected != null) {
        selected_language = selected.locale;
      }
    });
    button_box.append (apply_button);

    listbox.row_selected.connect (() => {
      var selected = listbox.get_selected_row () as Locale.LocaleRow;
      apply_button.sensitive = selected != null;
    });

    this.set_child (content);
  }
}
