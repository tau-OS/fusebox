class Locale.FormatPicker : He.Window {
  static GLib.List<Locale.LocaleModel> format_list;
  static construct {
    format_list = get_all_locales ();
  }

  public Locale.LocaleModel? selected_format { get; private set; }

  public FormatPicker (He.ApplicationWindow parent) {
    this.parent = parent;
  }

  construct {
    this.modal = true;
    this.resizable = false;
    this.set_size_request (440, 550);

    var main = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
    var side = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    main.append (side);
    var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
    side.append (content);

    var title = new Gtk.Label (_("Format")) {
      margin_top = 34,
      margin_start = 18,
      halign = Gtk.Align.START,
    };
    title.add_css_class ("view-title");
    content.append (title);

    var search_entry = new Gtk.SearchEntry () {
      placeholder_text = "Search formats…",
      margin_start = 18,
      halign = Gtk.Align.START
    };
    content.append (search_entry);

    var scrolled = new Gtk.ScrolledWindow () {
      vexpand = true,
      hscrollbar_policy = Gtk.PolicyType.NEVER,
    };
    content.append (scrolled);

    var listbox = new Gtk.ListBox () {
      margin_start = 18,
      margin_end = 18,
    };
    listbox.add_css_class ("content-list");
    foreach (var format in format_list) {
      listbox.append (new Locale.LocaleRow (format));
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
      margin_start = 18,
      margin_end = 18,
      margin_bottom = 18,
      halign = Gtk.Align.END
    };
    main.append (button_box);

    var cancel_button = new He.TextButton (_("Cancel"));
    cancel_button.set_size_request (200, -1);
    cancel_button.clicked.connect (() => {
      this.destroy ();
    });
    button_box.append (cancel_button);

    var apply_button = new He.FillButton (_("Set Format")) {
      sensitive = false,
    };
    apply_button.set_size_request (200, -1);
    apply_button.clicked.connect (() => {
      var selected = listbox.get_selected_row () as Locale.LocaleRow;
      if (selected != null) {
        selected_format = selected.locale;
      }
    });
    button_box.append (apply_button);

    var preview = new Preview () {
      visible = false,
      margin_end = 18
    };
    preview.set_size_request (250, -1);
    side.append (preview);

    listbox.row_selected.connect (() => {
      var selected = listbox.get_selected_row () as Locale.LocaleRow;
      apply_button.sensitive = selected != null;
      preview.visible = selected != null;
      preview.locale = selected ? .locale;
    });

    this.set_child (main);
  }
}