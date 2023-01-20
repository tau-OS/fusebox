public class Accounts.AccountsView : Gtk.Box {
    construct {
        var users = Act.UserManager.get_default ().list_users ();

        var mbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        var overlay_button = new He.OverlayButton ("list-add-symbolic", null, null);
        mbox.append (overlay_button);

        var user_list = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        user_list.add_css_class ("content-list");
        user_list.append(new Accounts.AccountRow ());
        overlay_button.child = user_list;

        var clamp = new Bis.Latch ();
        clamp.set_child (mbox);
        this.append (clamp);
        this.orientation = Gtk.Orientation.VERTICAL;
    }
}
