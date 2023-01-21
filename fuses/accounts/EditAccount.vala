class Accounts.EditAccount : He.Window {
  private Act.User user;

  private string real_name;
  private bool administator;
  private string icon_file;

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
    this.modal = true;
    this.resizable = false;

    this.user = user;
    this.real_name = user.get_real_name ();
    this.administator = user.get_account_type () == Act.UserAccountType.ADMINISTRATOR;
    this.icon_file = user.icon_file;

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

    var avatar = new He.Avatar (96, user.icon_file != null ? "file://" + user.icon_file : null, user.real_name);
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

    var title = new Gtk.Label(user.real_name) {
      halign = Gtk.Align.CENTER,
    };
    title.add_css_class ("large-title");
    avatar_box.append (title);

    var username_block = new He.MiniContentBlock () {
      title = "Username",
    };
    main_box.append (username_block);

    var username_entry = new Gtk.Entry () {
      text = user.get_user_name (),
      sensitive = false,
    };
    username_entry.set_parent (username_block);

    var name_block = new He.MiniContentBlock () {
      title = "Name",
    };
    main_box.append (name_block);

    var name_entry = new Gtk.Entry () {
      text = user.real_name,
    };
    name_entry.set_parent (name_block);

    var administrator_block = new He.MiniContentBlock () {
      title = "Administrator",
      subtitle = "An administrator account can act on \nsystem sensitive settings."
    };
    administrator_block.add_css_class ("text-meson-red");
    main_box.append (administrator_block);

    var administrator_switch = new Gtk.Switch () {
      active = user.get_account_type () == Act.UserAccountType.ADMINISTRATOR,
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

    var apply_button = new He.FillButton (_("Edit Account")) {
      sensitive = false,
    };
    apply_button.clicked.connect (() => {
      this.update_user ();
      this.destroy ();
    });
    apply_button.set_size_request(200, -1);
    button_box.append (apply_button);

    this.set_child (main_box);

    name_entry.changed.connect (() => {
      this.real_name = name_entry.text;
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
  }
}
