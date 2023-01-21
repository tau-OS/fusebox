class Accounts.CreateAccount : He.Window {
  private static Regex username_regex;

  static construct {
    username_regex = new Regex ("^[a-z][a-z0-9_-]*$");
  }

  private string username = "";
  private string real_name = "";
  private bool administator = false;
  private string? icon_file = null;
  private string password = "";
  private string password_confirm = "";


  bool fields_changed () {
    return this.username != "" &&
           username_regex.match (this.username) &&
           this.real_name != "" &&
           this.password != "" &&
           this.password_confirm != "" &&
           this.password == this.password_confirm;
  }

  public CreateAccount (He.ApplicationWindow parent) {
    this.parent = parent;
    this.modal = true;
    this.resizable = false;

    var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
      margin_bottom = 12,
      margin_top = 12,
      margin_start = 12,
      margin_end = 12,
    };

    var avatar_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
      margin_bottom = 12,
      margin_top = 12,
      valign = Gtk.Align.CENTER,
      halign = Gtk.Align.CENTER,
    };
    main_box.append (avatar_box);

    var avatar = new He.Avatar (96, null, "New User");
    var avatar_edit_button = new He.DisclosureButton ("document-edit-symbolic") {
      valign = Gtk.Align.END,
      halign = Gtk.Align.END,
    };

    var avatar_overlay = new Gtk.Overlay () {
      valign = Gtk.Align.CENTER,
      halign = Gtk.Align.CENTER,
    };
    avatar_overlay.set_child (avatar);
    avatar_overlay.add_overlay (avatar_edit_button);
    avatar_box.append (avatar_overlay);

    var title = new Gtk.Label("New User") {
      halign = Gtk.Align.CENTER,
    };
    title.add_css_class ("large-title");
    avatar_box.append (title);

    var username_block = new He.MiniContentBlock () {
      title = "Username",
    };
    main_box.append (username_block);

    var username_entry = new Gtk.Entry () {
      placeholder_text = "emilyfuentes",
      max_length = 32,
    };
    username_entry.set_parent (username_block);

    var name_block = new He.MiniContentBlock () {
      title = "Name",
    };
    main_box.append (name_block);

    var name_entry = new Gtk.Entry () {
      placeholder_text = "Emily Fuentes",
    };
    name_entry.set_parent (name_block);

    var password_block = new He.MiniContentBlock () {
      title = "Password",
    };
    main_box.append (password_block);

    var password_entry = new Gtk.Entry () {
      visibility = false,
      placeholder_text = "••••••••",
    };
    password_entry.set_parent (password_block);

    var password_confirm_block = new He.MiniContentBlock () {
      title = "Confirm Password",
    };
    main_box.append (password_confirm_block);

    var password_confirm_entry = new Gtk.Entry () {
      visibility = false,
      placeholder_text = "••••••••",
    };

    password_confirm_entry.set_parent (password_confirm_block);

    var administrator_block = new He.MiniContentBlock () {
      title = "Administrator",
      subtitle = "An administrator account can act on \nsystem sensitive settings."
    };
    administrator_block.add_css_class ("text-meson-red");
    main_box.append (administrator_block);

    var administrator_switch = new Gtk.Switch () {
      valign = Gtk.Align.CENTER,
    };
    administrator_switch.add_css_class ("bg-meson-red");
    administrator_switch.set_parent (administrator_block);

    var button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12) {
      margin_top = 12,
      homogeneous = true,
      valign = Gtk.Align.END,
      vexpand = true,
    };
    main_box.append (button_box);

    var cancel_button = new He.TextButton (_("Cancel"));
    cancel_button.set_size_request(200, -1);
    cancel_button.clicked.connect (() => {
      this.destroy ();
    });
    button_box.append (cancel_button);

    var apply_button = new He.FillButton (_("Create Account")) {
      sensitive = false,
    };
    apply_button.clicked.connect (() => {
      create_user (
        this.username,
        this.real_name,
        this.password,
        this.administator ? Act.UserAccountType.ADMINISTRATOR : Act.UserAccountType.STANDARD,
        this.icon_file
      );
      this.destroy ();
    });
    apply_button.set_size_request(200, -1);
    button_box.append (apply_button);

    this.set_child (main_box);

    username_entry.changed.connect (() => {
      this.username = username_entry.text;
      apply_button.sensitive = this.fields_changed ();
    });

    name_entry.changed.connect (() => {
      this.real_name = name_entry.text;
      title.set_text (this.real_name);
      apply_button.sensitive = this.fields_changed ();
    });

    password_entry.changed.connect (() => {
      this.password = password_entry.text;
      apply_button.sensitive = this.fields_changed ();
    });

    password_confirm_entry.changed.connect (() => {
      this.password_confirm = password_confirm_entry.text;
      apply_button.sensitive = this.fields_changed ();
    });

    administrator_switch.notify["active"].connect (() => {
      this.administator = administrator_switch.active;
      apply_button.sensitive = this.fields_changed ();
    });

    avatar_edit_button.clicked.connect (() => {
      var dialog = new Gtk.FileChooserDialog (_("Select an image"), this, Gtk.FileChooserAction.OPEN, _("Cancel"), Gtk.ResponseType.CANCEL, _("Select"), Gtk.ResponseType.ACCEPT);
      dialog.set_transient_for (this);
      dialog.set_modal (true);
      dialog.set_select_multiple (false);

      var filter = new Gtk.FileFilter ();
      filter.add_pixbuf_formats ();
      dialog.add_filter (filter);

      dialog.present ();

      dialog.response.connect ((response) => {
        if (response == Gtk.ResponseType.ACCEPT) {
          var file = dialog.get_file ();
          avatar.image = file.get_uri ();
          this.icon_file = file.get_path ();
          apply_button.sensitive = this.fields_changed ();
        }

        dialog.destroy ();
      });
    });

    // * TODO: Add regex to username entry
    //  var username_editable = username_entry.get_delegate ();

    //  username_editable.insert_text.connect ((text, position) => {
    //    var new_text = username_entry.text == "" ? text : username_entry.text.slice (0, position) + text + username_entry.text.slice (position, -1);
    //    if (new_text == "") {
    //      return;
    //    };

    //    if (!username_regex.match (username_entry.text)) {
    //      print("no match");
    //      GLib.Signal.stop_emission_by_name (username_editable, "insert-text");
    //    };
    //  });

    //  username_editable.delete_text.connect ((start, end) => {
    //    var new_text = username_entry.text.slice (0, start) + username_entry.text.slice (end, -1);
    //    if (new_text == "") {
    //      return;
    //    };

    //    if (!username_regex.match (username_entry.text)) {
    //      GLib.Signal.stop_emission_by_name (username_editable, "delete-text");
    //    };
    //  });
  }
}
