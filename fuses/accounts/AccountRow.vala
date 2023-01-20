public class Accounts.AccountRow : Gtk.Box {
  construct {
    var avatar = new He.Avatar (64, null, "Lea Gray") {
      margin_end = 24,
    };
    this.append(avatar);

    var headings = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
      valign = Gtk.Align.CENTER,
    };
    this.append(headings);
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
    this.append(edit_button);

    this.add_css_class ("mini-content-block");
  }
}
