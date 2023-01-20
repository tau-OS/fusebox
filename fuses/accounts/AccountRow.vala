public class Accounts.AccountRow : Gtk.ListBoxRow {
  construct {
    var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

    var avatar = new He.Avatar (64, null, "Lea Gray") {
      margin_end = 24,
    };
    main_box.append(avatar);

    var headings = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
      valign = Gtk.Align.CENTER,
    };
    main_box.append(headings);
    var title = new Gtk.Label ("Lea Gray") {
      xalign = 0,
    };
    title.add_css_class ("cb-title");
    headings.append(title);
    var subtitle = new Gtk.Label ("User") {
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
  }
}
