class Accounts.EditAccount : He.Window {
  public EditAccount (He.ApplicationWindow parent) {
    this.parent = parent;
  }

  construct {
    this.modal = true;
    this.resizable = false;
    this.set_size_request (440, 550);

    var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
      margin_bottom = 12,
      margin_top = 12,
      margin_start = 12,
      margin_end = 12,
    };
    var username_block = new He.MiniContentBlock () {
      title = "Username",
    };
    main_box.append (username_block);

    var username_entry = new Gtk.Entry ();
    username_entry.set_parent (username_block);

    var name_block = new He.MiniContentBlock () {
      title = "Name",
    };
    main_box.append (name_block);

    var name_entry = new Gtk.Entry ();
    name_entry.set_parent (name_block);

    var password_block = new He.MiniContentBlock () {
      title = "Password",
    };
    main_box.append (password_block);

    var password_entry = new Gtk.Entry ();
    password_entry.visibility = false;
    password_entry.set_parent (password_block);

    var password_confirm_block = new He.MiniContentBlock () {
      title = "Confirm Password",
    };
    main_box.append (password_confirm_block);

    var password_confirm_entry = new Gtk.Entry ();
    password_confirm_entry.visibility = false;
    password_confirm_entry.set_parent (password_confirm_block);

    var button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12) {
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
    apply_button.set_size_request(200, -1);
    button_box.append (apply_button);

    this.set_child (main_box);
  }
}
