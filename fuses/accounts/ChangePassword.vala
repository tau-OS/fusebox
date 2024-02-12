class Accounts.ChangePassword : He.Window {
  public ChangePassword (Act.User user, He.ApplicationWindow parent) {
    this.parent = parent;
    this.resizable = false;

    var main = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
    var winhandle = new Gtk.WindowHandle ();
    winhandle.set_child (main);

    this.set_child (winhandle);
    main.add_css_class ("dialog-content");
    this.add_css_class ("dialog-content");

    var title = new Gtk.Label (_("Change Password")) {
      halign = Gtk.Align.START,
      margin_bottom = 12,
    };
    title.add_css_class ("view-title");
    main.append (title);

    var password_entry = new He.TextField ();
    password_entry.visibility = false;
    password_entry.placeholder_text = "Password";
    main.append (password_entry);

    var password_confirm_entry = new He.TextField ();
    password_confirm_entry.visibility = false;
    password_confirm_entry.placeholder_text = "Confirm Password";
    password_confirm_entry.support_text = (_("Remember your password."));
    main.append (password_confirm_entry);

    var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
      homogeneous = true,
      valign = Gtk.Align.END,
      vexpand = true,
      margin_top = 12,
    };
    main.append (button_box);

    var cancel_button = new He.TextButton (_("Cancel"));
    cancel_button.set_size_request (200, -1);
    cancel_button.clicked.connect (() => {
      this.destroy ();
    });
    button_box.append (cancel_button);

    var apply_button = new He.FillButton (_("Update")) {
      sensitive = false,
    };
    apply_button.set_size_request (200, -1);
    apply_button.clicked.connect (() => {
      user.set_password (password_entry.get_internal_entry ().text, user.password_hint);
      this.destroy ();
    });
    button_box.append (apply_button);

    password_confirm_entry.notify["is-valid"].connect (() => {
      apply_button.sensitive = password_entry.get_internal_entry ().text == password_confirm_entry.get_internal_entry ().text;
    });
  }
}
