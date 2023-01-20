class Accounts.EditAccount : He.Window {
  public EditAccount (He.ApplicationWindow parent) {
    this.parent = parent;
  }

  construct {
    this.modal = true;
    this.resizable = false;
    this.set_size_request (440, 550);

    var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    var username_block = new He.MiniContentBlock () {
      title = "Username",
    };
    main_box.append (username_block);

    var username_entry = new Gtk.Entry ();
    username_block.child = username_entry;

    var name_block = new He.MiniContentBlock () {
      title = "Name",
    };
    main_box.append (name_block);

    var name_entry = new Gtk.Entry ();
    name_block.child = name_entry;

    var password_block = new He.MiniContentBlock () {
      title = "Password",
    };
    main_box.append (password_block);

    var password_entry = new Gtk.Entry ();
    password_entry.visibility = false;
    password_block.child = password_entry;

    var password_confirm_block = new He.MiniContentBlock () {
      title = "Confirm Password",
    };
    main_box.append (password_confirm_block);

    var password_confirm_entry = new Gtk.Entry ();
    password_confirm_entry.visibility = false;
    password_confirm_block.child = password_confirm_entry;

    this.set_child (main_box);
  }
}
