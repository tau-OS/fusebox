class Accounts.EditAccount : He.Window {
  private Act.User user;

  private string real_name;
  private bool administator;
  private string icon_file;
  private static Regex username_regex;

  static construct {
    try {
      username_regex = new Regex ("^[a-z0-9]*$");
    } catch (Error e) {
      critical ("Failed to compile regex: %s", e.message);
    }
  }

  bool fields_changed () {
    return this.real_name != this.user.get_real_name () ||
           this.administator != (this.user.get_account_type () == Act.UserAccountType.ADMINISTRATOR) ||
           this.icon_file != this.user.icon_file;
  }

  void update_user () {
    if (this.real_name != this.user.get_real_name ())
      this.user.set_real_name (this.real_name);

    if (this.administator != (this.user.get_account_type () == Act.UserAccountType.ADMINISTRATOR))
      this.user.set_account_type (this.administator ? Act.UserAccountType.ADMINISTRATOR : Act.UserAccountType.STANDARD);

    if (this.icon_file != this.user.icon_file)
      this.user.set_icon_file (this.icon_file);
  }

  public EditAccount (Act.User user, He.ApplicationWindow parent) {
    this.parent = parent;
    this.resizable = false;

    this.user = user;
    this.real_name = user.get_real_name ();
    this.administator = user.get_account_type () == Act.UserAccountType.ADMINISTRATOR;
    this.icon_file = user.icon_file;

    var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);

    var avatar_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 16) {
      margin_bottom = 12,
      valign = Gtk.Align.CENTER,
      halign = Gtk.Align.START,
    };
    main_box.append (avatar_box);

    var avatar = new He.Avatar (96, user.icon_file != null ? "file://" + user.icon_file : null, user.real_name, false);
    var avatar_edit_button = new He.Button ("document-edit-symbolic", "") {
      valign = Gtk.Align.END,
      halign = Gtk.Align.END,
      is_disclosure = true
    };

    var avatar_overlay = new Gtk.Overlay () {
      valign = Gtk.Align.CENTER,
      halign = Gtk.Align.CENTER,
    };
    avatar_overlay.set_child (avatar);
    avatar_overlay.add_overlay (avatar_edit_button);
    avatar_box.append (avatar_overlay);

    var title = new Gtk.Label (user.real_name) {
      halign = Gtk.Align.CENTER,
    };
    title.add_css_class ("display");
    avatar_box.append (title);

    var username_entry = new He.TextField.from_regex (username_regex) {
      placeholder_text = _("Username"),
      text = user.get_user_name (),
      sensitive = false,
    };
    username_entry.support_text = (_("4—32 non-capitalized letters/numbers."));
    main_box.append (username_entry);

    var name_entry = new He.TextField () {
      text = user.real_name,
    };
    name_entry.placeholder_text = _("Name");
    name_entry.support_text = (_("The person's name."));
    main_box.append (name_entry);

    var administrator_block = new He.MiniContentBlock () {
      title = "Administrator",
      subtitle = "An administrator account can act on \nsystem sensitive settings."
    };
    administrator_block.add_css_class ("text-meson-red");
    main_box.append (administrator_block);

    var administrator_switch = new He.Switch () {
      valign = Gtk.Align.CENTER,
    };
    administrator_switch.add_css_class ("bg-meson-red");
    administrator_switch.set_parent (administrator_block);
    administrator_switch.iswitch.active = user.get_account_type () == Act.UserAccountType.ADMINISTRATOR;

    var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
      margin_top = 12,
      homogeneous = true,
      valign = Gtk.Align.END,
      vexpand = true,
    };
    main_box.append (button_box);

    var cancel_button = new He.Button (null, _("Cancel")) {
      is_textual = true
    };
    cancel_button.set_size_request (200, -1);
    cancel_button.clicked.connect (() => {
      this.destroy ();
    });
    button_box.append (cancel_button);

    var apply_button = new He.Button (null, _("Edit Account")) {
      sensitive = false,
      is_fill = true
    };
    apply_button.clicked.connect (() => {
      this.update_user ();
      this.destroy ();
    });
    apply_button.set_size_request (200, -1);
    button_box.append (apply_button);

    var winhandle = new Gtk.WindowHandle ();
    winhandle.set_child (main_box);

    this.set_child (winhandle);
    main_box.add_css_class ("dialog-content");
    this.add_css_class ("dialog-content");

    name_entry.get_internal_entry ().changed.connect (() => {
      this.real_name = name_entry.text;
      apply_button.sensitive = this.fields_changed ();
    });

    administrator_switch.iswitch.notify["active"].connect (() => {
      this.administator = administrator_switch.iswitch.active;
      apply_button.sensitive = this.fields_changed ();
    });

    avatar_edit_button.clicked.connect (() => {
      var dialog = new Gtk.FileChooserDialog (_("Select an image"),
                                              this,
                                              Gtk.FileChooserAction.OPEN,
                                              _("Cancel"),
                                              Gtk.ResponseType.CANCEL,
                                              _("Select"),
                                              Gtk.ResponseType.ACCEPT);
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
  }
}
