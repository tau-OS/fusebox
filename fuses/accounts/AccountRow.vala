public class Accounts.AccountRow : Gtk.ListBoxRow {
  public AccountRow (Act.User user) {
    var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

    var avatar = new He.Avatar (64, user.icon_file != null ? "file://" + user.icon_file : null, user.real_name, user.is_logged_in ()) {
      margin_end = 24,
      status = user.is_logged_in ()
    };
    main_box.append (avatar);

    var headings = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
      valign = Gtk.Align.CENTER,
    };
    main_box.append (headings);
    var title = new Gtk.Label (user.real_name) {
      xalign = 0,
    };
    title.add_css_class ("cb-title");
    headings.append (title);
    var subtitle = new Gtk.Label (user.account_type == Act.UserAccountType.ADMINISTRATOR ? "Administrator" : "User") {
      xalign = 0,
    };
    subtitle.add_css_class ("cb-subtitle");
    headings.append (subtitle);

    var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
      hexpand = true,
      valign = Gtk.Align.CENTER,
      halign = Gtk.Align.END,
    };
    main_box.append (button_box);

    var delete_button = new He.DisclosureButton ("user-trash-symbolic");
    delete_button.visible = GLib.Environment.get_user_name () != user.user_name;
    delete_button.add_css_class ("bg-meson-red");
    delete_button.clicked.connect (() => {
      var dialog = new He.Dialog (
                                  true,
                                  He.Misc.find_ancestor_of_type<He.ApplicationWindow> (this),
                                  "Delete " + user.real_name + "'s Account",
                                  "",
                                  "You cannot undo this action, and will delete " + user.real_name + "'s data.",
                                  "dialog-warning-symbolic",
                                  new He.FillButton ("Delete"),
                                  null
      );

      dialog.present ();

      dialog.primary_button.clicked.connect (() => {
        try {
          Act.UserManager.get_default ().delete_user (user, false);
        } catch (Error e) {
          critical ("Failed to delete user %s: %s", user.user_name, e.message);
        }
        dialog.close ();
      });
    });
    button_box.append (delete_button);

    var change_password_button = new He.DisclosureButton ("dialog-password-symbolic");
    change_password_button.clicked.connect (() => {
      var dialog = new Accounts.ChangePassword (user, He.Misc.find_ancestor_of_type<He.ApplicationWindow> (this));
      dialog.present ();
    });
    button_box.append (change_password_button);

    var edit_button = new He.DisclosureButton ("document-edit-symbolic");
    edit_button.clicked.connect (() => {
      var dialog = new Accounts.EditAccount (user, He.Misc.find_ancestor_of_type<He.ApplicationWindow> (this));
      dialog.present ();
    });
    button_box.append (edit_button);
    main_box.add_css_class ("mini-content-block");

    this.set_child (main_box);

    user.changed.connect (() => {
      avatar.image = user.icon_file != null ? "file://" + user.icon_file : null;
      avatar.name = user.real_name;
      title.label = user.real_name;
      subtitle.label = user.account_type == Act.UserAccountType.ADMINISTRATOR ? "Administrator" : "User";
    });
  }
}