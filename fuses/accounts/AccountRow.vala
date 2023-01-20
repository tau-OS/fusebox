public class Accounts.AccountRow : Gtk.ListBoxRow {
  public AccountRow(Act.User user) {
    var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

    var avatar = new He.Avatar (64, null, user.real_name) {
      margin_end = 24,
    };
    main_box.append(avatar);

    var headings = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
      valign = Gtk.Align.CENTER,
    };
    main_box.append(headings);
    var title = new Gtk.Label (user.real_name) {
      xalign = 0,
    };
    title.add_css_class ("cb-title");
    headings.append(title);
    var subtitle = new Gtk.Label (user.account_type == Act.UserAccountType.ADMINISTRATOR ? "Administrator" : "User") {
      xalign = 0,
    };
    subtitle.add_css_class ("cb-subtitle");
    headings.append(subtitle);

    var edit_button = new He.DisclosureButton ("document-edit-symbolic") {
      hexpand = true,
      valign = Gtk.Align.CENTER,
      halign = Gtk.Align.END,
    };
    edit_button.clicked.connect (() => {
      var dialog = new Accounts.EditAccount (He.Misc.find_ancestor_of_type<He.ApplicationWindow>(this));
      dialog.present ();
    });
    main_box.append(edit_button);
    main_box.add_css_class ("mini-content-block");

    this.set_child (main_box);

    user.changed.connect (() => {
      avatar.set_name (user.real_name);
      title.label = user.real_name;
      subtitle.label = user.account_type == Act.UserAccountType.ADMINISTRATOR ? "Administrator" : "User";
    });
  }
}
