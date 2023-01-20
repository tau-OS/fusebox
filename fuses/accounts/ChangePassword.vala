class Accounts.ChangePassword : He.Window {
  public ChangePassword (Act.User user, He.ApplicationWindow parent) {
    this.parent = parent;
    this.modal = true;
    this.resizable = false;
    this.set_size_request (440, 550);

    var main = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
      margin_top = 12,
      margin_bottom = 12,
      margin_start = 12,
      margin_end = 12,
    };
    this.set_child (main);

    var title = new Gtk.Label (_("Change Password")) {
      margin_top = 22,
      halign = Gtk.Align.START,
    };
    title.add_css_class ("view-title");
    main.append(title);

    var password_block = new He.MiniContentBlock () {
      title = "Password",
    };
    main.append (password_block);

    var password_entry = new Gtk.Entry ();
    password_entry.visibility = false;
    password_entry.set_parent (password_block);

    var password_confirm_block = new He.MiniContentBlock () {
      title = "Confirm Password",
    };
    main.append (password_confirm_block);

    var password_confirm_entry = new Gtk.Entry ();
    password_confirm_entry.visibility = false;
    password_confirm_entry.set_parent (password_confirm_block);

    var button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12) {
      homogeneous = true,
      valign = Gtk.Align.END,
      vexpand = true,
    };
    main.append (button_box);

    var cancel_button = new He.TextButton (_("Cancel"));
    cancel_button.set_size_request(200, -1);
    cancel_button.clicked.connect (() => {
      this.destroy ();
    });
    button_box.append (cancel_button);

    var apply_button = new He.FillButton (_("Update")) {
      sensitive = false,
    };
    apply_button.set_size_request(200, -1);
    button_box.append (apply_button);
  }
}
