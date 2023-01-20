class Accounts.EditAccount : He.Window {
  public EditAccount (Act.User user, He.ApplicationWindow parent) {
    this.parent = parent;
    this.modal = true;
    this.resizable = false;
    this.set_size_request (440, 550);

    var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
      margin_bottom = 12,
      margin_top = 12,
      margin_start = 12,
      margin_end = 12,
    };

    var avatar_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
      margin_bottom = 12
    };
    main_box.append (avatar_box);

    var avatar = new He.Avatar (128, user.icon_file != null ? "file://" + user.icon_file : null, user.real_name);
    avatar_box.append (avatar);

    var avatar_button = new He.DisclosureButton ("document-edit-symbolic");
    avatar_box.append (avatar_button);

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
      text = user.get_real_name (),
    };
    name_entry.set_parent (name_block);

    var administrator_block = new He.MiniContentBlock () {
      title = "Administrator",
      subtitle = "An administrator account can act on system sensitive settings."
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
