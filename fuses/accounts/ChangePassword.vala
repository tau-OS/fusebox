class Accounts.ChangePassword : He.Window {
  public ChangePassword (Act.User user, He.ApplicationWindow parent) {
    this.parent = parent;
    this.modal = true;
    this.resizable = false;

    var main = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
      margin_bottom = 24,
      margin_top = 24,
      margin_start = 24,
      margin_end = 24,
    };
    var winhandle = new Gtk.WindowHandle ();
    winhandle.set_child (main);

    this.set_child (winhandle);
    this.add_css_class ("dialog-content");

    var title = new Gtk.Label (_("Change Password")) {
      margin_top = 22,
      halign = Gtk.Align.START,
    };
    title.add_css_class ("view-title");
    main.append (title);

    var password_block = new He.MiniContentBlock () {
      title = "Password",
    };
    main.append (password_block);

    var password_entry = new He.TextField ();
    password_entry.visibility = false;
    password_entry.placeholder_text = "••••••••";
    password_entry.set_parent (password_block);

    var password_confirm_block = new He.MiniContentBlock () {
      title = "Confirm Password",
    };
    main.append (password_confirm_block);

    var password_confirm_entry = new He.TextField ();
    password_confirm_entry.visibility = false;
    password_confirm_entry.placeholder_text = "••••••••";
    password_confirm_entry.set_parent (password_confirm_block);
    password_confirm_entry.support_text = (_("Remember your password."));

    var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
      homogeneous = true,
      valign = Gtk.Align.END,
      vexpand = true,
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
      user.set_password (password_entry.text, user.password_hint);
      this.destroy ();
    });
    button_box.append (apply_button);

    password_confirm_entry.notify["is-valid"].connect (() => {
      apply_button.sensitive = password_entry.text == password_confirm_entry.text;
    });
  }
}